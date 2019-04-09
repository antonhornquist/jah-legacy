-- Matrix
--
-- Routing signals with 88Matrix
--

local Formatters = require 'formatters'
local R = require 'r/lib/r'
local Grid = require 'grid'

engine.name = 'R'

local grid_device = grid.connect(1)

function init()
  engine.new("FreqGate", "FreqGate")
  engine.new("Osc", "MultiOsc")
  engine.new("LPFilter", "LPFilter")
  engine.new("HPFilter", "HPFilter")
  engine.new("BPFilter", "BPFilter")
  engine.new("BRFilter", "BRFilter")
  engine.new("Matrix", "88Matrix")
  engine.new("SoundOut", "SoundOut")

  engine.set("Osc.FM", 1)

  engine.connect("FreqGate/Frequency", "Osc/FM")
  engine.connect("Osc/Sine", "Matrix/In1")
  engine.connect("Osc/Triangle", "Matrix/In2")
  engine.connect("Osc/Saw", "Matrix/In3")
  engine.connect("Osc/Pulse", "Matrix/In4")
  engine.connect("LPFilter/Out", "Matrix/In5")
  engine.connect("HPFilter/Out", "Matrix/In6")
  engine.connect("BPFilter/Out", "Matrix/In7")
  engine.connect("BRFilter/Out", "Matrix/In8")
  engine.connect("Matrix/Out1", "SoundOut/Left")
  engine.connect("Matrix/Out2", "SoundOut/Right")
  engine.connect("Matrix/Out3", "Osc/FM")
  engine.connect("Matrix/Out4", "Osc/PWM")
  engine.connect("Matrix/Out5", "LPFilter/In")
  engine.connect("Matrix/Out6", "HPFilter/In")
  engine.connect("Matrix/Out7", "BPFilter/In")
  engine.connect("Matrix/Out8", "BRFilter/In")

  params:add {
    type="control",
    id="frequency",
    name="Frequency",
    controlspec=R.specs.FreqGate.Frequency,
    formatter=Formatters.round(0.001),
    action=function(value) engine.set("FreqGate.Frequency", value) end
  }

  params:add {
    type="control",
    id="fm",
    name="Osc FM",
    controlspec=R.specs.MultiOsc.FM,
    formatter=Formatters.percentage,
    action=function(value) engine.set("Osc.FM", value) end
  }

  params:add {
    type="control",
    id="pwm",
    name="Osc PWM",
    controlspec=R.specs.MultiOsc.PWM,
    formatter=Formatters.percentage,
    action=function(value) engine.set("Osc.PWM", value) end
  }

  params:add {
    type="control",
    id="lpfilter_frequency",
    name="LPFilter.Frequency",
    controlspec=R.specs.MMFilter.Frequency,
    action=function(value) engine.set("LPFilter.Frequency", value) end
  }

  params:add {
    type="control",
    id="lpfilter_resonance",
    name="LPFilter.Resonance",
    controlspec=R.specs.MMFilter.Resonance,
    formatter=Formatters.percentage,
    action=function(value) engine.set("LPFilter.Resonance", value) end
  }

  params:add {
    type="control",
    id="hpfilter_frequency",
    name="HPFilter.Frequency",
    controlspec=R.specs.MMFilter.Frequency,
    action=function(value) engine.set("HPFilter.Frequency", value) end
  }

  params:add {
    type="control",
    id="hpfilter_resonance",
    name="HPFilter.Resonance",
    controlspec=R.specs.MMFilter.Resonance,
    formatter=Formatters.percentage,
    action=function(value) engine.set("HPFilter.Resonance", value) end
  }

  params:add {
    type="control",
    id="bpfilter_frequency",
    name="BPFilter.Frequency",
    controlspec=R.specs.MMFilter.Frequency,
    action=function(value) engine.set("BPFilter.Frequency", value) end
  }

  params:add {
    type="control",
    id="bpfilter_resonance",
    name="BPFilter.Resonance",
    controlspec=R.specs.MMFilter.Resonance,
    formatter=Formatters.percentage,
    action=function(value) engine.set("BPFilter.Resonance", value) end
  }

  params:add {
    type="control",
    id="brfilter_frequency",
    name="BRFilter.Frequency",
    controlspec=R.specs.MMFilter.Frequency,
    action=function(value) engine.set("BRFilter.Frequency", value) end
  }

  params:add {
    type="control",
    id="brfilter_resonance",
    name="BRFilter.Resonance",
    controlspec=R.specs.MMFilter.Resonance,
    formatter=Formatters.percentage,
    action=function(value) engine.set("BRFilter.Resonance", value) end
  }

  for input=1,8 do
    for output=1,8 do
      params:add {
        type="control",
        id="gate_"..input.."_"..output,
        name="Matrix Gate "..input.." > "..output,
        controlspec=R.specs['88Matrix']["Gate_"..input.."_"..output],
        action=function(value) engine.set("Matrix.Gate_"..input.."_"..output, value) end
      }
    end
  end

  engine.set("LPFilter.AudioLevel", 1)
  engine.set("HPFilter.AudioLevel", 1)
  engine.set("BPFilter.AudioLevel", 1)
  engine.set("BRFilter.AudioLevel", 1)

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

local function gridkey_event(x, y, s)
  if x < 9 and y < 9 and s == 1 then
    local gate = params:get("gate_"..y.."_"..x)
    if gate == 1 then
      gate = 0
    else
      gate = 1
    end
    params:set("gate_"..y.."_"..x, gate)
    grid_device.led(x, y, gate*15)
    grid_device.refresh()
    redraw()
  end
end

grid_device.key = gridkey_event
