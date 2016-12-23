function [  ] = ms_scan_reset_position( scanMotor, scanSensor )

sm = scanMotor;
ss = scanSensor;

if readTouch(ss) == 1
    ms_start(sm, -90, 180);
    ms_start(sm, -90, 0);
    while readTouch(ss) == 1
    end
    ms_stop(sm);
end

ms_start(sm, 50, 0);
while readTouch(ss) == 0
end
ms_stop(sm);

% if ss.value == 1
%     ms_start(sm, -90, 0);
%     while ss.value == 1
%     end
%     ms_stop(sm);
% end
% 
% ms_start(sm, 50, 0);
% while ss.value == 0
% end
% ms_stop(sm);


% sm.speedRegulation = 0;
% sm.limitValue = 0;
% sm.limitMode = 'Tacho';
% sm.brakeMode = 'Brake';
% sm.power = -50;
% 
% 
% sm.debug=1;

% % sm.stop();
% 
% while ((sm.isRunning == 1) || (sm.currentSpeed > 0))
% end
% 
% if (ss.value == 1)
%     sm.start();
%     while (ss.value == 1)
%         %%%% pause(0.0 1);
%     end
%     %%% pause(0.25);
%     sm.stop();
%     % sm.power = 0;
%     % pause(1);
%     %%%% pause(0.2);
% end
% 
% while ((sm.isRunning == 1) || (sm.currentSpeed > 0))
% end
% 
% 
% 
% % Move backward
% % sm.speedRegulation = 1;
% 
% %sm.speedRegulation = 0;
% %sm.limitValue = 0;
% %sm.limitMode = 'Time';
% %sm.brakeMode = 'Brake';
% 
% sm.power = 50;
% pause(0.5);
% % test = 2
% % sm
% %pause(1);
% sm.start();
% % sm.waitFor();
% while (ss.value == 0)
%     pause(0.1);
% end
% % pause(0.5);
% sm.stop();
% %pause(0.5);
% % sm.power=0;
% 
% %while ((sm.isRunning == 1) || (sm.currentSpeed  > 0))
% %    pause(0.1);
% %end
% 
% end
