function [ ] = mindstorm_scan()
global scanMotor;
global scanSensor;
global cSensor;
global rotateMotor;
stop(scanMotor);
ms_scan_reset_position(scanMotor, scanSensor);

pause(0.1);
ms_start(scanMotor, -50, 3*360+120);
% Start Position ist jetzt erreicht
colorSeitenmitte1 = readLightIntensity(cSensor, 'reflected')
pause(1);
ms_start(rotateMotor, -70, 3*360-35);
colorSeitenmitte2 = readLightIntensity(cSensor, 'reflected')
pause(1);
ms_start(rotateMotor, -70, 3*360-35);
colorSeitenmitte3 = readLightIntensity(cSensor, 'reflected')
pause(1);
ms_start(rotateMotor, -70, 3*360-35);
colorSeitenmitte4 = readLightIntensity(cSensor, 'reflected')
pause(1);
ms_start(rotateMotor, -70, 3*360-35);
colorSeitenmitte1b = readLightIntensity(cSensor, 'reflected')

ms_scan_reset_position(scanMotor, scanSensor);

% 
% ms_start(scanMotor, 50, 600 + 360);
% color2 = readLightIntensity(cSensor, 'reflected')
% pause(5);
% 
% ms_start(rotateMotor, -50, 3*360+90);
% %% ms_start(scanMotor, 50, 400);
% color3 = readLightIntensity(cSensor, 'reflected')
% pause(5);
% % 
% % ms_start(rotateMotor, -50, 220);
% % ms_start(scanMotor, -50, 400);
% % color3 = readLightIntensity(cSensor, 'reflected')

end

