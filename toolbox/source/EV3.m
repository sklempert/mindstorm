classdef EV3 < MaskedHandle
    % High-level class to work with physical bricks.
    %
    % This is the 'central' class (from user's view) when working with this toolbox. It
    % delivers a convenient interface for creating a connection to the brick and sending
    % commands to it. An EV3-object creates 4 Motor- and 4 Sensor-objects, one for each port.
    % 
    % Notes:
    %     * Creating multiple EV3 objects and connecting them to different physical bricks has not
    %       been thoroughly tested yet, but seems to work on a first glance.
    %
    %
    % Attributes:
    %     motorA (Motor): Motor-object interfacing port A
    %     motorB (Motor): Motor-object interfacing port B
    %     motorC (Motor): Motor-object interfacing port C
    %     motorD (Motor): Motor-object interfacing port D
    %     sensor1 (Sensor): Motor-object interfacing port 1
    %     sensor2 (Sensor): Motor-object interfacing port 2
    %     sensor3 (Sensor): Motor-object interfacing port 3
    %     sensor4 (Sensor): Motor-object interfacing port 4
    %     debug (numeric in {0,1,2}): Debug mode. *[WRITABLE]*
    %
    %         - 0: Debug turned off
    %         - 1: Debug turned on for EV3-object -> enables feedback in the console about what firmware-commands have been called when using a method
    %         - 2: Low-level-Debug turned on -> each packet sent and received is printed to the console
    %
    %     batteryMode (string in {'Percentage', 'Voltage'}): Mode for reading battery charge.
    %         *[WRITABLE]*
    %     batteryValue (numeric): Current battery charge. Depending on batteryMode, the reading
    %         is either in percentage or voltage. *[READ-ONLY]*
    %     isConnected (bool): True if virtual brick-object is connected to physical one. *[READ-ONLY]*
    %
    %
    % Examples:
    %     b = EV3(); |br| 
    %     b.connect('usb'); |br|   
    %     ma = b.motorA; |br|
    %     ma.setProperties('power', 50, 'limitValue', 720); |br|
    %     ma.start(); |br|  
    %     % fun |br|
    %     b.sensor1.value |br|
    %     b.waitFor(); |br|
    %     b.beep(); |br|
    %     delete b; |br|
    
    properties
        % batteryMode (string in {'Percentage', 'Voltage'}): Mode for reading battery charge. [WRITABLE]
        % See also BATTERYVALUE
        batteryMode;
        
        % debug (numeric in {0,1,2}): Debug mode. [WRITABLE]
        %     - 0: Debug turned off
        %     - 1: (High-level-) Debug turned on for EV3-object - enables feedback in the 
        %          console about what firmware-commands have been called when using a method
        %     - 2: Low-level-Debug turned on - each packet sent and received is printed to the
        %          console
        debug; 
    end

    properties (Dependent)  % Parameters to be read directly from physical brick
        % batteryValue (numeric): Current battery charge. Depending on batteryMode, the reading
        %     is either in percentage or voltage. [READ-ONLY]
        % See also BATTERYMODE
        batteryValue; 
    end
    
    properties (SetAccess = private)  % Read-only properties that are set internally
        % isConnected (bool): True if virtual brick-object is connected to physical one. [READ-ONLY]
        % See also EV3.CONNECT, EV3.DISCONNECT
        isConnected = false; 
        
        % motorA (Motor): Motor-object interfacing port A
        % See also MOTOR
        motorA;
        % motorB (Motor): Motor-object interfacing port B
        % See also MOTOR
        motorB;
        % motorC (Motor): Motor-object interfacing port C
        % See also MOTOR
        motorC;
        % motorD (Motor): Motor-object interfacing port D
        % See also MOTOR
        motorD;
        
        % sensor1 (Sensor): Sensor-object interfacing port 1
        % See also SENSOR
        sensor1;
        % sensor2 (Sensor): Sensor-object interfacing port 2
        % See also SENSOR
        sensor2;
        % sensor3 (Sensor): Sensor-object interfacing port 3
        % See also SENSOR
        sensor3;
        % sensor4 (Sensor): Sensor-object interfacing port 4
        % See also SENSOR
        sensor4;            
    end
    
    properties (Access = private)
        % commInterface (CommunicationInterface): Interface to communication layer
        %     All commands sent to the Brick are created and written through this object. Each
        %     Motor- and Sensor-object has a reference to it.
        commInterface = 0;
    end
    
    properties (Hidden, Access = private)  % Hidden properties for internal use only
        % init (bool): Indicates init-phase (i.e. constructor is running).
        init = true;
    end
    
    methods  % Standard methods
        %% Constructor
        function ev3 = EV3(varargin)
            % Sets properties of EV3-object and creates Motor- and Sensor-objects with default
            % parameters.
            %
            % Arguments
            %     varargin: see setProperties(ev3, varargin)
            %
            % See also SETPROPERTIES
            
            ev3.setProperties(varargin{:});
            
            ev3.motorA = Motor('A', 'Debug', ev3.debug>=1);
            ev3.motorB = Motor('B', 'Debug', ev3.debug>=1);
            ev3.motorC = Motor('C', 'Debug', ev3.debug>=1);
            ev3.motorD = Motor('D', 'Debug', ev3.debug>=1);
            
            
            ev3.sensor1 = Sensor('1', 'Debug', ev3.debug>=1);
            ev3.sensor2 = Sensor('2', 'Debug', ev3.debug>=1);
            ev3.sensor3 = Sensor('3', 'Debug', ev3.debug>=1);
            ev3.sensor4 = Sensor('4', 'Debug', ev3.debug>=1);
            
            ev3.init = false;
        end
        
        function delete(ev3)
            % Disconnects from physical brick and deletes this instance
            
            if ev3.isConnected
                ev3.disconnect();
            end
        end
        
        %% Connection 
        function connect(ev3, varargin)
            % Connects EV3-object and its Motors and Sensors to physical brick.
            %
            % Arguments:
            %     connectionType (string in {'bt', 'usb'}): Connection type
            %     serPort (string in {'/dev/rfcomm1', '/dev/rfcomm2', ...}): Path to serial port 
            %         (if 'bt')
            %     beep (bool): If true, EV3 beeps if connection has been established
            %
            % Examples:
            %     % Setup bluetooth connection via com-port 0 |br|
            %     b = EV3(); |br|
            %     b.connect('bt', 'serPort', '/dev/rfcomm0'); |br|
            %     % Setup usb connection, beep when connection has been established
            %     b = EV3(); |br|
            %     b.connect('usb', 'beep', 'on', ); |br| 
            %     
            
            % Check connection
            if ev3.isConnected
                if isCommInterfaceValid(ev3.commInterface)
                    error('EV3::connect: Already connected.');
                else
                    warning(['EV3::connect: EV3.isConnected is set to ''True'', but ',...
                             'comm handle is invalid. Deleting invalid handle and ' ,...
                             'resetting EV3.isConnected now...']);
                         
                    ev3.commInterface = 0;
                    ev3.isConnected = false;
                end
            end
            
            if nargin < 2
                 error('EV3::connect: Wrong number of input arguments.');
            end
            
            idxes = strcmpi('beep', varargin);
            idx = find([0, idxes(1:end-1)]);
            if ~isempty(idx)
                beep = varargin{idx}; %#ok<FNDSB>
                if ~isBool(beep)
                    error('EV3::connect: Argument after ''beep'' has to be a bool.');
                end
            else
                beep = false;
            end
            
            % Try to connect
            try 
                % Connect to physical brick
                % -> Creating communication-handle implicitly establishes connection
                ev3.commInterface = CommunicationInterface(varargin{:}, 'debug', ev3.debug>=2);
                ev3.isConnected = true;
                
                if beep
                    ev3.beep();
                end
                
                % Connect motors
                ev3.motorA.connect(ev3.commInterface);
                ev3.motorB.connect(ev3.commInterface);
                ev3.motorC.connect(ev3.commInterface);
                ev3.motorD.connect(ev3.commInterface);
                
                % Connect sensors
                ev3.sensor1.connect(ev3.commInterface);
                ev3.sensor2.connect(ev3.commInterface);
                ev3.sensor3.connect(ev3.commInterface);
                ev3.sensor4.connect(ev3.commInterface);
            catch ME
                % Something went wrong...
                ev3.isConnected = false;
                if isCommInterfaceValid(ev3.commInterface) && ev3.commInterface ~= 0
                    ev3.commInterface.delete();
                    ev3.commInterface = 0;
                end
                
                rethrow(ME);
            end
        end
        
        function disconnect(ev3)
            % Disconnects EV3-object and its Motors and Sensors from physical brick.
            %
            % Notes:
            %     * Gets called automatically when EV3-object is destroyed.
            %
            % Example:
            %     b = EV3(); 
            %     b.connect('bt', 'serPort', '/dev/rfcomm0');
            %     % do stuff
            %     b.disconnect();
            
            % Reset motors and sensors before disconnecting
            ev3.resetPhysicalBrick();
            
            % Disconnect motors and sensors
            % -> set references to comm handle to 0
            ev3.motorA.disconnect();
            ev3.motorB.disconnect();
            ev3.motorC.disconnect();
            ev3.motorD.disconnect();
            
            ev3.sensor1.disconnect();
            ev3.sensor2.disconnect();
            ev3.sensor3.disconnect();
            ev3.sensor4.disconnect();
            
            % Delete handle to comm-interface
            if isCommInterfaceValid(ev3.commInterface) && ev3.commInterface ~= 0
                ev3.commInterface.delete();
            end
            ev3.commInterface = 0;
            
            ev3.isConnected = false;
        end
        
        %% Device functions
        function stopAllMotors(ev3)
            % Sends a stop-command to all motor-ports
            
            if ~ev3.isConnected
                stopAllMotors(['EV3::beep: Brick-Object not connected physical brick. ',...
                       'You have to call ev3.connect(...) first!']);
            end
            
            ev3.commInterface.outputStopAll();
        end
        
        %% Sound functions
        function beep(ev3)
            % Plays a 'beep'-tone on brick.
            %
            % Notes:
            %     * This equals playTone(10, 1000, 100) (Wraps the same opCode in comm-layer)
            %
            % Example:
            %     b = EV3(); |br|
            %     b.connect('bt', 'serPort', '/dev/rfcomm0'); |br|
            %     b.beep(); |br|
            %
            
            if ~ev3.isConnected
                error(['EV3::beep: Brick-Object not connected physical brick. ',...
                       'You have to call ev3.connect(...) first!']);
            end
            
            ev3.commInterface.beep();
            
            if ev3.debug
				fprintf('(DEBUG) EV3::beep: Called beep on brick\n');
            end
        end
        
        function playTone(ev3, volume, frequency, duration)
            % Plays tone on brick.
            %
            % Arguments:
            %     volume (numeric in [0, 100]): in percent
            %     frequency (numeric in [250, 10000]): in Hertz
            %     duration (numeric >0): in milliseconds
            %
            % Example:
            %     b = EV3(); |br| 
            %     b.connect('bt', 'serPort', '/dev/rfcomm0'); |br|
            %     b.playTone(50, 5000, 1000);  % Plays tone with 50% volume and 5000Hz for 1
            %     second. |br|
            %
            
            if ~ev3.isConnected
                error(['EV3::isConnected: Brick-Object not connected physical brick. ',...
                       'You have to call ev3.connect(...) first!']);
            end
            
            ev3.commInterface.soundPlayTone(volume, frequency, duration);
            
            if ev3.debug
				fprintf('(DEBUG) EV3::beep: Called soundPlayTone on brick\n');
            end
        end
        
        function stopTone(ev3)
            % Stops tone currently played
            %
            % Example:
            %     b = EV3(); |br|
            %     b.connect('bt', 'serPort', '/dev/rfcomm0'); |br|
            %     b.playTone(10,100,100000000);  % Accidentally given wrong tone duration :) |br|
            %     b.stopTone();  % Stops tone immediately. |br|
            %
            
            if ~ev3.isConnected
                error(['EV3::stopTone: Brick-Object not connected physical brick. ',...
                       'You have to call ev3.connect(...) first!']);
            end
            
            ev3.commInterface.soundStopTone();
            
            if ev3.debug
				fprintf('(DEBUG) EV3::beep: Called soundStopTone on brick\n');
            end
        end
        
        function status = tonePlayed(ev3)
            % Tests if tone is currently played.
            %
            % Returns:  
            %     status (bool): True if a tone is being played
            %            
            % Example
            %     b = EV3(); |br|
            %     b.connect('bt', 'serPort', '/dev/rfcomm0'); |br|
            %     b.playTone(10, 100, 1000); |br|
            %     pause(0.5); |br|
            %     b.tonePlayed() -> Outputs 1 to console. |br|
            %
            
            if ~ev3.isConnected
                error(['EV3::tonePlayed: Brick-Object not connected physical brick. ',...
                       'You have to call ev3.connect(...) first!']);
            end
            
            status = ev3.commInterface.soundTest;
            
            if ev3.debug
				fprintf('(DEBUG) EV3::beep: Called soundTest on brick\n');
            end
        end
        
        %% Setter
        function set.commInterface(ev3, comm)
            if ~isCommInterfaceValid(comm)
                error('EV3::set.commInterface: Handle to Brick-object not valid.');
            else
                ev3.commInterface = comm;
            end
        end
        
        function set.batteryMode(ev3, batteryMode)
            validModes = {'Voltage', 'Percentage'};
            if ~ischar(batteryMode) || ~ismember(batteryMode, validModes)
                error('EV3::set.batteryMode: Given parameter is not a valid battery mode.');
            else 
                ev3.batteryMode = batteryMode;
            end
        end
        
        function set.debug(ev3, debug)
            if ~isBool(debug) && debug ~= 2
                error('EV3::set.debug: Given parameter is not a bool.');
            end
            
            ev3.debug = str2bool(debug);
            
            if ev3.isConnected
                ev3.commInterface.debug = (ev3.debug >= 2); 
            end
        end
        
        function setProperties(ev3, varargin)
            % Set multiple EV3 properties at once using MATLAB's inputParser.
            %
            % Arguments:
            %     debug (numeric in {0,1,2}): see EV3.debug *[OPTIONAL]*
            %     batteryMode (string in {'Voltage'/'Percentage'}): see EV3.batteryMode *[OPTIONAL]*
            %
            % Example:
            %     b = EV3(); |br|
            %     b.connect('bt', 'serPort', '/dev/rfcomm0'); |br|
            %     b.setProperties('debug', 'on', 'batteryMode', 'Voltage'); |br|
            %     % Instead of: b.debug = 'on'; b.batteryMode = 'Voltage'; |br|
            %
            % See also EV3.DEBUG, EV3.BATTERYMODE
            
            p = inputParser();
            
            % Set default values
            if ev3.init
                defaultDebug = false;
                defaultBatteryMode = 'Percentage';
            else
                defaultDebug = ev3.debug;
                defaultBatteryMode = ev3.batteryMode;
            end
            
            % Add parameter
            p.addOptional('debug', defaultDebug);
            p.addOptional('batteryMode', defaultBatteryMode);
            
            % Parse...
            p.parse(varargin{:});
            
            % Set properties
            ev3.batteryMode = p.Results.batteryMode;
            ev3.debug = p.Results.debug;
        end
        
        %% Getter
        function bat = get.batteryValue(ev3)
            if ~ev3.isConnected
                warning('EV3::getBattery: EV3-Object not connected to physical EV3.');
                
                bat = 0;
                return;
            end
            
            bat = ev3.getBattery();
        end
        
        function display(ev3)
            % Displays EV3-properties and its devices
            
            displayProperties(ev3); 
            
            fprintf('\n\tDevices\n');
            props = properties(ev3);
            
            warning('off', 'all');  % Turn off warnings while reading values
            for i = 1:length(props)
                p = props{i};
                
                if strcmp(class(ev3.(p)),'Sensor') || strcmp(class(ev3.(p)), 'Motor')
                    fprintf('\t%15s [Type: %s]\n', p, char(ev3.(p).type));
                end
            end
            warning('on', 'all');
        end
    end
    
    methods (Access = private)  % Private brick functions that are wrapped by dependent params
        function bat = getBattery(ev3)
            if ~ev3.isConnected
                error(['EV3::getBattery: EV3-Object not connected to physical EV3. You have ',...
                    'to call ev3.connect(properties) first!']);
            end
            
            if strcmpi(ev3.batteryMode, 'Percentage')
                bat = ev3.commInterface.uiReadLbatt();
                
                if ev3.debug
                    fprintf('(DEBUG) EV3::getBattery: Called uiReadLBatt.\n');
                end
            elseif strcmpi(ev3.batteryMode, 'Voltage')
                bat = ev3.commInterface.uiReadVbatt();
                
                if ev3.debug
                    fprintf('(DEBUG) EV3::getBattery: Called uiReadVBatt.\n');
                end
            end
        end
        
        function resetPhysicalBrick(ev3)
            sensors = {'sensor1', 'sensor2', 'sensor3', 'sensor4'};
            motors = {'motorA', 'motorB', 'motorC', 'motorD'};
            
            for i = 1:4
                motor = motors{i};
                ev3.(motor).resetPhysicalMotor();
            end
            
            for i = 1:4
                sensor = sensors{i};
                ev3.(sensor).resetPhysicalSensor();
            end
        end
    end
end 
