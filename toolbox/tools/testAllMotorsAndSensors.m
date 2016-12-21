function [] = testAllMotorsAndSensors()

% Connect the Brick via USB
clear all;
b=EV3;
connected = 0;
i=0;
while connected == 0
    disp(sprintf('Please connect the brick via USB and press any key to continue.\n\n'));
    pause();
    try b.connect('usb')
    catch disp('Connection failed, try again...')
        %discard errors
    end;
    connected = b.isConnected();
    i=i+1;
    if i==3
        error('USB connection failed. You can not continue the test. Restart Matlab and the brick, then try again. If the error occurs again, please contact us.');
    end;
end;
 
% Connect motors and sensors to ports
connectWires();

% Test motors (USB)
USBresultMotor = motorTest(b, 'USB');

if USBresultMotor == 0
    warning('The USB motor test failed. Please contact us.');
end;

% Test sensors (USB)
USBresultSensor = sensorTest(b, 'USB');

if USBresultSensor == 0
    warning('The USB sensor test failed. Please contact us.');
end;

if (USBresultMotor == 1) && (USBresultSensor == 1)
    disp(sprintf('\n<strong>--------------All USB tests passed successfully---------------</strong>\n'));
else
    disp(sprintf('\n<strong>-----End of USB tests. Some tests failed, notice the warnings.-----</strong>\n'));
end;

b.disconnect;
pause(1);

%Connect the Brick via BT
b=EV3;
connected = 0;
i=0;
while connected==0
    disp(sprintf('Please remove the USB wire and use btconnect in the terminal, so that the brick can be\nautomatically connected via BT and press any key to continue.\n\n'));
    pause();
    try b.connect('bt', 'serPort', '/dev/rfcomm0')
    catch all
    end;
    try b.connect('bt', 'serPort', '/dev/rfcomm1')
    catch all
    end;
    pause(1);
    connected = b.isConnected();
    i=i+1;
    if i==3
        error('BT connection failed. You can not continue the test. Did you connect the brick with btconnect? If no, start btconnect in the terminal. If yes, restart Matlab and try again. If the error occurs again, please contact us.');
    end;
end;

%Test motors (BT)
BTresultMotor = motorTest(b, 'BT');

if BTresultMotor == 0
    warning('The BT motor test failed. Please contact us.');
end;

%Test sensors (BT)
BTresultSensor = sensorTest(b, 'BT');

if BTresultSensor == 0
    warning('The BT sensor test failed. Please contact us.');
end;

if (BTresultMotor == 1) && (BTresultSensor == 1)
    disp(sprintf('\n<strong>---------------All BT tests passed successfully---------------</strong>\n'));
else
    disp(sprintf('\n<strong>-----End of BT tests. Some tests failed, notice the warnings.-----</strong>\n'));
end;

disp(sprintf('\n------------------------End of the test------------------------\n'));
clear all;

end

