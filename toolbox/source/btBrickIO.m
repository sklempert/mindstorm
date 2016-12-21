%btBrickIO Bluetooth interface between MATLAB and the brick
%
% Methods::
%
%  btBrickIO    Constructor, initialises and opens the bluetooth connection
%  delete       Destructor, closes the bluetooth connection
%
%  open         Open a bluetooth connection to the brick
%  close        Close the bluetooth connection to the brick
%  read         Read data from the brick through bluetooth
%  write        Write data to the brick through bluetooth
%
% Example::
%           btbrick = btBrickIO(1,'/dev/rfcomm0')
%
% Notes::
% - Connects to the bluetooth module on the host through a serial
% connection. Hence be sure that a serial connection to the bluetooth
% module can be made. Also be sure that the bluetooth module can be paired
% to the brick before MATLAB is opened.
% - Works under mac and potentially linux (have yet to find a suitable
% bluetooth device that can pair with the brick under linux).
% - Does not work under windows (will need to either virtualise the serial
% bluetooth port or use the instrumentation and control toolbox BrickIO
% version).

classdef btBrickIO < BrickIO
    properties
        % debug input
        debug = 0;
        % bluetooth serial port
        serialPort = '/dev/rfcomm0'
    end
    
    properties (Access = 'protected')
        % connection handle
        handle
    end 
    
    methods
        function brickIO = btBrickIO(debug,serialPort)
            %btBrickIO.btBrickIO Create a btBrickIO object
            %
            % btbrick = btBrickIO(debug,serialPort) is an object which
            % initialises and opens a bluetooth connection between MATLAB
            % and the brick using serial functions.
            %
            % Notes::
            % - debug is a flag specifying output printing (0 or 1).
            
            if nargin > 1
                brickIO.debug = debug;
                brickIO.serialPort = serialPort;
            end
            
            if brickIO.debug > 0
                fprintf('btBrickIO init\n');
            end
            
            % Set the connection handle
            try
                brickIO.handle = serial(brickIO.serialPort);
            catch ME
                if ~isempty(strfind(ME.identifier, 'invalidPORT'))
                    % Throw a clean InvalidSerialPort to avoid confusion in upper layers
                    msg = 'Couldn''t connect to BT-device because given serial port is invalid.';
                    id = [ID(), ':', 'InvalidSerialPort'];
                    throw(MException(id, msg));
                else
                    % Throw combined error because error did not happen due to known reasons...
                    msg = 'Unknown error occurred while creating serial-port-object for BT connection.';
                    id = [ID(), ':', 'UnknownError'];
                    newException = MException(id, msg);
                    newException = addCause(newException, ME);
                    throw(newException);
                end
            end
            
            % Open the connection handle
            brickIO.open;
        end
        
        function delete(brickIO)
            %btBrickIO.delete Delete the btBrickIO object
            %
            % delete(brickIO) closes the bluetooth connection handle
            
            if brickIO.debug > 0
                fprintf('btBrickIO delete\n');
            end
            
            % Disconnect
            try
                brickIO.close;
            catch
                % Connection already closed (probably due to an error) - do nothing
            end
        end
        
        function open(brickIO)
            %btBrickIO.open Open the btBrickIO object
            %
            % btBrickIO.open() opens the bluetooth connection to the brick
            % using fopen.
            
            if brickIO.debug > 0
                fprintf('btBrickIO open\n');
            end
            
            % Open the bt handle
            try
                fopen(brickIO.handle);
            catch ME 
                if strcmp(ME.identifier, 'MATLAB:serial:fopen:opfailed')
                    % Throw only clean CommError to avoid confusion in upper layers
                    msg = 'Failed to open connection to Brick via Bluetooth.';
                    id = [ID(), ':', 'CommError'];
                    throw(MException(id, msg));
                else
                    % Throw combined error because error did not happen due to communication
                    % failure
                    msg = 'Unknown error occurred while connecting to the Brick via Bluetooth.';
                    id = [ID(), ':', 'UnknownError'];
                    newException = MException(id, msg);
                    newException = addCause(newException, ME);
                    throw(newException);
                end
            end
        end

        function close(brickIO)
            %btBrickIO.close Close the btBrickIO object
            %
            % btBrickIO.close() closes the bluetooth connection the brick
            % using fclose.
            
            if brickIO.debug > 0
                fprintf('btBrickIO close\n');
            end 
            
            try
                % Close the close handle
                fclose(brickIO.handle);
            catch ME
                % Throw combined error because error did not happen due to communication
                % failure
                msg = 'Unknown error occurred while disconnecting from the Brick via Bluetooth.';
                id = [ID(), ':', 'UnknownError'];
                newException = MException(id, msg);
                newException = addCause(newException, ME);
                throw(newException);
            end
        end
        
        function rmsg = read(brickIO)
            %btBrickIO.read Read data from the btBrickIO object
            %
            % rmsg = btBrickIO.read() reads data from the brick through
            % bluetooth via fread and returns the data in uint8 format.
            
            if brickIO.debug > 0
                fprintf('btBrickIO read\n');
            end 
            
            try
                % Get the number of bytes to be read from the bt handle
                nLength = fread(brickIO.handle,2);

                % Read the remaining bytes
                rmsg = fread(brickIO.handle,double(typecast(uint8(nLength),'uint16')));
            catch ME
                if strcmp(ME.identifier, 'MATLAB:serial:fread:opfailed')
                    % Throw only clean CommError to avoid confusion in upper layers
                    msg = 'Failed to read data from Brick via Bluetooth.';
                    id = [ID(), ':', 'CommError'];
                    throw(MException(id, msg));
                else
                    % Throw combined error because error did not happen due to known reasons...
                    msg = 'Unknown error occurred while reading data from the Brick via BT.';
                    id = [ID(), ':', 'UnknownError'];
                    newException = MException(id, msg);
                    newException = addCause(newException, ME);
                    throw(newException);
                end
            end
            
            % Append the reply size to the return message
            rmsg = uint8([nLength' rmsg']);
        end
        
        function write(brickIO,wmsg)
            %btBrickIO.write Write data to the btBrickIO object
            %
            % btBrickIO.write(wmsg) writes data to the brick through
            % bluetooth.
            %
            % Notes::
            % - wmsg is the data to be written to the brick via bluetooth
            % in uint8 format.
            
            if brickIO.debug > 0
                fprintf('btBrickIO write\n');
            end 
            
            try
                % Write to the bluetooth handle
                fwrite(brickIO.handle,wmsg);
            catch ME
                if strcmp(ME.identifier, 'MATLAB:serial:fwrite:opfailed')
                    % Throw only clean CommError to avoid confusion in upper layers
                    msg = 'Failed to send data to Brick via Bluetooth.';
                    id = [ID(), ':', 'CommError'];
                    throw(MException(id, msg));
                else
                    % Throw combined error because error did not happen due to known reasons...
                    msg = 'Unknown error occurred while sending data to the Brick via BT.';
                    id = [ID(), ':', 'UnknownError'];
                    newException = MException(id, msg);
                    newException = addCause(newException, ME);
                    throw(newException);
                end
            end
        end
    end 
end
