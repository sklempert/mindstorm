function [ ] = mindstorm_scan()
global brickObj;

ms_scan_reset_position(brickObj);

sm = brickObj.motorD;
pause(1);
ms_start(sm, -50, 50);
% sm.waitFor();

end

