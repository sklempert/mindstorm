%hidpi Interface to the hidapi library
%
% Methods::
%  hidapi                   Constructor, loads the hidapi library
%  delete                   Destructor, closes any open hid connection
%
%  open                     Open the hid device with vendor and product ID
%  close                    Close the hid device connection
%  read                     Read data from the hid device
%  write                    Write data to the hid device
%
%  getHIDInfoString         Get the relevant hid info from the hid device
%  getManufacturersString   Get the manufacturers string from the hid device
%  getProductString         Get the product string from the hid device
%  getSerialNumberString    Get the serial number from the hid device
%  setNonBlocking           Set non blocking hid read
%  init                     Init the hidapi (executed in open by default)
%  exit                     Exit the hidapi
%  error                    Return the error string
%  enumerate                Enumerate the connected hid devices
%
%
% Example::
%           hid = hidapi(1,1684,0005,1024,1025)
%
% Notes::
% - Developed from the hidapi available from http://www.signal11.us/oss/hidapi/
% - Windows: need the hidapi.dll file
% - Mac: need the hidapi.dylib file. Will also need Xcode installed to run load library
% - Linux: will need to compile on host system and copy the resulting .so file

classdef hidapi < handle
    properties
        % connection handle
        handle
        % debug input
        debug = 0;
        % vendor ID
        vendorID = 0;
        % product ID
        productID = 0;
        % read buffer size
        nReadBuffer = 256;
        % write buffer size
        nWriteBuffer = 256;
        % shared library
        slib = 'hidapi';
        % shared library header
        sheader = 'hidapi.h';
        
    end
    
    methods
        %% Constructor
        
        function hid = hidapi(debug,vendorID,productID,nReadBuffer,nWriteBuffer)
            %hidapi.hidapi Create a hidapi library interface object
            %
            % hid = hidapi(debug,vendorID,productID,nReadBuffer,nWriteButter)
            % is an object which initialises the hidapi from the corresponding
            % OS library. Other parameters are also initialised. Some OS
            % checking is required in this function to load the correct
            % library.
            %
            % Throws::
            %  LoadingLibraryError              Could not load .dll/.dylib/.so-file of hidapi
            %  InvalidFileNameOrFileMissing     Either file names given were wrong or the files 
            %                                   are missing (thunk files, proto files, ...)
            %
            % Notes::
            % - debug is a flag specifying output printing (0 or 1).
            % - vendorID is the vendor ID of the hid device (decimal not hex).
            % - productID is the product ID of the hid device (decimal not hex).
            % - nReadBuffer is the length of the read buffer.
            % - nWriteBuffer is the length of the write buffer.
            
            
            hid.debug = debug;
            
            if hid.debug > 0
                fprintf('hidapi init\n');
            end
            
            if nargin > 1
                hid.vendorID = vendorID;
                hid.productID = productID;
                hid.nReadBuffer = nReadBuffer;
                hid.nWriteBuffer = nWriteBuffer;
            end
            
            % Disable warnings
            warning('off','MATLAB:loadlibrary:TypeNotFoundForStructure');
            warning('off', 'MATLAB:loadlibrary:ClassIsLoaded');
            
            try
                % Check the operating system type and load slib
                if (ispc == 1)
                    % Check the bit version
                    if (strcmp(mexext,'mexw32'))
                        hid.slib = 'hidapi32';
                        % Load the library via the proto file
                        loadlibrary(hid.slib,@hidapi32_proto,'alias','hidapiusb')
                    elseif (strcmp(mexext,'mexw64'))
                        hid.slib = 'hidapi64';
                        % Load the library via the proto file
                        loadlibrary(hid.slib,@hidapi64_proto,'alias','hidapiusb')
                    end
                elseif (ismac == 1)
                    hid.slib = 'hidapi64';
                    % Load the library via the proto file
                    loadlibrary(hid.slib,@hidapi64mac_proto,'alias','hidapiusb');
                elseif (isunix == 1)
                    hid.slib = 'libhidapi-libusb';
                    % Load the shared library
                    loadlibrary(hid.slib,@hidapi_libusb_proto,'alias','hidapiusb');
                end
            catch ME
                % Create own exception for clarification
                id = [ID(), ':', 'LoadingLibraryError'];
                msg = strcat({'Could not load library '}, {hid.slib}, {'.'});
                exception = MException(id, msg);

                % Try to narrow down loading failure
                if isempty(findstr(ME.identifier, 'LoadFailed')) ...
                        && isempty(findstr(ME.identifier, 'ErrorLoadingLibrary')) ...
                        && isempty(findstr(ME.identifier, 'ErrorInHeader'))
                    id = [ID(), ':', 'InvalidFileNameOrFileMissing'];
                    msg = 'Invalid file names were given or files are not available.';
                    cause = MException(id, msg);
                    exception = addCause(exception, cause);
                end

                throw(exception);
            end
            % Remove the library extension
            hid.slib = 'hidapiusb';

            if hid.debug > 0
                libfunctionsview('hidapiusb');
            end
        end
        
        function delete(hid)
            %hidapi.delete Delete hid object
            %
            % delete(hid) closes an open hid device connection. This function is called 
            % automatically when deleting.
            %
            % Notes::
            % - You cannot unloadlibrary in this function as the object is
            % still present in the MATLAB work space.
            
            if hid.debug > 0
                fprintf('hidapi delete\n');
            end
        end
        
        %% Wrapper 
        
        function str = getManufacturersString(hid)
            %hidapi.getManufacturersString get manufacturers string from hid object
            %
            % hid.getManufacturersString() returns the manufacturers string
            % from the hid device using getHIDInfoString.
            
            str = getHIDInfoString(hid,'hid_get_manufacturer_string');
        end
        
        function str = getProductString(hid)
            %hidapi.getProductString get product string from hid object
            %
            % hid.getProductString() returns the product string from the
            % hid device using getProductString.
            
            str = getHIDInfoString(hid,'hid_get_product_string');
        end
        
        function str = getSerialNumberString(hid)
            %hidapi.getSerialNumberString get product string from hid object
            %
            % hid.getSerialNumberString() returns the serial number string
            % from the hid device using getSerialNumberString.
            
            str = getHIDInfoString(hid,'hid_get_serial_number_string');
        end
        
        %% Wrapped HIDAPI-Functions
        
        function open(hid)
            %hidapi.open Open a hid object
            %
            % hid.open() opens a connection with a hid device with the
            % initialised values of vendorID and productID from the hidapi
            % constructor.
            %
            % Throws::
            %  CommError	Error during communication with device
            %
            % Notes::
            % - The pointer return value from this library call is always
            % null so it is not possible to know if the open was
            % successful.
            % - The final parameter to the open hidapi library call has
            % different types depending on OS. In windows it is uint16 but
            % linux/mac it is int32.
            
            if hid.debug > 0
                fprintf('hidapi open\n');
            end
            
            % Create a null pointer for the hid_open function (depends on OS)
            if (ispc == 1)
                pNull = libpointer('uint16Ptr');
            elseif ((ismac == 1) || (isunix == 1))
                pNull = libpointer('int32Ptr');
            end
            
            % Open the hid interface
            [newHandle,value] = calllib(hid.slib,'hid_open',uint16(hid.vendorID), ...
                uint16(hid.productID),pNull);
            
            % (MMI) Assert error case (hid_open returns null-pointer in error case)
            assert(isLibPointerValid(newHandle)==1, ...
                [ID(), ':', 'CommError'], ...
                'Failed to connect to USB device.');
            
            hid.handle = newHandle;
        end
        
        function close(hid)
            %hidapi.close Close hid object
            %
            % hid.close() closes the connection to a hid device. Gets called automatically
            % when deleting the hid instance.
            %
            % Throws::
            %  InvalidHandle	Handle to USB-device not valid
            %
            
            if hid.debug > 0
                fprintf('hidapi close\n');
            end
            
            % (MMI) Check if pointer is (unexpectedly) already invalidated
            assert(isLibPointerValid(hid.handle)==1, ...
                [ID(), ':', 'InvalidHandle'], ...
                'Failed to close USB-connection because pointer to USB-device is already invalidated.');
            
            % Close the connection
            calllib(hid.slib,'hid_close',hid.handle);
            
            % Invalidate the pointer
            hid.handle = [];
        end
        
        function rmsg = read(hid)
            %hidapi.rmsg Read from hid object
            %
            % rmsg = hid.read() reads from a hid device and returns the
            % read bytes. Will print an error if no data was read.
            %
            % Throws::
            %  CommError        Error during communication with device
            %  InvalidHandle    Handle to USB-device not valid
            %
            
            if hid.debug > 0
                fprintf('hidapi read\n');
            end
            
            % Read buffer of nReadBuffer length
            buffer = zeros(1,hid.nReadBuffer);
            % Create a uint8 pointer
            pbuffer = libpointer('uint8Ptr', uint8(buffer));
            
            % (MMI) Check if pointer is (unexpectedly) already invalidated
            assert(isLibPointerValid(hid.handle)==1, ...
                [ID(), ':', 'InvalidHandle'], ...
                'Failed to read USB-data because pointer to USB-device is invalidated.');
            
            % Read data from HID device
            [res,h] = calllib(hid.slib,'hid_read',hid.handle,pbuffer,uint64(length(buffer)));
            
            % (MMI) Check the response (No assert as there are multiple cases)
            if res < 1
                % Error occurred
                id = [ID(), ':', 'CommError'];
                % Narrow error down
                if res == -1
                    msg = 'Connection error (probably lost connection to device)';
                elseif res == 0
                    msg = ['Could not read data from device (device is still connected, ',...
                           'but does not react)'];
                else
                    msg = 'Unexpected connection error';
                end
                causeException = MException(id, msg);
                ME = MException(id, 'Failed to read data via USB.');
                addCause(ME, causeException);
                throw(ME);
            end
            
            % Return the string value
            rmsg = pbuffer.Value;
        end
        
        function write(hid,wmsg,reportID)
            %hidapi.write Write to hid object
            %
            % hid.write() writes to a hid device. Will print an error if
            % there is a mismatch between the buffer size and the reported
            % number of bytes written.
            %
            % Throws::
            %  CommError        Error during communication with device
            %  InvalidHandle	Handle to USB-device not valid
            %
            
            if hid.debug > 0
                fprintf('hidapi write\n');
            end
            
            % Append a 0 at the front for HID report ID
            wmsg = [reportID wmsg];
            
            % Pad with zeros for nWriteBuffer length
            % (MMI) Note:: The following line does not seem to be necessary;
            % wmsg does not need to be the max packet size. Uncommenting this doesn't affect
            % anything, and I would prefer sending short messages over long ones.
            % Further testing may be required, so for now I don't change a thing.
            wmsg(end+(hid.nWriteBuffer-length(wmsg))) = 0;
            
            % Create a uint8 pointer
            pbuffer = libpointer('uint8Ptr', uint8(wmsg));
            
            % (MMI) Check if pointer is (unexpectedly) already invalidated
            assert(isLibPointerValid(hid.handle)==1, ...
                [ID(), ':', 'InvalidHandle'], ...
                'Failed to write to USB because pointer to USB-device is invalidated.');
            
            % Write the message
            [res,h] = calllib(hid.slib,'hid_write',hid.handle,pbuffer,uint64(length(wmsg)));
            
            % (MMI) Check the response
            assert(res == length(wmsg), ...
                [ID(), ':', 'CommError'], ...
                'Failed to write data via USB.');
        end
        
        function str = getHIDInfoString(hid,info)
            %hidapi.getHIDInfoString get hid information from object
            %
            % hid.getHIDInfoString(info) gets the corresponding hid info
            % from the hid device
            %
            % Throws::
            %  CommError        Error during communication with device
            %  InvalidHandle	Handle to USB-device not valid
            %
            % Notes::
            % - info is the hid information string.
            
            if hid.debug > 0
                fprintf(['hidapi ' info '\n']);
            end
            % Read buffer nReadBuffer length
            buffer = zeros(1,hid.nReadBuffer);
            % Create a libpointer (depends on OS)
            if (ispc == 1)
                pbuffer = libpointer('uint16Ptr', uint16(buffer));
            elseif ((ismac == 1) || (isunix == 1))
                pbuffer = libpointer('int32Ptr', uint32(buffer));
            end
            
            % (MMI) Check if pointer is (unexpectedly) already invalidated
            assert(isLibPointerValid(hid.handle)==1, ...
                [ID(), ':', 'InvalidHandle'], ...
                'Failed to read USB-data because pointer to USB-device is invalidated.');
            
            % Get the HID info string
            [res,h] = calllib(hid.slib,info,hid.handle,pbuffer,uint32(length(buffer)));
            
            % (MMI) Check the response
            assert(res~=-1, ...
                [ID(), ':', 'CommError'], ...
                'Failed to read HID info string.');
            
            % Return the string value
            str = sprintf('%s',char(pbuffer.Value));
        end
        
        function setNonBlocking(hid,nonblock)
            %hidapi.setNonBlocking sets non blocking on the hid object
            %
            % hid.setNonBlocking(nonblock) sets the non blocking flag on
            % the hid device connection.
            %
            % Throws::
            %  CommError        Error during communication with device
            %  InvalidHandle	Handle to USB-device not valid
            %
            % Notes::
            % nonblock - 0 disables nonblocking, 1 enables nonblocking
            
            if hid.debug > 0
                fprintf('hidapi setNonBlocking\n');
            end
            
            % (MMI) Check if pointer is (unexpectedly) already invalidated
            assert(isLibPointerValid(hid.handle)==1, ...
                [ID(), ':', 'InvalidHandle'], ...
                'Failed to set USB-read-mode to non-blocking because pointer to USB-device is invalidated.');
            
            % Set non blocking
            [res,h] = calllib(hid.slib,'hid_set_nonblocking',hid.handle,uint32(nonblock));
            
            % (MMI) Check the response
            assert(res~=-1, ...
                [ID(), ':', 'CommError'], ...
                'Failed to set USB-read-mode to non-blocking.');
        end
        
        function init(hid)
            %hidapi.init Init hidapi
            %
            % hid.init() inits the hidapi library. This is called
            % automatically in the library itself with the open function.
            %
            % Throws::
            %  CommError	Error during communication with device
            %
            % Notes::
            % - You should not have to call this function directly.
            
            if hid.debug > 0
                fprintf('hidapi init\n');
            end
            
            warning([ID(), ':', 'RedundantCall'], ...
                'The init-function gets called automatically when connecting!');
            
            % Init device
            res = calllib(hid.slib,'hid_init');
            
            % (MMI) Check the response
            assert(res~=-1, ...
                [ID(), ':', 'CommError'], ...
                'Failed to init USB-device.');
        end
        
        function exit(hid)
            %hidapi.exit Exit hidapi
            %
            % hid.exit() exits the hidapi library.
            %
            % Throws::
            %  CommError	Error during communication with device
            %
            % Notes::
            % - You should not have to call this function directly.
            
            if hid.debug > 0
                fprintf('hidapi exit\n');
            end
            
            warning([ID(), ':', 'RedundantCall'], ...
                'The exit-function gets called automatically when disconnecting!');
            
            % Exit device
            res = calllib(hid.slib,'hid_exit');
            
            % (MMI) Check the response
            assert(res~=-1, ...
                [ID(), ':', 'CommError'], ...
                'Failed to exit USB-device.');
        end
        
        function str = error(hid)
            %hidapi.error Output the hid object error string
            %
            % hid.error() returns the hid device error string if a function
            % produced an error.
            %
            % Throws::
            %  InvalidHandle	Handle to USB-device not valid
            %
            % Notes::
            % - This function must be called explicitly if you think an
            % error was generated from the hid device.
            
            if hid.debug > 0
                fprintf('hidapi error\n');
            end
            
            % (MMI) Check if pointer is (unexpectedly) already invalidated
            assert(isLibPointerValid(hid.handle)==1, ...
                [ID(), ':', 'InvalidHandle'], ...
                'Failed to read USB-error-data because pointer to USB-device is invalidated.');
            
            [~,str] = calllib(hid.slib,'hid_error',hid.handle);
        end
        
        function str = enumerate(hid,vendorID,productID)
            %hidapi.enumerate Enumerates the hid object
            %
            % str = hid.enumerate(vendorID,productID) enumerates the hid
            % device with the given vendorID and productID and returns a
            % string with the returned hid information.
            %
            % Notes::
            % - vendorID is the vendor ID (in decimal not hex).
            % - productID is the vendor ID (in decimal not hex).
            % - Using a vendorID and productID of (0,0) will enumerate all
            % connected hid devices.
            % - MATLAB does not have the hid_device_infoPtr struct so some
            % of the returned information will need to be resized and cast
            % into uint8 or chars.
            
            if hid.debug > 0
                fprintf('hidapi enumerate\n');
            end
            
            % Enumerate the hid devices
            str = calllib(u.slib,'hid_enumerate',uint16(vendorID),uint16(productID));
        end
    end
end


function valid = isLibPointerValid(handle)
    %isHandleValid Check whether hid.handle is valid libpointer

    valid = 0;
    if ~isempty(handle)
        if isa(handle, 'handle') && ~isNull(handle)
            valid = 1;
        end
    end
end
