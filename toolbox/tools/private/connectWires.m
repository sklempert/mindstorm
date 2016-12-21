function [] = connectWires()
%Connect motors to ports
disp(sprintf('Please connect middle motor to port A, large motors to port B and C. Then press any key to continue.\n\n'));
pause();

%Connect sensors to ports
disp(sprintf('Please connect touch sensor to port 1, gyro sensor to port 2, color sensor to port 3,\nultrasonic sensor to port 4. Then press any key to continue.\n\n'));
pause();

end

