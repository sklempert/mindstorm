% In order to generally examine the runtime-distribution, start this script
% with the 'Run and Time'-Button in MATLAB. 
% Necessary:
%   * USB-connection
%   * Motor at Port A
clear all

b = EV3();
b.connect('usb');
ma = b.motorA;
ma.setProperties('Power', 50, 'LimitValue', 2000);

t = 0;
flag = 0;
tacho = 0;

tic;
ma.start();
while(toc < 7)
    flag = [flag, ma.isRunning];
    tacho = [tacho, ma.tachoCount];
end

clear all