function [ ] = ms_swing( )
global swingMotor;

ms_start(swingMotor,30,230);
pause(0.5);
ms_start(swingMotor,-30,230);

end

