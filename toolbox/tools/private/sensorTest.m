function ret = sensorTest(EV3, mode)

ret = 0;

%Start test
disp(sprintf(['--------------------------------------------------------------\nStart sensor test ', mode]));

%Test sensor 1
if EV3.sensor1.type == DeviceType.Touch
    answer1 = 1;
else
    answer1 = 0;
end;
%Test sensor 2
if EV3.sensor2.type == DeviceType.Gyro
    answer2 = 1;
else
    answer2 = 0;
end;
%Test sensor 3
if EV3.sensor3.type == DeviceType.Color
    answer3 = 1;
else
    answer3 = 0;
end;

%Test sensor 4
if EV3.sensor4.type == DeviceType.UltraSonic
    answer4 = 1;
else
    answer4 = 0;
end;

%Warnings for defect motors
if answer1 == 0
    warning('Test for sensor 1 failed. Expected touch sensor.');
end;

if answer2 == 0
    warning('Test for sensor 2 failed. Expected gyro sensor.');
end;

if answer3 == 0
    warning('Test for sensor 3 failed. Expected color sensor.');
end;

if answer4 == 0
    warning('Test for sensor 4 failed. Expected ultrasonic sensor');
end;

if answer1==1 && answer2==1 && answer3==1 && answer4==1
    disp(sprintf('All sensors work correctly.\n'));
    ret = 1;
end;

end

