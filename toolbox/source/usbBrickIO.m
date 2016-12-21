%usbBrickIO USB interface between MATLAB and the brick
%
% Methods::
%
%  usbBrickIO    Constructor, initialises and opens the usb connection
%  delete       Destructor, closes the usb connection
%
%  open         Open a usb connection to the brick
%  close        Close the usb connection to the brick
%  read         Read data from the brick through usb
%  write        Write data to the brick through usb
%
% Example::
%           usbbrick = usbBrickIO()
%
% Notes::
% - Uses the hid library implementation in hidapi.m

classdef usbBrickIO < BrickIO
    properties
        % debug input
        debug = 0;
        % vendor ID (EV3 = 0x0694)
        vendorID = 1684;
        % product ID (EV3 = 0x0005)
        productID = 5;
        % read buffer size
        nReadBuffer = 1024;
        % write buffer size
        nWriteBuffer = 1024;
    end
    
    properties (Access = 'protected')
        % connection handle
        handle
    end 
    
    methods
        function brickIO = usbBrickIO(varargin)
            %usbBrickIO.usbBrickIO Create a usbBrickIO object
            %
            % usbbrick = usbBrickIO(varargin) is an object which
            % initialises a usb connection between MATLAB and the brick
            % using hidapi.m.
            % 
            % Notes::
            % - Can take one parameter debug which is a flag specifying
            % output printing (0 or 1).
            
            if nargin == 0
                brickIO.debug = 0;
            else
                brickIO.debug = varargin{1}; 
            end
            
            if brickIO.debug > 0
                fprintf('usbBrickIO init\n');
            end
            
            % Create the usb handle
            try
                brickIO.handle = hidapi(0,brickIO.vendorID,brickIO.productID, ...
                                        brickIO.nReadBuffer,brickIO.nWriteBuffer);
            catch ME
                if ~isempty(strfind(ME.identifier, 'InvalidParameterOrFileMissing'))
                    % Throw a clean InvalidParameterOrFileMissing to avoid confusion in upper layers
                    msg = ['Couldn''t load hidapi-library for USB connection due to a ' ...
                           'missing file. Make sure the correct hidapi-library and its ' ...
                           'corresponding thunk- and proto-files are available.'];
                    id = [ID(), ':', 'InvalidParameterOrFileMissing'];
                    throw(MException(id, msg));
                elseif ~isempty(strfind(ME.identifier, 'LoadingLibraryError'))
                    % Throw a clean LoadingLibraryError to avoid confusion in upper layers
                    msg = 'Failed to load hidapi-library for USB connection.';
                    id = [ID(), ':', 'LoadingLibraryError'];
                    throw(MException(id, msg));
                else
                    % Throw combined error because error did not happen due to known reasons...
                    msg = 'Unknown error occurred while trying to load the HIDAPI-lib for USB.';
                    id = [ID(), ':', 'UnknownError'];
                    newException = MException(id, msg);
                    newException = addCause(newException, ME);
                    throw(newException);
                end
            end
                                
            % Open the brick IO connection
            brickIO.open;
        end
        
        function delete(brickIO)
            %usbBrickIO.delete Delete the usbBrickIO object
            %
            % delete(brickIO) closes the usb connection handle
            
            if brickIO.debug > 0
                fprintf('usbBrickIO delete\n');
            end
            
            % Disconnect
            try
                brickIO.close;
            catch
                % Connection already closed (probably due to an error) - do nothing
            end
        end
        
        function open(brickIO)
            %usbBrickIO.open Open the usbBrickIO object
            %
            % usbBrickIO.open() opens the usb handle through the hidapi
            % interface.
            
            if brickIO.debug > 0
                fprintf('usbBrickIO open\n');
            end
            
            % Open the usb handle (MMI: and handle possible errors)
            try
                brickIO.handle.open;
            catch ME
                if ~isempty(strfind(ME.identifier, 'CommError'))
                    % Throw a clean CommError to avoid confusion in upper layers
                    msg = 'Failed to open connection to Brick via USB.';
                    id = [ID(), ':', 'CommError'];
                    throw(MException(id, msg));
                else
                    % Throw combined error because error did not happen due to known reasons...
                    msg = 'Unknown error occurred while trying to connect to the Brick via USB.';
                    id = [ID(), ':', 'UnknownError'];
                    newException = MException(id, msg);
                    newException = addCause(newException, ME);
                    throw(newException);
                end
            end
        end
        
        function close(brickIO)
            %usbBrickIO.close Close the usbBrickIO object
            %
            % usbBrickIO.close() closes the usb handle through the hidapi
            % interface.
            if brickIO.debug > 0
                fprintf('usbBrickIO close\n');
            end 
            
            try
                % Close the usb handle
                brickIO.handle.close;
            catch ME
                % Throw combined error because error did not happen due to known reasons...
                msg = 'Unknown error occurred while closing the USB connection.';
                id = [ID(), ':', 'UnknownError'];
                newException = MException(id, msg);
                newException = addCause(newException, ME);
                throw(newException);
            end
        end
        
        function rmsg = read(brickIO)
            %usbBrickIO.read Read data from the usbBrickIO object
            %
            % rmsg = usbBrickIO.read() reads data from the brick through
            % usb and returns the data in uint8 format.
            %
            % Notes::
            % - This function is blocking with no time out in the current
            % implementation.
            
            if brickIO.debug > 0
                fprintf('usbBrickIO read\n');
            end 
            
            % Read from the usb handle
            try
                rmsg = brickIO.handle.read;
            catch ME
                if ~isempty(strfind(ME.identifier, 'CommError'))
                    % Throw a clean CommError to avoid confusion in upper layers
                    msg = 'Failed to read data from the Brick via USB due to connection-error.';
                    id = [ID(), ':', 'CommError'];
                    throw(MException(id, msg));
                elseif ~isempty(strfind(ME.identifier, 'InvalidHandle'))
                    % Throw a clean InvalidHandle to avoid confusion in upper layers
                    msg = 'Failed to read data from the Brick via USB due to invalid handle to USB-device.';
                    id = [ID(), ':', 'InvalidHandle'];
                    throw(MException(id, msg));
                else
                    % Throw combined error because error did not happen due to known reasons...
                    msg = 'Unknown error occurred while reading data from the Brick via USB.';
                    id = [ID(), ':', 'UnknownError'];
                    newException = MException(id, msg);
                    newException = addCause(newException, ME);
                    throw(newException);
                end
            end
            
            % Get the number of read bytes
            pLength = double(typecast(uint8(rmsg(1:2)),'uint16')) + 2;
            
            % Format the read message (2 byte length plus message)
            if pLength < length(rmsg)
                rmsg = rmsg(1:pLength);
            end
        end
        
        function write(brickIO,wmsg)
            %usbBrickIO.write Write data to the usbBrickIO object
            %
            % usbBrickIO.write(wmsg) writes data to the brick through usb.
            %
            % Notes::
            % - wmsg is the data to be written to the brick via usb in  
            % uint8 format.
            
            if brickIO.debug > 0
                fprintf('usbBrickIO write\n');
            end 
            
            % Write to the usb handle using report ID 0
            try
                brickIO.handle.write(wmsg,0);
            catch ME
                if ~isempty(strfind(ME.identifier, 'CommError'))
                    % Throw a clean CommError to avoid confusion in upper layers
                    msg = 'Failed to send data to Brick via USB due to connection-error.';
                    id = 'RWTHMindstormsEV3:usbBrickIO:write:CommError';
                    throw(MException(id, msg));
                elseif ~isempty(strfind(ME.identifier, 'InvalidHandle'))
                    % Throw a clean InvalidHandle to avoid confusion in upper layers
                    msg = 'Failed to send data to Brick via USB due to invalid handle to USB-device.';
                    id = [ID(), ':', 'InvalidHandle'];
                    throw(MException(id, msg));
                else
                    % Throw combined error because error did not happen due to known reasons...
                    msg = 'Unknown error occurred while sending data to the Brick via USB.';
                    id = [ID(), ':', 'UnknownError'];
                    newException = MException(id, msg);
                    newException = addCause(newException, ME);
                    throw(newException);
                end
            end
        end
    end 
end
