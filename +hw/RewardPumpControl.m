classdef RewardPumpControl < hw.ControlSignalGenerator & handle
    % Class for handling delivery of water reward via a syringe pump.
    % The pump is powered by a stepper motor. A single step of the motor is
    % made when a pulse is delivered to the driver board.
    % Based on a 60mL syringe, 400-step motor and 16x microstep multiplier
    % on the driver board, 2mm lead screw, the volume of water delivered on
    % a single step is ~0.17uL. Therefore you can obtain multiples of this
    % by delivering multiple steps to the stepper motor.
    
    properties
        microLitresPerMicroStep=0.17; %Amount of water delivered by one microstep of the motor
    end
  
  methods
      function obj = RewardPumpControl()
          obj.DefaultValue = 0;
      end
    
      function samples = waveform(obj, ~, microLitres)
          %Function which outputs the set of digital out voltage pulses
          %required to output the water volume
          assert(mod(microLitres,obj.microLitresPerMicroStep)==0,...
              'Requested reward size %0.2fuL is not a multiple of the microLitre resolution %0.2fuL',...
              microLitres,obj.microLitresPerMicroStep);
          
          numSteps = microLitres/obj.microLitresPerMicroStep;
          
          samples = repmat([0;1],numSteps,1);
          samples = [samples; 0];
      end
  end
end