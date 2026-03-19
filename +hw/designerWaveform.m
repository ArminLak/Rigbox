classdef designerWaveform < hw.ControlSignalGenerator
  % HW.DESIGNERWAVEFORM
  % Plays one waveform selected from a library of custom waveforms.
  %
  % Each waveform in Waveforms is a vector of desired LED power values
  % over consecutive output samples. These power values are converted to
  % analog volts using Calibration before being sent to the LED driver.
  %
  % Task sends a single numeric command:
  %   command = waveform index (1-based)
  %
  % Example:
  %   obj.Waveforms = {
  %     [0 0.2 0.5 1 0.5 0.2 0], ...
  %     [0 1 0 1 0 1 0], ...
  %     linspace(0,1,100)
  %   };
  %
  % EN & ChatGPT 18 03 2026

  properties
    ClosedValue (1,1) double = 0
    EndPaddingSeconds (1,1) double = 3

    % Safety limits
    MinVoltage (1,1) double = 0
    MaxVoltage (1,1) double = 5
    Clamp (1,1) logical = true

    % Cell array of waveform vectors.
    % Each vector is interpreted as power values at consecutive samples.
    Waveforms cell = {}

    % Calibration struct: vectors Power and Volts
    Calibration struct = struct('Power', [], 'Volts', [], 'PowerUnits', '')
  end

  methods
    function obj = designerWaveform(waveforms, calibration)
      obj.DefaultValue = obj.ClosedValue;

      if nargin >= 1 && ~isempty(waveforms)
        obj.Waveforms = waveforms;
      end

      if nargin >= 2 && ~isempty(calibration)
        obj.Calibration = calibration;
      end
    end

    function samples = waveform(obj, sampleRate, command) %#ok<INUSD>
      assert(~isempty(obj.Waveforms), ...
        'designerWaveform: Waveforms is empty. Define waveform library in hardware.');

      validateattributes(command, {'numeric'}, {'vector','real','finite','nonempty'});
      command = command(:); % force column vector

      % Backward-compatible parsing:
      %   command = idx
      %   command = [idx; scale]
      idx = command(1);

      if numel(command) >= 2
        scale = command(2);
      else
        scale = 1;
      end

      validateattributes(idx, {'numeric'}, {'scalar','real','finite','>=',1});
      validateattributes(scale, {'numeric'}, {'scalar','real','finite','>=',0});

      idx = floor(idx);

      assert(idx >= 1 && idx <= numel(obj.Waveforms), ...
        'designerWaveform: waveform index %d out of range 1..%d.', ...
        idx, numel(obj.Waveforms));

      pwr = obj.Waveforms{idx};
      validateattributes(pwr, {'numeric'}, {'vector','real','finite','nonempty'});
      pwr = pwr(:);

      % Apply linear amplitude scaling in power-space
      pwr = scale .* pwr;

      % Convert per-sample power values to volts
      samples = obj.power2volts(pwr);

      % Keep baseline for zero-or-below power
      samples(pwr <= 0) = obj.ClosedValue;

      % Apply voltage safety limits
      samples = obj.applyLimits(samples);

      % Ensure return to baseline
      padSamples = round(obj.EndPaddingSeconds * sampleRate);
      samples = [samples; repmat(obj.ClosedValue, padSamples, 1)];
    end
  end

  methods (Access = private)
    function v = power2volts(obj, pwr)
      P = []; V = [];
      if isfield(obj.Calibration, 'Power'); P = obj.Calibration.Power; end
      if isfield(obj.Calibration, 'Volts'); V = obj.Calibration.Volts; end

      if ~isempty(P) && ~isempty(V)
        P = P(:);
        V = V(:);

        if numel(P) == 1
          % Single-point calibration
          if abs(P(1)) < eps
            error('designerWaveform: invalid single-point calibration power value.');
          end
          v = (pwr ./ P(1)) * V(1);
        else
          v = interp1(P, V, pwr, 'linear', 'extrap');
        end
      else
        % Fallback: treat waveform values as volts directly
        v = pwr;
      end
    end

    function v = applyLimits(obj, v)
      if obj.Clamp
        v = min(max(v, obj.MinVoltage), obj.MaxVoltage);
      else
        assert(all(v >= obj.MinVoltage & v <= obj.MaxVoltage), ...
          'designerWaveform: voltage out of range [%.3f, %.3f].', ...
          obj.MinVoltage, obj.MaxVoltage);
      end
    end
  end
end
