-- FM
--
-- FM example
--
-- TODO: separate linear FM input

local Formatters = require 'formatters'
local R = require 'r/lib/r'

engine.name = 'R'

function init()
  engine.new("CarrierFG", "FreqGate") -- TODO: awkward, refactor Oscs to use direct freq instead
  engine.new("Carrier", "MultiOsc")
  engine.new("OperatorFG", "FreqGate") -- TODO: awkward, refactor Oscs to use direct freq instead
  engine.new("Operator", "MultiOsc")
  engine.new("SoundOut", "SoundOut")

  engine.set("Carrier.FM", 1)

  engine.connect("CarrierFG/Frequency", "Carrier/FM")
  engine.connect("Carrier/Sine", "Operator/FM")
  engine.connect("OperatorFG/Frequency", "Operator/FM")
  engine.connect("Operator/Sine", "SoundOut/Left")
  engine.connect("Operator/Sine", "SoundOut/Right")

  params:add {
    type="control",
    id="carrier_freq",
    name="Carrier Freq",
    controlspec=R.specs.FreqGate.Frequency,
    formatter=Formatters.round(0.001),
    action=function(value) engine.set("CarrierFG.Frequency", value) end
  }

  local fm_amount_spec = R.specs.MultiOsc.FM:copy()
  fm_amount_spec.default = 0.5

  params:add {
    type="control",
    id="fm_amount",
    name="FM Amount",
    controlspec=fm_amount_spec,
    action=function(value) engine.set("Operator.FM", value) end
  }

  params:add {
    type="control",
    id="operator_freq",
    name="Operator Freq",
    controlspec=R.specs.FreqGate.Frequency,
    formatter=Formatters.round(0.001),
    action=function(value) engine.set("OperatorFG.Frequency", value) end
  }

  params:bang()
end

function redraw()
  screen.clear()
  screen.update()
end

function enc(n, delta)
  if n == 1 then
    mix:delta("output", delta)
  end
end
