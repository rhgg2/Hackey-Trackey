--[[
@noindex
]]--

-- Helper functions for microtuning

local function print(...)
  if ( not ... ) then
    reaper.ShowConsoleMsg("nil value\n")
    return
  end
  reaper.ShowConsoleMsg(...)
  reaper.ShowConsoleMsg("\n")
end

microtuning = {}

local tuning12EDO = {
  name      = '12EDO',
  pitches   = {[0] = 0, 100, 
                     200, 
                     300, 400, 
                     500, 600, 
                     700, 
                     800, 900, 
                     1000, 1100},
  stepNames = {[0] = 'A-', 'A#',
                     'B-', 
                     'C-', 'C#',
                     'D-', 'D#',
                     'E-', 
                     'F-', 'F#',
                     'G-', 'G#'},
  octaveStep   = 3
}

local tuning19EDO = {
  name      = '19EDO',
  pitches   = {[0] = 0, 63, 126,
                     189, 253, 
                     316, 379, 442, 
                     505, 568, 632, 
                     695, 758, 
                     821, 884, 947, 
                     1011, 1074, 1137},
  stepNames = {[0] = 'A-', 'A#', 'Bb',
                     'B-', 'B#',
                     'C-', 'C#', 'Db',
                     'D-', 'D#', 'Eb',
                     'E-', 'E#',
                     'F-', 'F#', 'Gb',
                     'G-', 'G#', 'Ab'},
  octaveStep = 5
}

local tuning31EDO = {
  name      = '31EDO',
  pitches   = {[0] = 0, 39, 77, 116, 155, 
                     194, 232, 271, 
                     310, 348, 387, 426, 465, 
                     503, 542, 581, 619, 658, 
                     697, 735, 774, 
                     813, 852, 890, 929, 968, 
                     1006, 1045, 1084, 1123, 1161},
  stepNames = {[0] = 'A-', 'A^', 'A#', 'Bb', 'Bv',
                     'B-', 'B^', 'Cv',
                     'C-', 'C^', 'C#', 'Db', 'Dv',
                     'D-', 'D^', 'D#', 'Eb', 'Ev',
                     'E-', 'E^', 'Fv',
                     'F-', 'F^', 'F#', 'Gb', 'Gv',
                     'G-', 'G^', 'G#', 'Ab', 'Av' },
  octaveStep = 7
}

local tuning53EDO = {
  name      = '53EDO',
  pitches   = {[0] = 0, 23, 45, 68, 91, 
                     113, 136, 158, 181, 
                     204, 226, 249, 272, 
                     294, 317, 340, 362, 385, 
                     408, 430, 453, 475, 
                     498, 521, 543, 566, 589, 
                     611, 634, 657, 679, 
                     702, 725, 747, 770, 
                     792, 815, 838, 860, 883, 
                     906, 928, 951, 974, 
                     996, 1019, 1042, 1064, 1087, 
                     1109, 1132, 1155, 1177},
  stepNames = {[0] = 'A-', 'A>', 'A)', 'A]', 'Bb', 
                     'A#', 'B[', 'B(', 'B<', 
                     'B-', 'B>', 'B)', 'C<',
                     'C-', 'C>', 'C)', 'C]', 'Db', 
                     'C#', 'D[', 'D(', 'D<', 
                     'D-', 'D>', 'D)', 'D]', 'Eb', 
                     'D#', 'E[', 'E(', 'E<', 
                     'E-', 'E>', 'E)', 'F<',
                     'F-', 'F>', 'F)', 'F]', 'Gb', 
                     'F#', 'G[', 'G(', 'G<', 
                     'G-', 'G>', 'G)', 'G]', 'Ab', 
                     'G#', 'A[', 'A(', 'A<'},
  octaveStep = 12
}

microtuning.tunings = {
  [0] = tuning12EDO,
  tuning19EDO,
  tuning31EDO,
  tuning53EDO
}

function microtuning:findTuning(name)
  for i,v in pairs(self.tunings) do
    if v.name == name then
      return i,v
    end
  end
  return false
end

function microtuning:setTuningFromNumber(num)
  self.activeTuning = self.tunings[num] or self.activeTuning
  return num
end

function microtuning:setDefaultTuning()
  local retval
  retval, self.activeTuning = self:findTuning('12EDO')
  return retval
end

function microtuning:serialiseTuning()
  local pitches = {}
  local stepNames = {}
  for i = 0,#self.activeTuning.pitches do
    table.insert(pitches, tostring(self.activeTuning.pitches[i]))
    table.insert(stepNames, string.format('%2s',self.activeTuning.stepNames[i]))
  end
  return string.format('%5s',self.activeTuning.name) .. table.concat(pitches, ",") .. '|' .. table.concat(stepNames) .. '|' .. tostring(self.activeTuning.octaveStep)
end

function microtuning:unserialiseTuning(str)
  local name, pitchTxt, stepTxt, octaveTxt = string.match(str,
                                                          '(.....)([^|]*)|([^|]*)|(.*)')
  local pitches = {}
  local stepNames = {}
  local i = 1
  if pitchTxt then
    for match in string.gmatch(pitchTxt, '([^,|]+)') do
      pitches[i-1] = tonumber(match)
      stepNames[i-1] = string.sub(stepTxt, 2*i-1, 2*i)
      i=i+1
    end
    local octaveStep = tonumber(octaveTxt)
    return self:setTuningFromData(name, pitches, stepNames, octaveStep)
  end
  return false
end


function microtuning:areEqualTunings(pitches1, pitches2)
  if #pitches1 ~= #pitches2 then
    return false
  end
  for i=0,#pitches1 do
    if pitches1[i] ~= pitches2[i] then return false end
  end
  return true
end

function microtuning:setTuningFromData(name,pitches,stepNames,octaveStep)
  local idx, extant = self:findTuning(name)

  if extant and self:areEqualTunings(extant.pitches, pitches) then
    self.activeTuning = extant
    return idx
  end
    
  for i,v in pairs(self.tunings) do
    if self:areEqualTunings(v.pitches, pitches) then
      self.activeTuning = v
      return i
    end
  end

  local newTuning = { pitches = pitches, stepNames =
                        stepNames, octaveStep = octaveStep }

  if not extant then
    newTuning.name = name
  end
  
  for i = 0, 99 do
    local name = string.format('USR%02d', i)
    if not self:findTuning(name) then
      newTuning.name = name
    end
  end

  if newTuning.name then
    table.insert(self.tunings, newTuning)
    self.activeTuning = newTuning
    return #self.tunings
  end
  return false
end

function microtuning:getTuningName()
  return self.activeTuning.name
end

function microtuning:midiPitchToStep(midiNote, detune)
  local pitches = self.activeTuning.pitches

  local octave = math.floor((midiNote - 9) / 12)
  local cents = ((midiNote - 9) % 12) * 100 + detune
  if (cents < 0) then
    cents = cents + 1200
    octave = octave - 1
  end

  local distance = 1200
  local step = 0
  for i=0,#pitches,1 do
    if (math.abs(cents - pitches[i]) < distance) then
      distance = math.abs(cents - pitches[i])
      step = i
    end
  end

  return step, octave
end

function microtuning:stepToMIDIPitch(step, octave)
  local pitches = self.activeTuning.pitches
  while step < 0 do
    step = step + #pitches + 1
    octave = octave - 1
  end
  while step > #pitches do
    step = step - #pitches - 1
    octave = octave + 1
  end

  local cents = pitches[step]
  local midiStep = math.floor((cents + 49) / 100)
  local detune = cents - midiStep * 100
  local midiNote = midiStep + (octave * 12) + 9

  if (midiNote < 0) then
    detune = detune + 100 * midiNote
    midiNote = 0
  elseif (midiNote > 127) then
    detune = detune + 100 * (midiNote - 127)
    midiNote = 127
  end

  return midiNote, detune
end

function microtuning:stepToText(step, octave)
  if (step < self.activeTuning.octaveStep) then
    octave = octave - 1
  end
  return self.activeTuning.stepNames[step] .. (octave < 0 and "M" or tostring(octave))
end

function microtuning:normaliseDetune(midiNote, detune)
  local step, octave = self:midiPitchToStep(midiNote, detune)
  local newNote, newDetune = self:stepToMIDIPitch(step, octave)

  return newNote, newDetune
end

function microtuning:ccToCents(msg2, msg3)
  return math.floor( (((msg3*128 + msg2) - 8192) * tracker.pbRange / 81.92)+0.5 )
end

function microtuning:centsToCC(cents)
  local pbvalue = math.floor((cents * 81.92 / tracker.pbRange) + 8192.5)
  pbvalue = pbvalue < 0 and 0 or (pbvalue > 16383 and 16838 or pbvalue)
  msg2 = pbvalue & 0x7F
  msg3 = (pbvalue >> 7) & 0x7F

  return msg2, msg3
end

function microtuning:initialize()
  tracker.currentTuning = self:setDefaultTuning()
end
