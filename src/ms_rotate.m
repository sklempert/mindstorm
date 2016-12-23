function [ ] = ms_rotate( )
global swingMotor;
global rotateMotor;

ms_start(swingMotor,30,110);
ms_start(rotateMotor, -30, 3*360+100);
ms_start(rotateMotor, 30, 135);
ms_start(swingMotor,-30,110);

end