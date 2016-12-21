function testConnSpeed(ioType, serPort, it, withResponse)
%testConnSpeed Test connection speed in various modi.
% This is a test function to test how many packets can be sent and received with bluetooth and
% usb. MotorB will run at power 10 for 15 seconds. In 'withResponse'-mode, the isRunning() on
% the brick is polled, therefore on every time step a packet is sent and received. With
% 'withResponse'-mode turned off, a resetTachoCount is sent on each iteration (without waiting
% for a reply).
%
% * ioType: 'bt' or 'usb'
% * serPort: 0 if 'usb', else '/dev/rfcommx'
% * it: number if iterations
% * withResponse: 0 or 1 

    b = EV3();
    if strcmp(ioType, 'bt')
        b.connect(ioType, 'serPort', serPort);
    else 
        b.connect('usb');
    end
    
    m = b.motorB;
    m.setProperties('power', 10, 'limitMode', 'Time', 'limitValue', 15000);
    m.resetTachoCount();
    
    if withResponse
        for i = 0:it-1
            m.start();
            t = 0;
            tic;
            pause(0.5);
            while m.isRunning
                t = [t; toc]; 
            end

            fprintf('Iteration %d\n', i+1);
            fprintf('\tTime: %fs\n', t(length(t)));
            fprintf('\tReceived packets: %d\n', length(t));
            fprintf('\tPackets per sec: %f\n', length(t)/t(length(t)));
            pause(0.5);
        end
    else
        for i = 0:it-1
            m.start();
            t = 0;
            tic;
            while t < 15
                m.resetTachoCount(); % Has no effect but at least sends a packet 
                t = [t; toc]; 
            end

            fprintf('Iteration %d\n', i+1);
            fprintf('\tTime: %fs\n', t(length(t)));
            fprintf('\tSent packets: %d\n', length(t));
            fprintf('\tPackets per sec: %f\n', length(t)/t(length(t)));
            pause(0.5);
        end
    end
    b.disconnect();
    b.delete();

end