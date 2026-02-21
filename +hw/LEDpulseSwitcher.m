classdef LEDpulseSwitcher < hw.ControlSignalGenerator
  % HW.LEDPULSEPASSSER Pulse Generator based on pulseSwitcher, but takes a
  % power input which determines analog voltage input to LED driver
  %
  % EN & ChatGPT 5.2 29 01 2026
  %
  % Timing (pulseWidth, nPulses, freq) is defined in hardware via ParamsFun
  % Task sends a single numeric command:
  %   - if CommandMode = 'power' (default): command is power, mapped via Calibration
  %   - if CommandMode = 'volts'          : command is volts directly

  properties
    ClosedValue (1,1) double = 0
    EndPaddingSeconds (1,1) double = 3

    % Safety limits
    MinVoltage  (1,1) double = 0
    MaxVoltage  (1,1) double = 5
    Clamp (1,1) logical = true

    % Interpret numeric command as 'power' or 'volts'
    CommandMode (1,:) char = 'power'

    % Calibration struct: vectors Power and Volts
    Calibration struct = struct('Power', [], 'Volts', [], 'PowerUnits', '')

    % ParamsFun(sz) -> [pulseWidthSeconds, nPulses, freqHz]
    ParamsFun
  end

  methods
    function obj = LedPulsePasser(duration, nPulses, freq, calibration)
      obj.DefaultValue = obj.ClosedValue;

      if nargin >= 3 && ~isempty(duration) && ~isempty(nPulses) && ~isempty(freq)
        obj.ParamsFun = @(sz) deal(duration, nPulses, freq); %#ok<NASGU>
      end

      if nargin >= 4 && ~isempty(calibration)
        obj.Calibration = calibration;
      end
    end

    function samples = waveform(obj, sampleRate, command)
      assert(~isempty(obj.ParamsFun), ...
        'LedPulsePasser: ParamsFun is empty. Set timing in hardware.');

      [dt, npulses, f] = obj.ParamsFun(command);

      validateattributes(dt, {'numeric'}, {'scalar','real','finite','>',0});
      validateattributes(npulses, {'numeric'}, {'scalar','real','finite','>=',1});
      validateattributes(f, {'numeric'}, {'scalar','real','finite','>',0});

      npulses = floor(npulses);

      openV = obj.command2volts(command);
      openV = obj.applyLimits(openV);

      wavelength = 1 / f;
      duty = dt / wavelength;
      assert(duty <= (1 + 1e-3), ...
        'Pulse width larger than period (duty=%.3f)', duty);

      duty = min(duty, 1);

      len = npulses * wavelength;
      nsamples = ceil(len * sampleRate);

      % cycles axis
      tt = linspace(0, npulses - 1/sampleRate, nsamples)';

      % 0/1 square wave with given duty cycle
      gate01 = 0.5 * (square(2*pi*tt, 100*duty) + 1);

      % scale to voltage range
      samples = (openV - obj.ClosedValue) .* gate01 + obj.ClosedValue;

      % ensure return to baseline
      padSamples = round(obj.EndPaddingSeconds * sampleRate);
      samples = [samples; repmat(obj.ClosedValue, padSamples, 1)];    end
  end

  methods (Access = private)
    function v = command2volts(obj, command)
      validateattributes(command, {'numeric'}, {'scalar','real','finite'});

      if strcmpi(obj.CommandMode, 'volts')
        v = command;
      else
        v = obj.power2volts(command);
      end

      if strcmpi(obj.CommandMode, 'power') && v <= obj.MinVoltage
        v = obj.ClosedValue;
      end
    end

    function v = power2volts(obj, pwr)
      P = []; V = [];
      if isfield(obj.Calibration, 'Power'); P = obj.Calibration.Power; end
      if isfield(obj.Calibration, 'Volts'); V = obj.Calibration.Volts; end

      if ~isempty(P) && ~isempty(V)
        P = P(:); V = V(:);
        if numel(P) == 1
          % Single-point calibration
          if abs(pwr - P(1)) < eps(max(1,abs(P(1))))
            v = V(1);
          else
            v = (pwr / P(1)) * V(1);
          end
        else
          v = interp1(P, V, pwr, 'linear', 'extrap');
        end
      else
        % fallback: treat power as volts
        v = pwr;
      end
    end

    function v = applyLimits(obj, v)
      if obj.Clamp
        v = min(max(v, obj.MinVoltage), obj.MaxVoltage);
      else
        assert(v >= obj.MinVoltage && v <= obj.MaxVoltage, ...
          'Voltage %.3f out of range [%.3f, %.3f].', ...
          v, obj.MinVoltage, obj.MaxVoltage);
      end
    end
  end
end
