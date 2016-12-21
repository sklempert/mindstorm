function [ ] = ms_start(motor, power, limit)
  motor.brakeMode = 'Brake';
  motor.limitValue = limit;
  motor.limitMode = 'Tacho';
  motor.power = power;

%  if limit ~= 0
%      motor.resetTachoCount();
%  end
  
  while motor.isRunning == 0 && motor.currentSpeed == 0
      motor.start();
  end
  
%  if limit ~= 0
%      while abs(motor.tachoCount) < limit
%      end
%      motor.power=0;
%      motor.start();
%      ms_stop(motor);
%  end
      
  
  % isRunning = motor.isRunning
  % currentSpeed = motor.currentSpeed
end
