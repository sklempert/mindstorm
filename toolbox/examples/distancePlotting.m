% This script has two purposes:
%   * Plotting distance to ultrasonic sensor (for fun and as an example)
%   * Analyse runtime of sensor readings (comment out marked part of code to get useful
%   results)
% Necessary:
%   * USB-connection
%   * UltraSonic-Sensor at Port 4
clear all

b = EV3('debug', 0);
b.connect('usb');

s = b.sensor4;
if s.type ~= DeviceType.UltraSonic
    error('Connect US-sensor to port 4');
end
s.mode = DeviceMode.UltraSonic.DistCM;

readings = [];
time = [];

tic
hold on;
while toc < 20
    readings = [readings, s.value];
    time = [time, toc];
    
    %% Plotting
    % Should be commented out if you analyse latency of sensor readings
    plot(time, readings)
    drawnow
end
hold off;

fprintf('\nSensor readings per sec: %f\n', length(readings)/time(length(time)));

b.disconnect();

clear all

%% Results
%   Bluetooth
% debug=2, sensor-typ-kontrolle an: 7.5 Readings/sec   % worst case
% debug=1, sensor-typ-kontrolle an: 9.3 readings/sec   
% debug=0, sensor-typ-kontrolle an: 9.6 readings/sec 
% debug=0, sensor-typ-kontrolle aus: 16.5 readings/sec 
% debug=0, sensor-typ-kontrolle aus, plotting aus: 22.5 readings/sec   % best case
% debug=0, sensor-typ-kontrolle an, plotting aus: 10
%   USB
% debug=2, sensor-typ-kontrolle an: 16.5 readings/sec   % worst case 
% debug=0, sensor-typ-kontrolle aus, plotting aus: 100 readings/sec   % best case
%
%       -> NOTIZ AN MICH: TYP KONTROLLE ÜBERDENKEN
