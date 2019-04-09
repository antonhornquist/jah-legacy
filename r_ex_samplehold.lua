-- SAMPLEHOLD
--
-- Sample and hold example
--

local Formatters = require 'formatters'
local R = require 'r/lib/r'

engine.name = 'R'

function init()
  engine.new("Noise", "Noise")
  engine.new("LFO", "MultiLFO")
  engine.new("SampleHold", "SampHold")
  engine.new("Osc", "SineOsc")
  engine.new("SoundOut", "SoundOut")

  engine.connect("Noise/Out", "SampleHold/In")
  engine.connect("LFO/Pulse", "SampleHold/Trig")
  engine.connect("SampleHold/Out", "Osc/FM")

  engine.connect("Osc/Out", "SoundOut/Left")
  engine.connect("Osc/Out", "SoundOut/Right")

  engine.set("LFO.Frequency", 8)
  engine.set("Osc.FM", 0.2)

  local osc_fm_spec = R.specs.SineOsc.FM:copy()
  osc_fm_spec.default = 0.3

  params:add {
    type="control",
    id="osc_fm",
    name="Osc.FM",
    controlspec=osc_fm_spec,
    action=function(value) engine.set("Osc.FM", value) end
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
