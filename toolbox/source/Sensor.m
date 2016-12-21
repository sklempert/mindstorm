classdef Sensor < MaskedHandle
    % High-level class to work with sensors.
    % 
    % The Sensor-class facilitates the communication with sensors. This mainly consists of 
    % reading the sensor's type and current value in a specified mode.
    %
    % Notes:
    %     * You don't need to create instances of this class. The EV3-class automatically creates
    %       instances for each sensor port, and you can work with them via the EV3-object. 
    %     * The Sensor-class represents sensor ports, not individual sensors!
    %
    %
    % Attributes:
    %    mode (DeviceMode.{Type}): Sensor mode in which the value will be read. By default, 
    %        mode is set to DeviceMode.Default.Undefined. Once a physical sensor is connected
    %        to the port *and* the physical Brick is connected to the EV3-object, the allowed 
    %        mode and the default mode for a Sensor-object are the following (depending on the
    %        sensor type): *[WRITABLE]*
    %
    %        * Touch-Sensor: 
    %            * DeviceMode.Touch.Pushed [Default]
    %            * DeviceMode.Touch.Bumps
    %        * Ultrasonic-Sensor: 
    %            * DeviceMode.UltraSonic.DistCM [Default]
    %            * DeviceMode.UltraSonic.DistIn
    %            * DeviceMode.UltraSonic.Listen
    %        * Color-Sensor: 
    %            * DeviceMode.Color.Reflect [Default]
    %            * DeviceMode.Color.Ambient
    %            * DeviceMode.Color.Col
    %        * Gyro-Sensor: 
    %            * DeviceMode.Gyro.Angular [Default]
    %            * DeviceMode.Gyro.Rate
    %    debug (bool): Debug turned on or off. In debug mode, everytime a command is passed to 
    %        the sublayer ('communication layer'), there is feedback in the console about what 
    %        command has been called. *[WRITABLE]*
    %    value (numeric): Value read from hysical sensor. What the value represents depends on
    %        sensor.mode. *[READ-ONLY]*
    %    type (DeviceType): Type of physical sensor connected to the port. Possible types are: [READ-ONLY]
    %
    %        * DeviceType.NXTTouch
    %        * DeviceType.NXTLight
    %        * DeviceType.NXTSound
    %        * DeviceType.NXTColor
    %        * DeviceType.NXTUltraSonic
    %        * DeviceType.NXTTemperature
    %        * DeviceType.LargeMotor
    %        * DeviceType.MediumMotor
    %        * DeviceType.Touch 
    %        * DeviceType.Color 
    %        * DeviceType.UltraSonic 
    %        * DeviceType.Gyro 
    %        * DeviceType.InfraRed 
    %        * DeviceType.Unknown
    %        * DeviceType.None 
    %        * DeviceType.Error
    
    properties  % Standard properties to be set by user
        % mode (DeviceMode.{Type}): Sensor mode in which the value will be read. By default, 
        %     mode is set to DeviceMode.Default.Undefined. Once a physical sensor is connected
        %     to the port *and* the physical Brick is connected to the EV3-object, the allowed 
        %     mode and the default mode for a Sensor-object are the following (depending on the
        %     sensor type): [WRITABLE]
        %
        %     * Touch-Sensor: 
        %         * DeviceMode.Touch.Pushed [Default]
        %         * DeviceMode.Touch.Bumps
        %     * Ultrasonic-Sensor: 
        %         * DeviceMode.UltraSonic.DistCM [Default]
        %         * DeviceMode.UltraSonic.DistIn
        %         * DeviceMode.UltraSonic.Listen
        %     * Color-Sensor: 
        %         * DeviceMode.Color.Reflect [Default]
        %         * DeviceMode.Color.Ambient
        %         * DeviceMode.Color.Col
        %     * Gyro-Sensor: 
        %         * DeviceMode.Gyro.Angular [Default]
        %         * DeviceMode.Gyro.Rate
        %
        % See also SENSOR.VALUE, SENSOR.TYPE 
        mode;
        
        % debug (bool): Debug turned on or off. In debug mode, everytime a command is passed to 
        %     the sublayer ('communication layer'), there is feedback in the console about what 
        %     command has been called. [WRITABLE]
        debug;
    end
    
    properties (Dependent)  % Parameters to be read directly from physical brick
        % value (numeric): Value read from hysical sensor. What the value represents depends on
        %     sensor.mode. *[READ-ONLY]*
        % See also SENSOR.MODE
        value;
        
        % type (DeviceType): Type of physical sensor connected to the port. Possible types are
        % *[READ-ONLY]*:
        %     * DeviceType.NXTTouch
        %     * DeviceType.NXTLight
        %     * DeviceType.NXTSound
        %     * DeviceType.NXTColor
        %     * DeviceType.NXTUltraSonic
        %     * DeviceType.NXTTemperature
        %     * DeviceType.LargeMotor
        %     * DeviceType.MediumMotor
        %     * DeviceType.Touch 
        %     * DeviceType.Color 
        %     * DeviceType.UltraSonic 
        %     * DeviceType.Gyro 
        %     * DeviceType.InfraRed 
        %     * DeviceType.Unknown
        %     * DeviceType.None 
        %     * DeviceType.Error
        type; 
    end

    properties (Hidden, Access = private)  % Hidden properties for internal use only 
        % commInterface (CommunicationInterface): Commands are created and sent via the 
        %     communication interface class.
        commInterface; 
        
        % port (string): Sensor port. 
        %     This is only the string representation of the sensor port to work with.
        %     Internally, SensorPort-enums are used.
        port; 
        
        % init (bool): Indicates init-phase (i.e. constructor is running).
        init = true;
        
        % connectedToBrick (bool): True if virtual brick is connected to physical brick.
        connectedToBrick = false;
    end   
    
    properties (Hidden, Dependent, Access = private)
        %physicalSensorConnected (bool): True if physical sensor is connected to this port
        physicalSensorConnected;
    end
    
    methods  % Standard methods
        %% Constructor
        function sensor = Sensor(varargin)
            % Sets properties of Sensor-object and indicates end of init-phase when it's done
            %
            % Notes:
            %     * input-arguments will directly be handed to Motor.setProperties
            %
            % Arguments:
            %     varargin: see setProperties(sensor, varargin)
            %
            
            sensor.setProperties(varargin{1:end});
			sensor.init = false;
        end
        
        %% Brick functions
        function reset(sensor)
            % Resets value on sensor
            %
			% Notes:
            %     * This clears ALL the sensors right now, no other Op-Code available... :(
            if ~sensor.connectedToBrick
                error('Sensor::reset: Sensor-Object not connected to comm handle.');
            elseif ~sensor.physicalSensorConnected
                error('Sensor::reset: No physical sensor connected to Port %d.',...
                       sensor.port+1);
            end
            
%             warning(['Sensor::reset: Current version of reset resets ALL devices, that is, ',...
%                      'all motor tacho counts and all other sensor counters!']);
            sensor.commInterface.inputDeviceClrAll(0);
            
            if sensor.debug
                fprintf('(DEBUG) Sensor::reset: Called inputReadSI on Port %d.\n',...
                    sensor.port+1);
            end
        end
        
        %% Setter
        function set.mode(sensor, mode)
            if strcmp(class(mode),'DeviceMode.Default') && ~sensor.physicalSensorConnected
                sensor.mode = mode;
                return;
            end
            
            type = sensor.type;
            if ~isModeValid(mode, type)
                error('Sensor::set.mode: Invalid sensor mode.');
            else
                sensor.mode = mode;
                
                if ~strcmp(class(mode),'DeviceMode.Default') && sensor.connectedToBrick 
                    try
                        sensor.setMode(mode);  % Update physical brick's mode parameter
                    catch
                        % Ignore
                    end
                end
            end
        end
        
        function set.debug(sensor, debug)
            % Check if debug is valid and set sensor.debug if it is.
            if ~isBool(debug)
                error('Sensor::set.debug: Given parameter is not a bool.');
            end
            
            sensor.debug = str2bool(debug);
        end
        
        function set.port(sensor, port)
            if ~isPortStrValid(class(sensor),port)
                error('Sensor::set.port: Given port is not a valid port.');
            else
                sensor.port = str2PortParam(class(sensor), port);
            end
        end
        
        function set.commInterface(sensor, comm)
            if ~isCommInterfaceValid(comm)
                error('Sensor::set.commInterface: Handle to commInterface not valid.');
            else
                sensor.commInterface = comm;
            end
        end
        
        function setProperties(sensor, varargin)
            % Sets multiple Sensor properties at once using MATLAB's inputParser.
            %
            % Arguments:
            %     debug (bool) *[OPTIONAL]*
            %     mode (DeviceMode.{Type}) *[OPTIONAL]*
            %
            % Example:
            %     b = EV3(); |br|
            %     b.connect('bt', 'serPort', '/dev/rfcomm0'); |br|
            %     b.sensor1.setProperties('debug', 'on', 'mode', DeviceMode.Color.Ambient); |br|
            %     % Instead of: b.sensor1.debug = 'on'; |br|
            %     %             b.sensor1.mode = DeviceMode.Color.Ambient; |br|
            %
            p = inputParser();
            
            % Set default values
            if sensor.init
                defaultDebug = 0;
                defaultMode = DeviceMode.Default.Undefined;
            else
                defaultDebug = sensor.debug;
                defaultMode = sensor.mode;
            end
            
            % Add parameter
            if sensor.init
                p.addRequired('port');
            end
            p.addOptional('debug', defaultDebug);
            p.addOptional('mode', defaultMode);
            
            % Parse...
            p.parse(varargin{:});
            
            % Set properties
            if sensor.init
                sensor.port = p.Results.port;
            end
            sensor.mode = p.Results.mode;
            sensor.debug = p.Results.debug;
        end
        
        %% Getter
        function value = get.value(sensor)
            value = 0;
            defaultMode = -1;
            
            if sensor.connectedToBrick
                value = sensor.getValue(defaultMode);
                if isnan(value)
                    warning('Sensor::get.value: Could not detect sensor at port %d.', ...
                        sensor.port+1);
                    value = 0;
                end
            end
        end
        
        function conn = get.physicalSensorConnected(sensor)
            currentType = sensor.type;
            conn = (currentType<DeviceType.Unknown && ... 
                (currentType~=DeviceType.MediumMotor && currentType~=DeviceType.LargeMotor));
        end
        
        function sensorType = get.type(sensor)
            if sensor.connectedToBrick
                [sensorType, ~] = sensor.getTypeMode(); 
            else
                sensorType = DeviceType.Unknown;
            end
        end
        
        %% Display
        function display(sensor)
            displayProperties(sensor); 
        end
    end
    
    methods (Access = private)  % Private brick functions that are wrapped by dependent params
        function setMode(sensor, mode)
            if ~sensor.connectedToBrick
                error('Sensor::getTachoCount: Sensor-Object not connected to comm handle.');
            elseif ~sensor.physicalSensorConnected
                error('Sensor::getTachoCount: No physical sensor connected to Port %d',...
                       sensor.port+1);
            end
            
            sensor.commInterface.inputReadSI(0, sensor.port, mode);  % Reading a value implicitly
                                                             % sets the mode.
            
            if sensor.debug
                fprintf('(DEBUG) Sensor::setMode: Called inputReadSI on Port %d.\n',...
                    sensor.port+1);
            end
        end
        
        function val = getValue(sensor, varargin)
            %getValue Reads value from sensor
            % 
            % Notes:
            %  * After changing the mode, sensors initially always send an invalid value. In
            %    this case, the inputReadSI-opCode is sent again to get the correct value.
            %
            
            if ~isempty(varargin)
                defaultMode = varargin{1};
                
                % 5 is numerically highest available number of modes for a sensor(NXT Color)
                if ~isnumeric(defaultMode) || defaultMode > 5
                     error('Sensor::getValue: Invalid mode');
                end
            else
                defaultMode = -1;
            end
            
            if ~sensor.connectedToBrick
                error('Sensor::getValue: Sensor-Object not connected to comm handle.');
            end
            
            if defaultMode ~= -1
                val = sensor.commInterface.inputReadSI(0, sensor.port, defaultMode);
            else
                val = sensor.commInterface.inputReadSI(0, sensor.port, sensor.mode);
            end
            
            if strcmp(class(sensor.mode), 'DeviceMode.Color')
                if sensor.mode == DeviceMode.Color.Col
                    val = Color(val);
                end
            end
            
            % See note
			if isnan(val)
				val = sensor.commInterface.inputReadSI(0, sensor.port, sensor.mode);
                if sensor.debug
                    fprintf('(DEBUG) Sensor::getValue: Called inputReadSI on Port %d.\n',...
                        sensor.port+1);
                end
			end
			
            if sensor.debug
                fprintf('(DEBUG) Sensor::getValue: Called inputReadSI on Port %d.\n',...
                    sensor.port+1);
            end
        end
        
        function status = getStatus(sensor)
           if ~sensor.connectedToBrick
                error('Sensor::getStatus: Sensor-Object not connected to comm handle.');
           end
           
            statusNo = sensor.commInterface.inputDeviceGetConnection(0, sensor.port);
            status = ConnectionType(statusNo);
            
            if sensor.debug
                fprintf(['(DEBUG) Sensor::getStatus: Called inputDeviceGetConnection on ' ,...
                         'Port %d.\n'], sensor.port+1);
            end
        end
        
        function [type,mode] = getTypeMode(sensor)
           if ~sensor.connectedToBrick
                error('Sensor::getTypeMode: Sensor-Object not connected to comm handle.');
           end
           
            [typeNo,modeNo] = sensor.commInterface.inputDeviceGetTypeMode(0, sensor.port);
            type = DeviceType(typeNo);
            try
                mode = DeviceMode(type,modeNo);
            catch ME
                mode = DeviceMode.Default.Undefined;
            end
            
            if sensor.debug
                fprintf(['(DEBUG) Sensor::getStatus: Called inputDeviceGetConnection on ' ,...
                         'Port %d.\n'], sensor.port+1);
            end
        end
        
    end
    
    methods (Access = ?EV3)
        function connect(sensor,commInterface)
            %connect Connects Sensor-object to physical brick
            
            if sensor.connectedToBrick
                if isCommInterfaceValid(sensor.commInterface)
                    error('Sensor::connect: Sensor-Object already has a comm handle.');
                else
                    warning(['Sensor::connect: Sensor.connectedToBrick is set to ''True'', but ',...
                        'comm handle is invalid. Deleting invalid handle and ' ,...
                        'resetting Sensor.connectedToBrick now...']);
                    
                    sensor.commInterface = 0;
                    sensor.connectedToBrick = false;
                    
                    error('Sensor::connect: Disconnected due to internal error.');
                end
            end
            
            sensor.commInterface = commInterface;
            sensor.connectedToBrick = true;
            
            if sensor.debug
                fprintf('(DEBUG) Sensor-Object connected to comm handle.\n');
            end
        end
        
        function disconnect(sensor)
            %disconnect Disconnects Sensor-object from physical brick
            
            sensor.commInterface = 0; % Note: actual deleting is done in EV3::disconnect.
            sensor.connectedToBrick = false;
        end
        
        function resetPhysicalSensor(sensor)
            if ~sensor.connectedToBrick || ~sensor.physicalSensorConnected
                return
            end
            
            sensor.mode = DeviceMode(sensor.type, uint8(0));
            sensor.reset;
        end
    end
end
