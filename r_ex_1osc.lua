-- 1OSC
--
-- Dynamic re-patching example
--
-- Oscillator thru filter: pulse
-- width and filter cutoff is
-- modulated by an LFO.
--

local Option = require 'params/option'
local Trigger = require 'params/trigger'
local Formatters = require 'formatters'
local R = require 'r/lib/r'

engine.name = 'R'

function init()
  engine.new("Base", "FreqGate")
  engine.new("LFO", "MultiLFO")
  engine.new("Osc", "MultiOsc")
  engine.new("Filter", "MMFilter")
  engine.new("SoundOut", "SoundOut")

  engine.connect("Base/Frequency", "Osc/FM")
  engine.set("Osc.FM", 1)

  local current_lfo_wave
  local lfo_wave_option = Option.new(
    "lfo_wave",
    "LFO/Wave",
    {"InvSaw", "Saw", "Sine", "Triangle", "Pulse"}
  )
  params:add {
    param=lfo_wave_option,
    action=function(value)
      if current_lfo_wave then
        engine.disconnect("LFO/"..current_lfo_wave, "Osc/PWM")
        engine.disconnect("LFO/"..current_lfo_wave, "Filter/FM")
      end
      if not current_lfo_wave then
        current_lfo_wave = "InvSaw" -- default
      end
      current_lfo_wave = lfo_wave_option.options[value]
      engine.connect("LFO/"..current_lfo_wave, "Osc/PWM")
      engine.connect("LFO/"..current_lfo_wave, "Filter/FM")
    end
  }

  local lfo_frequency_spec = R.specs.MultiLFO.Frequency:copy()
  lfo_frequency_spec.default = 0.2

  params:add {
    type="control",
    id="lfo_frequency",
    name="LFO Frequency",
    controlspec=lfo_frequency_spec,
    formatter=Formatters.round(0.001),
    action=function(value) engine.set("LFO.Frequency", value) end
  }

  local reset_trigger = Trigger.new("lfo_reset", "LFO Reset")
  reset_trigger.action = function()
    engine.set("LFO.Reset", 1)
    engine.set("LFO.Reset", 0)
  end
  params:add {
    param = reset_trigger
  }
    
  local current_osc_wave
  local osc_wave_option = Option.new(
    "osc_wave",
    "Osc/Wave",
    {"Sine", "Triangle", "Saw", "Pulse"},
    4
  )
  params:add {
    param=osc_wave_option,
    action=function(value)
      if current_osc_wave then
        engine.disconnect("Osc/"..current_osc_wave, "Filter/In")
      end
      if not current_osc_wave then
        current_osc_wave = "Pulse" -- default
      end
      current_osc_wave = osc_wave_option.options[value]
      engine.connect("Osc/"..current_osc_wave, "Filter/In")
    end
  }

  params:add {
    type="control",
    id="base_freq",
    name="Osc Frequency",
    controlspec=R.specs.FreqGate.Frequency,
    formatter=Formatters.round(0.001),
    action=function(value) engine.set("Base.Frequency", value) end
  }

  params:add {
    type="control",
    id="osc_pulsewidth",
    name="Osc PulseWidth",
    controlspec=R.specs.MultiOsc.PulseWidth,
    formatter=Formatters.percentage,
    action=function(value) engine.set("Osc.PulseWidth", value) end
  }

  local lfo_to_osc_pwm_spec = R.specs.MultiOsc.PWM:copy()
  lfo_to_osc_pwm_spec.default = 0.2

  params:add {
    type="control",
    id="lfo_to_osc_pwm",
    name="LFO > Osc PWM",
    controlspec=lfo_to_osc_pwm_spec,
    formatter=Formatters.percentage,
    action=function(value) engine.set("Osc.PWM", value) end
  }

  local current_filter_type
  local filter_type_option = Option.new(
    "filter_tyoe",
    "Filter/Type",
    {"Lowpass", "Highpass", "Bandpass", "Notch"}
  )
  params:add {
    param=filter_type_option,
    action=function(value)
      if current_filter_type then
        engine.disconnect("Filter/"..current_filter_type, "SoundOut/Left")
        engine.disconnect("Filter/"..current_filter_type, "SoundOut/Right")
      end
      if not current_filter_type then
        current_filter_type = "Lowpass" -- default
      end
      current_filter_type = filter_type_option.options[value]
      engine.connect("Filter/"..current_filter_type, "SoundOut/Left")
      engine.connect("Filter/"..current_filter_type, "SoundOut/Right")
    end
  }

  local filter_frequency_spec = R.specs.MMFilter.Frequency:copy()
  filter_frequency_spec.default = 2000

  params:add {
    type="control",
    id="filter_frequency",
    name="Filter Frequency",
    controlspec=filter_frequency_spec,
    action=function(value) engine.set("Filter.Frequency", value) end
  }

  local filter_resonance_spec = R.specs.MMFilter.Resonance:copy()
  filter_resonance_spec.default = 0.4

  params:add {
    type="control",
    id="filter_resonance",
    name="Filter Resonance",
    controlspec=filter_resonance_spec,
    formatter=Formatters.percentage,
    action=function(value) engine.set("Filter.Resonance", value) end
  }

  local lfo_to_filter_fm_spec = R.specs.MMFilter.FM:copy()
  lfo_to_filter_fm_spec.default = 0.1

  params:add {
    type="control",
    id="lfo_to_filter_fm",
    name="LFO > Filter FM",
    controlspec=lfo_to_filter_fm_spec,
    formatter=Formatters.percentage,
    action=function(value) engine.set("Filter.FM", value) end
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
