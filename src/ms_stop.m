function [ ] = ms_stop(motor)
  stop(motor, 1);
  motor.Speed = 0;
%   motor.stop();
%   while motor.isRunning == 1 || motor.currentSpeed > 0
%       motor.stop();
%       motor.power=0;
%   end
%   isRunning = motor.isRunning
%   currentSpeed = motor.currentSpeed
%   pause(0.1);
end
