function [ ] = ms_start(motor, power, limit)
  motor.power = power;
  motor.brakeMode = 'Brake';
  motor.limitValue = limit;
  motor.limitMode = 'Tacho';

  while motor.isRunning == 0 && motor.currentSpeed == 0
      motor.start();
  end
  isRunning = motor.isRunning
  currentSpeed = motor.currentSpeed
end
