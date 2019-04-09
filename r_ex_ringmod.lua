-- RINGMOD
--
-- Ring modulation example
--

local Formatters = require 'formatters'
local R = require 'r/lib/r'

engine.name = 'R'

function init()
  engine.new("Osc1FG", "FreqGate") -- TODO: awkward, fix in osc
  engine.new("Osc1", "MultiOsc")
  engine.new("Osc2FG", "FreqGate") -- TODO: awkward, fix in osc
  engine.new("Osc2", "MultiOsc")
  engine.new("RingMod", "RingMod")
  engine.new("SoundOut", "SoundOut")

  engine.set("Osc1.FM", 1)
  engine.set("Osc2.FM", 1)

  engine.connect("Osc1FG/Frequency", "Osc1/FM")
  engine.connect("Osc1/Sine", "RingMod/In")
  engine.connect("Osc2FG/Frequency", "Osc2/FM")
  engine.connect("Osc2/Sine", "RingMod/Carrier")

  engine.connect("RingMod/Out", "SoundOut/Left")
  engine.connect("RingMod/Out", "SoundOut/Right")

  local osc1_freq_spec = R.specs.FreqGate.Frequency:copy()
  osc1_freq_spec.default = 42

  params:add {
    type="control",
    id="osc1_freq",
    name="Osc1 Freq",
    controlspec=osc1_freq_spec,
    formatter=Formatters.round(0.001),
    action=function(value) engine.set("Osc1FG.Frequency", value) end
  }

  local osc2_freq_spec = R.specs.FreqGate.Frequency:copy()
  osc2_freq_spec.default = 704

  params:add {
    type="control",
    id="osc2_freq",
    name="Osc2 Freq",
    controlspec=osc2_freq_spec,
    formatter=Formatters.round(0.001),
    action=function(value) engine.set("Osc2FG.Frequency", value) end
  }

  --[[
  params:add {
    type="control",
    id="osc1_range",
    name="Osc1.Range",
    controlspec=R.specs.MultiOsc.Range,
  }

  params:add {
    type="control",
    id="osc1_tune",
    name="Osc1.Tune",
    controlspec=R.specs.MultiOsc.Tune,
  }

  params:add {
    type="control",
    id="osc2_range",
    name="Osc2.Range",
    controlspec=R.specs.MultiOsc.Range,
  }

  params:add {
    type="control",
    id="osc2_tune",
    name="Osc2.Tune",
    controlspec=R.specs.MultiOsc.Tune,
  }
  ]]

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
