classdef Motor < MaskedHandle & dynamicprops
    % High-level class to work with motors.
    %
    % This class is supposed to ease the use of the brick's motors. It is possible to set all
    % kinds of parameters, request the current status of the motor ports and of course send 
    % commands to the brick to be executed on the respective port. 
    %
    % Notes:
    %     * You don't need to create instances of this class. The EV3-class automatically creates
    %       instances for each motor port, and you can work with them via the EV3-object. 
    %     * The Motor-class represents motor ports, not individual motors!
    %
    % Attributes:
    %    power (numeric in [-100, 100]): Power level of motor in percent. *[WRITABLE]*
    %    speedRegulation (bool): Speed regulation turned on or off. When turned on, motor will 
    %        try to 'hold' its speed at given power level, whatever the load. In this mode, the
    %        highest possible speed depends on the load and mostly goes up to around 70-80 (at 
    %        this point, the Brick internally input 100% power). When turned off, motor will 
    %        constantly input the same power into the motor. The resulting speed will be 
    %        somewhat lower, depending on the load. *[WRITABLE]*
    %    smoothStart (numeric s. t. smoothStart+smoothStop < limitValue): Degrees/Time 
    %        indicating how far/long the motor should smoothly start. Depending on limitMode, 
    %        the input is interpreted either in degrees or milliseconds. The first 
    %        {smoothStart}-milliseconds/degrees of limitValue the motor will slowly accelerate 
    %        until reaching its defined speed. *[WRITABLE]*
    %    smoothStop (numeric s. t. smoothStart+smoothStop < limitValue): Degrees/Time 
    %        indicating how far/long the motor should smoothly stop. Depending on limitMode, the 
    %        input is interpreted either in degrees or milliseconds. The last 
    %        [smoothStop]-milliseconds/degrees of limitValue the motor will slowly slow down 
    %        until it has stopped. *[WRITABLE]*
    %    limitValue (numeric>=0): Degrees/Time indicating how far/long the motor should run.
    %        Depending on limitMode, the input is interpreted either in degrees or 
    %        milliseconds. *[WRITABLE]*
    %    limitMode ('Tacho'|'Time'): Mode for motor limit. *[WRITABLE]*
    %    brakeMode ('Brake'|'Coast'): Mode for braking. If 'Coast', the motor will (at 
    %        tacholimit, if ~=0) coast to a stop. If 'Brake', the motor will stop immediately 
    %        (at tacholimit, if ~=0) and hold the brake. *[WRITABLE]*
    %    debug (bool): Debug turned on or off. In debug mode, everytime a command is passed to 
    %        the sublayer ('communication layer'), there is feedback in the console about what 
    %        command has been called. *[WRITABLE]*
    %    isRunning (bool): True if motor is running. *[READ-ONLY]*
    %    tachoCount (numeric): Current tacho count. *[READ-ONLY]*
    %    currentSpeed (numeric): Current speed of motor. If speedRegulation=on this should equal power, 
    %        otherwise it will probably be lower than that. *[READ-ONLY]*
    %    type (DeviceType): Type of connected device if any. *[READ-ONLY]*
    
    
    properties  % Standard properties to be set by user
        % power (numeric in [-100, 100]): Power level of motor in percent. [WRITABLE]
        power;
        
        % speedRegulation (bool): Speed regulation turned on or off. When turned on, motor will 
        %     try to 'hold' its speed at given power level, whatever the load. In this mode, the
        %     highest possible speed depends on the load and mostly goes up to around 70-80 (at 
        %     this point, the Brick internally input 100% power). When turned off, motor will 
        %     constantly input the same power into the motor. The resulting speed will be 
        %     somewhat lower, depending on the load. [WRITABLE]
        speedRegulation;
        
        % smoothStart (numeric s. t. smoothStart+smoothStop < limitValue): Degrees/Time 
        %     indicating how far/long the motor should smoothly start. Depending on limitMode, 
        %     the input is interpreted either in degrees or milliseconds. The first 
        %     {smoothStart}-milliseconds/degrees of limitValue the motor will slowly accelerate 
        %     until reaching its defined speed. [WRITABLE]
        smoothStart;
        
        % smoothStop (numeric s. t. smoothStart+smoothStop < limitValue): Degrees/Time 
        %     indicating how far/long the motor should smoothly stop. Depending on limitMode, the 
        %     input is interpreted either in degrees or milliseconds. The last 
        %     [smoothStop]-milliseconds/degrees of limitValue the motor will slowly slow down 
        %     until it has stopped. [WRITABLE]
        smoothStop;
        
        % limitValue (numeric>=0): Degrees/Time indicating how far/long the motor should run.
        %     Depending on limitMode, the input is interpreted either in degrees or 
        %     milliseconds. [WRITABLE]
        % See also MOTOR.LIMITMODE 
        limitValue;  
        
        % limitMode ('Tacho'|'Time'): Mode for motor limit. [WRITABLE]
        % See also MOTOR.SMOOTHSTART, MOTOR.SMOOTHSTOP, MOTOR.LIMITMODE
        limitMode;
        
        % brakeMode ('Brake'|'Coast'): Mode for braking. If 'Coast', the motor will (at 
        %     tacholimit, if ~=0) coast to a stop. If 'Brake', the motor will stop immediately 
        %     (at tacholimit, if ~=0) and hold the brake. [WRITABLE]
        brakeMode;
        
        % debug (bool): Debug turned on or off. In debug mode, everytime a command is passed to 
        %     the sublayer ('communication layer'), there is feedback in the console about what 
        %     command has been called. [WRITABLE]
        debug;
    end
    
    properties (Dependent)  % Read-only parameters to be read directly from physical brick
        % isRunning (bool): True if motor is running. [READ-ONLY]
        isRunning; 
        
        % tachoCount (numeric): Current tacho count. [READ-ONLY]
        tachoCount;
        
        % currentSpeed (numeric): Current speed of motor. If speedRegulation=on this should 
        %     equal power, otherwise it will probably be lower than that. [READ-ONLY]
        % See also MOTOR.SPEEDREGULATION
        currentSpeed;
        
        % type (DeviceType): Type of connected device if any. [READ-ONLY]
        type;
    end
    
    properties (Hidden, Access = private)  % Hidden properties for internal use only 
        % commInterface (CommunicationInterface): Commands are created and sent via the 
        %     communication interface class.
        commInterface; 
        
        % port (string): Motor port. This is only the string representation of the motor port 
        %     to work with. Internally, either MotorPort-, MotorBitfield- or MotorInput-member 
        %     will be used.
        port; 
        
        % brakeMode_ (BrakeMode): Byte value, corresponding to brakeMode, that will be sent to the brick
        %     brakeMode is an actual parameter on the brick. To avoid inconsistencies with other
        %     modi and to prettify the output, a string representing it is saved. In order to avoid
        %     using string comparisons each time it is used, the corresponding value, that is going 
        %     to be sent, is saved (hidden from the user).
        % See also BRAKEMODE
        brakeMode_;
        
        % init (bool): Indicates init-phase (i.e. constructor is running).
        init = true;
        
        % connectedToBrick (bool): True if virtual brick is connected to physical brick.
        connectedToBrick = false;
        
        % state (MotorState): State-struct consisting of several special Motor-flags
        % See also MOTORSTATE
        state = MotorState();
    end
    
    properties (Hidden, Dependent, Access = private)  % Hidden, dependent properties for internal use only
        % portNo (PortNo): Internal number of motor port.
        %     - Port 'A': 0
        %     - Port 'B': 1
        %     - Port 'C': 2
        %     - Port 'D': 3
        % See also PORTNO
        portNo;
        
        %portInput (PortInput): Internal number of motor port if accessed via input-opCodes 
        %    - Port 'A': 16
        %    - Port 'B': 17
        %    - Port 'C': 18
        %    - Port 'D': 19
        % See also PORTINPUT
        portInput;
        
        %isSynced (bool): True if motor is running in synced mode
        isSynced;
        
        %physicalMotorConnected (bool): True if physical motor is connected to this port
        physicalMotorConnected;
        
        %internalTachoCount (numeric): internal tacho counter used for positioning the motor with a limit
        internalTachoCount;
    end
    
    methods  % Standard methods
        %% Constructor
        function motor = Motor(varargin)
            % Sets properties of Motor-object and indicates end of init-phase when it's done.
            %
            % Notes:
            %     * input-arguments will directly be handed to Motor.setProperties
            %
            % Arguments:
            %     varargin: see setProperties(motor, varargin)
            %
            
            motor.setProperties(varargin{:});
            motor.init = false;
        end
        
        %% Brick functions
        function start(motor)
            % Starts the motor
            %
            % Notes:
            %     * Right now, alternatingly calling this function with and without tacho limit
            %       may lead to unexpected behaviour. For example, if you run the motor without
            %       a tacholimit for some time using Coast, then stop using Coast, and then try 
            %       to run the with a tacholimit, it will stop sooner or later than expected, 
            %       or may not even start at all. 
            %     * After calling one of the functions to control the motor with some kind of 
            %       limit (which is done if limit~=0), the physical brick's power/speed value for
            %       starting without a limit (i.e. if limit==0) is reset to zero. So if you want 
            %       to control the motor without a limit after doing so with a limit, you would 
            %       have to set the power manually to the desired value again. (I don't really 
            %       know if this is deliberate or a bug, and at this point, I'm too afraid to ask.)
            %       To avoid confusion, this is done automatically in this special case.
            %       However, this does not even work all the time. If motor does not
            %       start, call stop() and setPower() manually. :/
            % 
            
            % Check connection and if motor is already running
            if ~motor.connectedToBrick
                error('Motor::start: Motor-Object not connected to comm handle.');
            elseif ~motor.physicalMotorConnected
                error('Motor::start: No physical motor connected to Port %s',...
                       port2str('Motor', motor.port));
            elseif motor.isRunning
                error('Motor::start: Motor is already running!');
            end
            
            % If motor has been started synced with another, and it stopped 'itself' (when
            % using a tacholimit), the sync cache has to be deleted (otherwise, syncedStop
            % would do so)
            if motor.isSynced
                % Retrieve and delete former slave
                if length(findprop(motor, 'slave'))==1 
                    syncMotor = motor.slave;
                    delete(motor.findprop('slave'));
                    delete(syncMotor.findprop('master'));
                else
                    syncMotor = motor.master;
                    delete(motor.findprop('master'));
                    delete(syncMotor.findprop('slave'));
                end
                
                % Reset state
                motor.applyState();
                syncMotor.applyState();
                
                % Send power on next set
                if motor.state.sendPowerOnSet
                    motor.state.sendOnStart = bitset(motor.state.sendOnStart, SendOnStart.Power, 1);
                end
                if syncMotor.state.sendPowerOnSet
                    syncMotor.state.sendOnStart = bitset(syncMotor.state.sendOnStart, SendOnStart.Power, 1);
                end
                
                % Better safe than sorry
                motor.internalReset();  
                syncMotor.internalReset();
            end
            
            % If the motor coasts into its stops, the internal tachocount has to be reset 
            % before each start for it to behave predictable
            if motor.brakeMode_ == BrakeMode.Coast || motor.internalTachoCount ~= 0
                motor.internalReset();
            end

            % Call appropriate function in commInterface depending on limitValue and limitMode
            if motor.limitValue==0
                if motor.state.sendOnStart > 0
                    % If stop-flag is set: call stop() and reset flag
                    if bitget(motor.state.sendOnStart, SendOnStart.Stop)
                        motor.stop(); 
                        motor.state.sendOnStart = bitset(motor.state.sendOnStart, SendOnStart.Stop, 0);
                    end
                    
                    % If power-flag is set: call setPower() and reset flag if successful
                    if bitget(motor.state.sendOnStart, SendOnStart.Power)
                        success = motor.setPower(motor.power);
                        if ~success
                            motor.state.sendOnStart = bitset(motor.state.sendOnStart, SendOnStart.Power, 1);
                        else
                            motor.state.sendOnStart = bitset(motor.state.sendOnStart, SendOnStart.Power, 0);
                        end
                    end
                    
                end
                
                motor.commInterface.outputStart(0, motor.port);
                
                if motor.debug
                    fprintf('(DEBUG) Motor::start: Called outputStart on Port %s\n', port2str('Motor', motor.port));
                end
                motor.state.startedNotBusy = true;
            else
                limit = motor.limitValue - (motor.smoothStart + motor.smoothStop);
                if limit < 0
                    error(['Motor::start: smoothStart/Stop invalid. ' ,...
                        'smoothStart + smoothStop has to be smaller than limitValue.']);
                end
                
                if strcmpi(motor.limitMode, 'Tacho')
                    if motor.speedRegulation
                        motor.commInterface.outputStepSpeed(0, motor.port, motor.power,...
                            motor.smoothStart, limit, motor.smoothStop,...
                            motor.brakeMode_);
                        
                        if motor.debug
                            fprintf('(DEBUG) Motor::start: Called outputStepSpeed on Port %s\n',...
                                    port2str('Motor', motor.port));
                        end
                    else
                        motor.commInterface.outputStepPower(0, motor.port, motor.power,...
                            motor.smoothStart, limit, motor.smoothStop,...
                            motor.brakeMode_);
                        
                        if motor.debug
                            fprintf('(DEBUG) Motor::start: Called outputStepPower on Port %s\n',...
                                    port2str('Motor', motor.port));
                        end
                    end
                elseif strcmpi(motor.limitMode, 'Time')
                    if motor.speedRegulation
                        motor.commInterface.outputTimeSpeed(0, motor.port, motor.power,...
                            motor.smoothStart, limit, motor.smoothStop,...
                            motor.brakeMode_);
                        
                        if motor.debug
                            fprintf('(DEBUG) Motor::start: Called outputTimeSpeed on Port %s\n',...
                                    port2str('Motor', motor.port));
                        end
                    else
                        motor.commInterface.outputTimePower(0, motor.port, motor.power,...
                            motor.smoothStart, limit, motor.smoothStop,...
                            motor.brakeMode_);
                        
                        if motor.debug
                            fprintf('(DEBUG) Motor::start: Called outputTimePower on Port %s\n',...
                                    port2str('Motor', motor.port));
                        end
                    end
                end
            end
        end
        
        function stop(motor)
            % Stops the motor
            
            if ~motor.connectedToBrick
                error('Motor::stop: Motor-Object not connected to comm handle.');
            elseif ~motor.physicalMotorConnected
                error('Motor::stop: No physical motor connected to Port %s',...
                       port2str('Motor', motor.port));
            elseif motor.isSynced && motor.isRunning
                error(['Motor::stop: Motor is running synchronized with another motor. ' ,...
                       'Use ''syncedStop'' on the ''master''-motor.']);
            end
            
            motor.commInterface.outputStop(0, motor.port, motor.brakeMode_);
            
            if motor.debug
                fprintf('(DEBUG) Motor::stop: Called outputStop on Port %s\n', port2str('Motor', motor.port));
            end
            
            motor.state.startedNotBusy = false;
        end
        
        function syncedStart(motor, syncMotor, varargin)
            % Starts this motor synchronized with another
            %
            % This motor acts as a 'master', meaning that the synchronized control is done via
            % this one. When syncedStart is called, the master sets some of the slave's 
            % (syncMotor) properties to keep it consistent with the physical brick. So, for 
            % example, changing the power on the master motor will take effect
            % on the slave as soon as this method is called. 
            % The following parameters will be affected on the slave: power, brakeMode,
            % limitValue, speedRegulation
            %
            % Arguments:
            %     syncMotor (Motor): the motor-object to sync with
            %     turnRatio (numeric in [-200,200]): *[OPTIONAL]* |br| (Excerpt of Firmware-comments, in c_output.c): 
            %         "Turn ratio is how tight you turn and to what direction you turn. 
            %             * 0 value is moving straight forward
            %             * Negative values turn to the left
            %             * Positive values turn to the right
            %             * Value -100 stops the left motor
            %             * Value +100 stops the right motor
            %             * Values less than -100 makes the left motor run the opposite direction of the right motor (Spin)
            %             * Values greater than +100 makes the right motor run the opposite direction of the left motor (Spin)" 
            %
            % Notes:
            %     * This is right now a pretty 'heavy' function, as it tests if both motors are
            %       connected AND aren't running, wasting four packets, keep that in mind
            %     * It is necessary to call syncedStop() and not stop() for stopping the motors 
            %       (otherwise the sync-state cannot be exited correctly)
            %
            % Example:
            %     b = EV3(); |br|
            %     b.connect('usb'); |br|
            %     m = b.motorA; |br|
            %     slave = b.motorB; |br|
            %     m.power = 50; |br|
            %     m.syncedStart(slave); |br|
            %     % Do stuff
            %     m.syncedStop(); |br|
            %
            
            turnRatio = 0;
            
            % Check parameters
            if ~isDeviceValid('Motor', syncMotor)
                error('Motor::syncedStart: Given motor to sync with is not a valid motor object.');
            elseif ~isempty(varargin)
                if length(varargin)~=2
                    error(['Motor::syncedStart: Wrong number of input arguments. ' ,...
                           'Possible input: ''turnRatio'', value (with value in [-200,200])']); 
                end
                parameter = varargin{1};
                turnRatio = varargin{2};
                if ~strcmpi(parameter, 'turnRatio') || ~isnumeric(turnRatio) || ...
                        turnRatio<-200 || turnRatio > 200
                    error(['Motor::syncedStart: Wrong format of input arguments. Possible ',...
                           'input: ''turnRatio'', value (with value in [-200,200])']); 
                end
            end
            
            % Check connection and motor parameter
            if ~motor.connectedToBrick || ~syncMotor.connectedToBrick
                error('Motor::syncedStart: Motor-Object not connected to comm handle.');
            elseif ~motor.physicalMotorConnected || ~syncMotor.physicalMotorConnected
                error('Motor::syncedStart: No physical motor connected to Port %s or %s.',...
                    port2str('Motor', motor.port), port2str('Motor', syncMotor.port));
            elseif motor.speedRegulation
                error(['Motor::syncedStart: Cannot run motors synchronized if ',...
                    'speedRegulation is turned on.']);
            elseif motor.isRunning || syncMotor.isRunning
                error('Motor::syncedStart: One of the motors is already running!');
            end
            
%             if motor.power == 0
%                 warning('Motor::syncedStart: Synchronized motors starting with power=0.');
%             end
            
            % If the motor coasts into its stops, the internal tachocount has to be reset 
            % before each start for it to behave predictable
            if motor.brakeMode_ == BrakeMode.Coast || motor.internalTachoCount ~= 0
                motor.internalReset();
                syncMotor.internalReset();
            end
            
            if motor.state.sendOnStart > 0
                % If stop-flag is set: call stop() and reset flag
                if bitget(motor.state.sendOnStart, SendOnStart.Stop)
                    motor.stop(); 
                    motor.state.sendOnStart = bitset(motor.state.sendOnStart, SendOnStart.Stop, 0);
                end
            end
            
            % Cache old values to make it possible to reset them on syncedStop
            % Note: the existence of 'slave' is also used to determine whether motor is 
            %       running synchronized or not, see get.isSynced()
            motor.addProperty(syncMotor, 'slave', true);
            syncMotor.addProperty(motor, 'master', true);
            
            motor.saveState();
            syncMotor.saveState();
            
            % Disable immediate sending of new power values
            motor.state.sendPowerOnSet = false;
            syncMotor.state.sendPowerOnSet = false;
            
            % Keep 'slave'-motor synchronized
            syncMotor.speedRegulation = false;
        	syncMotor.limitValue= motor.limitValue;
            syncMotor.brakeMode = motor.brakeMode;
            syncMotor.power = motor.power;
            
            if strcmpi(motor.limitMode, 'Tacho')
               motor.commInterface.outputStepSync(0, motor.port+syncMotor.port, ...
                                              motor.power, turnRatio, ...
                                              motor.limitValue, motor.brakeMode_);
               if motor.debug
                   fprintf(['(DEBUG) SyncMotor::syncedStart: Called outputStepSync on ' ,...
                           'Ports %s and %s.\n'], port2str('Motor', motor.port), port2str('Motor', syncMotor.port));
               end
            elseif strcmpi(motor.limitMode, 'Time')
                motor.commInterface.outputTimeSync(0, motor.port+syncMotor.port, ...
                                              motor.power, turnRatio, ...
                                              motor.limitValue, motor.brakeMode_); 
               if motor.debug
                   fprintf('(DEBUG) SyncMotor::start: Called outputStepSync on Ports %s and %s.\n',...
                         port2str('Motor', motor.port), port2str('Motor', syncMotor.port));
               end
            end
        end
        
        function syncedStop(motor)
            % Stops both motors previously started with syncedStart.
            %
            % See also MOTOR.SYNCEDSTART
            
            if ~motor.isSynced
                error('Motor::syncedStop: Motor has not been started synchronized with another.');
            else
                % Retrieve synced motor from cache
                if length(findprop(motor, 'slave'))==1 
                    syncMotor = motor.slave;
                    delete(motor.findprop('slave'));
                    delete(syncMotor.findprop('master'));
                else
                    syncMotor = motor.master;
                    delete(motor.findprop('master'));
                    delete(syncMotor.findprop('slave'));
                end
            end 
            
            if ~motor.connectedToBrick || ~syncMotor.connectedToBrick
                error('Motor::syncedStop: Motor-Object not connected to comm handle.');
            elseif ~motor.physicalMotorConnected || ~syncMotor.physicalMotorConnected
                error('Motor::syncedStop: No physical motor connected to either Port %s or %s.',...
                    port2str('Motor', motor.port), port2str('Motor', syncMotor.port));
            end
            
            % Reset state
            motor.applyState();
            syncMotor.applyState();
            
            % Synced stopping
            motor.commInterface.outputStop(0, motor.port+syncMotor.port, motor.brakeMode_);
            
            % On next start, both motors have to send power-opcode again
            if motor.state.sendPowerOnSet
                motor.state.sendOnStart = bitset(motor.state.sendOnStart, SendOnStart.Power, 1);
            end
            if syncMotor.state.sendPowerOnSet
                syncMotor.state.sendOnStart = bitset(syncMotor.state.sendOnStart, SendOnStart.Power, 1);
            end
            
            
            if motor.debug
                fprintf('(DEBUG) Motor::syncedStop: Called outputStop on Ports %s and %s.\n', ...
                    port2str('Motor', motor.port), port2str('Motor', syncMotor.port));
            end
        end
        
        function waitFor(motor)
            % Stops execution of program as long as motor is running
            %
            % Notes:
            %     * (OLD)This one's a bit tricky. The opCode OutputReady makes the brick stop sending
            %       responses until the motor has stopped. For security reasons, in this toolbox 
            %       there is an internal timeout for receiving messages from the brick. It raises
            %       an error if a reply takes too long, which would happen in this case. As a
            %       workaround, there is an infinite loop that catches errors from outputReady and
            %       continues then, until outputReady will actually finish without an error.
            %     * (OLD)OutputReady (like OutputTest in isRunning) sometimes doesn't work. If 
            %       outputReady returns in less than a second, another while-loop iterates until 
            %       the motor has stopped, this time using motor.isRunning() (this only works as 
            %       long as not both OutputTest and OutputReady are buggy).
            %     * (OLD)Workaround: Poll isRunning (which itself return (speed>0)) until it
            %       is false (No need to check if motor is connected as speed correctly 
            %       returns 0 if it's not)
            
            if ~motor.connectedToBrick
                error('Motor::waitFor: Motor-Object not connected to comm handle.');
            end
            
            %pause(0.1);
            while motor.isRunning
                 pause(0.03);
            end
%             elseif ~motor.limitValue
%                 error(['Motor::waitFor: Motor has no tacho limit. ' ,...
%                          'Can''t reliably determine whether it is running or not.']);
%             end
%             
%             tic;
%             while 1
%                 try
%                     warning('off','all');
%                     
%                     motor.commInterface.outputReady(0, motor.port);
%                     t = toc;
%                     
%                     if t < 1
%                         while motor.isRunning()  % If outputReady correctly returned in less 
%                                                  % than a second, isRunning should instantly send 0.
%                         end
%                     end
%                     
%                     warning('on','all');
%                     break;
%                 catch  % TO DO: Catch only timeout exception, otherwise death and destruction possible (aka infinite loop)
%                     continue;
%                 end
%             end
%             
%             if motor.debug
%                 fprintf('(DEBUG) Motor::waitFor: Called outputReady on Port %s\n', motor.port);
%             end
        end
		
        function internalReset(motor)
            % Resets internal tacho count. Use this if motor behaves weird (i.e. not starting at all, or not correctly
            % running to limitValue)
            %
            % The internal tacho count is used for positioning the motor. When the
            % motor is running with a tacho limit, internally it uses another counter than the
            % one read by tachoCount. This internal tacho count needs to be reset if you 
            % physically change the motor's position or it coasted into a stop. If the motor's
            % brakemode is 'Coast', this function is called automatically.
            %
            % Notes:
            %     * A better name would probably be resetPosition...
            %
            % See also MOTOR.RESETTACHOCOUNT
            
            if ~motor.connectedToBrick
                error(['Motor::internalReset: Motor-Object not connected to brick handle.',...
                       'You have to call motor.connect(brick) first!']);
            elseif ~motor.physicalMotorConnected
                error('Motor::internalReset: No physical motor connected to Port %s',...
                       port2str('Motor', motor.port));
            end
            
            motor.commInterface.outputReset(0, motor.port);
            
            if motor.debug
                fprintf('(DEBUG) Motor::internalReset: Called outputReset on Port %s\n',...
                          port2str('Motor', motor.port));
            end
        end
        
        function resetTachoCount(motor)
            % Resets tachocount
            
            if ~motor.connectedToBrick
                error('Motor::resetTachoCount: Motor-Object not connected to comm handle.');
            elseif ~motor.physicalMotorConnected
                error('Motor::resetTachoCount: No physical motor connected to Port %s',...
                       port2str('Motor', motor.port));
            end
            
            motor.commInterface.outputClrCount(0, motor.port);
            
            if motor.debug
                fprintf('(DEBUG) Motor::resetTachoCount: Called outputClrCount on Port %s\n',...
                          port2str('Motor', motor.port));
            end
        end
        
        function setBrake(motor, brake)
            % Apply or release brake of motor
            %
            % Arguments:
            %     brake (bool): If true, brake will be pulled
            
            if ~isBool(brake)
                error('Motor::setBrake: Given parameter is not a valid bool.');
            else
                brake = str2bool(brake);
            end
            
            
            if brake
                motor.applyBrake();
            else
                motor.releaseBrake();
            end
            
            motor.state.sendOnStart = SendOnStart.Power + SendOnStart.Stop;
        end
        
        %% Setter
        function set.power(motor, power)
            if ~isnumeric(power)
                error('Motor::set.power: Given parameter is not a numeric.');
            elseif power<-100 || power>100
                warning('Motor::set.power: Motor power has to be an element of [-100,100]!');
                error('Motor::set.power: Given motor power is out of bounds.');
            end
            
            motor.power = power;  % Set power parameter.
            
            if motor.state.sendPowerOnSet
                success = motor.setPower(power);
                if ~success
                    motor.state.sendOnStart = bitset(motor.state.sendOnStart, SendOnStart.Power, 1);
                else
                    motor.state.sendOnStart = bitset(motor.state.sendOnStart, SendOnStart.Power, 0);
                end
            end
        end
        
        function set.speedRegulation(motor, speedRegulation)
            if ~isBool(speedRegulation)
                error('Motor::set.speedRegulation: Given parameter is not a bool.');
%             elseif motor.connectedToBrick && motor.physicalMotorConnected
%                 pause(0.5);
%                 if motor.currentSpeed ~= 0
%                     error(['Motor::set.speedRegulation: Cannot change speed regulation while ', ...
%                         'is motor is moving.']);
%                 end
            end
            
            speedRegulation = str2bool(speedRegulation);
            
            if ~isempty(motor.speedRegulation) && (speedRegulation ~= motor.speedRegulation)
                if motor.state.sendPowerOnSet
                    motor.state.sendOnStart = bitset(motor.state.sendOnStart, SendOnStart.Power, 1);
                end
            end
            
            motor.speedRegulation = speedRegulation;
        end
        
        function set.smoothStart(motor, steps)
            if ~isnumeric(steps)
                error('Motor::set.smoothStart: Given parameter is not a numeric.');
            elseif steps<0
                warning('Motor::set.smoothStart: Smooth start steps have to be positive.');
                error('Motor::set.smoothStart: Smooth start steps are out of bounds.');
            end
            
            motor.smoothStart = steps;
        end
        
        function set.smoothStop(motor, steps)
            if ~isnumeric(steps)
                error('Motor::set.smoothStop: Given parameter is not a numeric.');
            elseif steps<0
                warning('Motor::set.smoothStop: Smooth stop steps have to be positive.');
                error('Motor::set.smoothStop: Smooth stop steps are out of bounds.');
            end
            
            motor.smoothStop = steps;
        end
    	
        function set.brakeMode(motor, brakeMode)
            if ~ischar(brakeMode) ||  ...
                (~strcmpi(brakeMode, 'coast') && ~strcmpi(brakeMode, 'brake'))
                error('Motor::set.brakeMode: Given parameter is not a valid brake mode.');
            end 
            
            % If new brakeMode is 'Brake': reset internal tachocount once
            % Note: if new brakeMode is 'Coast', internal tachocount is always reset
            %       right before starting, so it's not necessary here
            if ~motor.init && strcmpi(brakeMode,'Brake') && ... 
                    motor.connectedToBrick && motor.physicalMotorConnected
                motor.internalReset();
            end
            
            
            motor.brakeMode = brakeMode;
            motor.brakeMode_ = str2brake(brakeMode);
        end
        
        function set.limitMode(motor, limitMode)
            if ~ischar(limitMode) ||  ...
                (~strcmpi(limitMode, 'tacho') && ~strcmpi(limitMode, 'time'))
                error('Motor::set.limitMode: Given parameter is not a valid limit mode.');
            end 
            
            motor.limitMode = limitMode;
        end
        
        function set.limitValue(motor, limitValue)
            if ~isnumeric(limitValue)
                error('Motor::set.limitValue: Given parameter is not a numeric.');
            elseif limitValue<0
                warning('Motor::set.limitValue: limitValue has to be positive!');
                error('Motor::set.limitValue: Given limitValue is out of bounds.');
            end    
               
            if limitValue == 0
                motor.state.sendOnStart = SendOnStart.Power;
                if ~isempty(motor.limitValue) && motor.limitValue > 0
                    motor.state.sendOnStart = motor.state.sendOnStart + SendOnStart.Stop;
                end
                motor.state.sendPowerOnSet = true;
            else
                motor.state.sendOnStart = 0;
                motor.state.sendPowerOnSet = false;
            end
            
            motor.limitValue= limitValue;
        end
        
        function set.port(motor, port)
            try
                motor.port = str2PortParam(class(motor), port);
            catch ME
                error('Motor::set.port: Given parameter is not valid port string.');
            end
        end
        
        function set.commInterface(motor, comm)
            if ~isCommInterfaceValid(comm)
                error('Motor::set.commInterface: Handle to commInterface not valid.');
            end
            
            motor.commInterface = comm;
        end
        
        function set.debug(motor, debug)
            if ~isBool(debug)
                error('Motor::set.debug: Given parameter is not a bool.');
            end
            
            motor.debug = str2bool(debug);
        end
        
        function setProperties(motor, varargin)
            % Sets multiple Motor properties at once using MATLAB's inputParser.
            %
            % Arguments:
            %     debug (bool) *[OPTIONAL]*
            %     smoothStart (numeric in [0, limitValue]) *[OPTIONAL]*
            %     smoothStop (numeric in [0, limitValue]) *[OPTIONAL]*
            %     speedRegulation (bool) *[OPTIONAL]*
            %     brakeMode ('Coast'|'Brake') *[OPTIONAL]*
            %     limitMode ('Time'|'Tacho') *[OPTIONAL]*
            %     limitValue (numeric > 0) *[OPTIONAL]*
            %     power (numeric in [-100,100]) *[OPTIONAL]*
            %     batteryMode ('Voltage'|'Percentage') *[OPTIONAL]*
            %
            % Example:
            %     b = EV3(); |br|
            %     b.connect('bt', 'serPort', '/dev/rfcomm0'); |br|
            %     b.motorA.setProperties('debug', 'on', 'power', 50, 'limitValue', 720, 'speedRegulation', 'on'); |br|
            %     % Instead of: b.motorA.debug = 'on'; |br| 
            %     %             b.motorA.power = 50; |br|
            %     %             b.motorA.limitValue = 720; |br|
            %     %             b.motorA.speedRegulation = 'on'; |br|
            %
            
            p = inputParser();
            p.KeepUnmatched = 1;
            
            % Set default values
            if motor.init
                defaultDebug = 0;
                defaultSpeedReg = 0;
                defaultBrakeMode = 'Coast';
                defaultLimitMode = 'Tacho';
                defaultLimit = 0;
                defaultPower = 0;
                defaultSmoothStart = 0;
                defaultSmoothStop = 0;
            else
                defaultDebug = motor.debug;
                defaultSpeedReg = motor.speedRegulation;
                defaultBrakeMode = motor.brakeMode;
                defaultLimitMode = motor.limitMode;
                defaultLimit = motor.limitValue;
                defaultPower = motor.power;
                defaultSmoothStart = motor.smoothStart;
                defaultSmoothStop = motor.smoothStop;
            end
            
            % Add parameter
            if motor.init
                p.addRequired('port');
            end
            p.addOptional('debug', defaultDebug);
            p.addOptional('speedRegulation', defaultSpeedReg);
            p.addOptional('brakeMode', defaultBrakeMode)
            p.addOptional('limitMode', defaultLimitMode);
            p.addOptional('limitValue', defaultLimit);
            p.addOptional('power', defaultPower);
            p.addOptional('smoothStart', defaultSmoothStart);
            p.addOptional('smoothStop', defaultSmoothStop);
            
            % Parse...
            p.parse(varargin{:});
            
            % Set properties
            if motor.init
               motor.port = p.Results.port; 
            end
            motor.power = p.Results.power;
            motor.limitValue= p.Results.limitValue;
            motor.limitMode = p.Results.limitMode;
            motor.brakeMode = p.Results.brakeMode;
            motor.debug = p.Results.debug;
            motor.speedRegulation = p.Results.speedRegulation;
            motor.smoothStart = p.Results.smoothStart;
            motor.smoothStop = p.Results.smoothStop;
        end
        
        %% Getter
        function portNo = get.portNo(motor)
            portNo = bitfield2port(motor.port);
        end
        
        function portInput = get.portInput(motor)
            portInput = bitfield2input(motor.port);
        end
        
        function cnt = get.tachoCount(motor)
            cnt = 0;
            if motor.connectedToBrick
                cnt = motor.getTachoCount();
                if isnan(cnt)
                    warning('Motor::get.tachoCount: Could not detect motor at port %s.', ...
                        port2str('Motor', motor.port));
                    cnt = 0;
                end
            end
        end
        
        function cnt = get.internalTachoCount(motor)
            cnt = 0;
            if motor.connectedToBrick
                cnt = motor.getInternalTachoCount();
                if isnan(cnt)
                    warning('Motor::get.internalTachoCount: Could not detect motor at port %s.', ...
                        port2str('Motor', motor.port));
                    cnt = 0;
                end
            end
        end
        
        function speed = get.currentSpeed(motor)
            speed = 0;
            if motor.connectedToBrick
                speed = motor.getSpeed();
                if isnan(speed)
                    warning('Motor::get.currentSpeed: Could not detect motor at port %s.', ...
                        port2str('Motor', motor.port));
                    speed = 0;
                end
            end
        end
        
        function running = get.isRunning(motor)
            running = 0;
            
            if motor.connectedToBrick
                busyFlag = motor.getBusyFlag();
            else
                busyFlag = 0;
            end
            
            assert(~(motor.state.startedNotBusy && busyFlag));
            running = motor.state.startedNotBusy || busyFlag;
        end
        
        function synced = get.isSynced(motor)
            synced = (length(findprop(motor, 'slave'))==1 || ...
                      length(findprop(motor, 'master'))==1); 
        end
        
        function motorType = get.type(motor)
            if motor.connectedToBrick
                [motorType, ~] = motor.getTypeMode();
            else
                motorType = DeviceType.Unknown;
            end
        end
        
        function conn = get.physicalMotorConnected(motor)
            currentType = motor.type;
            conn = (currentType==DeviceType.MediumMotor || currentType==DeviceType.LargeMotor);
        end
        
        %% Display
        function display(motor)
            displayProperties(motor); 
        end
    end
    
    methods (Access = private)  % Private functions that directly interact with commLayer
        function success = setPower(motor, power)
            %setPower Sets given power value on the physical Brick.
            %
            % Notes:
            %     * If motor is running with a limit, calling outputSpeed/outputPower, to
            %       manually set the power on the physical brick, would stop the motor and adopt
            %       the new power value on next start. To avoid this, the motor could be 'restarted'
            %       with the new value instantly. However, this sometimes leads to unexpected behaviour.
            %       Therefore, if motor is running with a limit, setPower aborts with a warning.
            % 
            % Returns:
            %     success (bool): if true, power has successfully been set
            
            if ~motor.connectedToBrick || ~motor.physicalMotorConnected
%                 error('Motor::getTachoCount: Motor-Object not connected to comm handle.');
                success = false;
                return;
            end
            
            % assert(motor.physicalMotorConnected==true);
            assert(motor.limitValue==0);
            
            if motor.speedRegulation
                motor.commInterface.outputSpeed(0, motor.port, power);

                if motor.debug
                    fprintf('(DEBUG) Motor::setPower: Called outputSpeed on Port %s\n', port2str('Motor', motor.port));
                end
            else
                motor.commInterface.outputPower(0, motor.port, power);

                if motor.debug
                    fprintf('(DEBUG) Motor::setPower: Called outputPower on Port %s\n', port2str('Motor', motor.port));
                end
            end
            %motor.sendPowerOnNextStart = false;
            success = true;
            return;
        end
        
        function setMode(motor, mode)  %% DEPRECATED
            if ~motor.connectedToBrick
                error('Motor::getTachoCount: Motor-Object not connected to comm handle.');
            elseif ~motor.physicalMotorConnected
                error('Motor::getTachoCount: No physical motor connected to Port %s',...
                       port2str('Motor', motor.port));
            end
            
            motor.commInterface.inputReadSI(0, motor.portInput, mode);  % Reading a value implicitly 
                                                                        % sets the mode.

            if motor.debug
                fprintf('(DEBUG) Motor::setMode: Called inputReadSI on Port %s\n',...
                         port2str('Motor', motor.port));
            end        
        end
        
        function [type,mode] = getTypeMode(motor)
            if ~motor.connectedToBrick
                error('Motor::getTypeMode: Motor-Object not connected to comm handle.');
            end
            
            [typeNo,modeNo] = motor.commInterface.inputDeviceGetTypeMode(0, motor.portInput);
            type = DeviceType(typeNo);
            mode = DeviceMode(type,modeNo);
            
            if motor.debug
                fprintf('(DEBUG) Motor::getTypeMode: Called inputDeviceGetTypeMode on Port %s\n',...
                         port2str('Motor', motor.port));
            end
        end
        
        function status = getStatus(motor)
            if ~motor.connectedToBrick
                error('Motor::getStatus: Motor-Object not connected to comm handle.');
            end
            
            statusNo = motor.commInterface.inputDeviceGetConnection(0, motor.portInput);
            status = ConnectionType(statusNo);
            
            if motor.debug
                fprintf('(DEBUG) Motor::getStatus: Called inputDeviceGetConnection on Port %s\n',...
                         port2str('Motor', motor.port));
            end
        end
        
        function cnt = getTachoCount(motor)
            if ~motor.connectedToBrick
                error('Motor::getTachoCount: Motor-Object not connected to comm handle.');
            end
            
            cnt = motor.commInterface.outputGetCount(0, motor.portNo);
            if motor.debug
                fprintf('(DEBUG) Motor::getTachoCount: Called outputGetCount on Port %s\n', port2str('Motor', motor.port));
            end
        end
        
        function cnt = getInternalTachoCount(motor)
            [~, cnt] = motor.commInterface.outputRead(0, motor.portNo);
            if motor.debug
                fprintf('(DEBUG) Motor::getInternalTachoCount: Called outputRead on Port %s\n', port2str('Motor', motor.port));
            end
        end
        
        function speed = getSpeed(motor)
            if ~motor.connectedToBrick
                error('Motor::getSpeed: Motor-Object not connected to comm handle.');
            end
            
            speed = motor.commInterface.inputReadSI(0, motor.portInput, DeviceMode.Motor.Speed);
            
            if motor.debug
                fprintf('(DEBUG) Motor::getSpeed: Called inputReadSI on Port %s\n', port2str('Motor', motor.port));
            end
        end
        
        function busy = getBusyFlag(motor)
            %getMotorStatus Returns whether motor is busy or not. 
            %
            % Notes:
            %     * This *mostly* works. Sometimes this falsely returns 0 if isRunning() gets 
            %       called immediately after starting the motor.
            %     * Busy is set to true if motor is running with tacholimit or synced
            %
            
            if ~motor.connectedToBrick
                error('Motor::getBusyFlag: Motor-Object not connected to comm handle.');
            end
            
            busy = motor.commInterface.outputTest(0, motor.port);
            
            if motor.debug
                fprintf('(DEBUG) Motor::getBusyFlag: Called outputTest on Port %s\n', port2str('Motor', motor.port));
            end
        end
        
        function applyBrake(motor)
            if ~motor.connectedToBrick
                error('Motor::applyBrake: Motor-Object not connected to comm handle.');
            elseif ~motor.physicalMotorConnected
                error('Motor::applyBrake: No physical motor connected to Port %s',...
                       port2str('Motor', motor.port));
            elseif motor.currentSpeed~=0
                error('Motor::applyBrake: Can''t apply brake because Motor is moving');
            end
            
            if motor.speedRegulation 
                motor.commInterface.outputPower(0, motor.port, 0);
            else
                motor.commInterface.outputSpeed(0, motor.port, 0);
            end
            motor.commInterface.outputStart(0, motor.port);
            motor.commInterface.outputStop(0, motor.port, BrakeMode.Brake);
            
            if motor.debug
                fprintf(['(DEBUG) Motor::applyBrake: Called outputPower, outputStart and' ,...
                    'outputStop on Port %s\n'], port2str('Motor', motor.port));
            end
        end
        
        function releaseBrake(motor)
            if ~motor.connectedToBrick
                error('Motor::releaseBrake: Motor-Object not connected to comm handle.');
            elseif ~motor.physicalMotorConnected
                error('Motor::releaseBrake: No physical motor connected to Port %s',...
                       port2str('Motor', motor.port));
            elseif motor.currentSpeed~=0
                error('Motor::releaseBrake: Can''t releaseBrake brake because Motor is moving');
            end
            
            if motor.speedRegulation 
                motor.commInterface.outputPower(0, motor.port, 0);
            else
                motor.commInterface.outputSpeed(0, motor.port, 0);
            end
            motor.commInterface.outputStart(0, motor.port);
            motor.commInterface.outputStop(0, motor.port, BrakeMode.Coast);
            
            if motor.debug
                fprintf(['(DEBUG) Motor::releaseBrake: Called outputPower, outputStart and' ,...
                    'outputStop on Port %s\n'], port2str('Motor', motor.port));
            end
        end
    end
    
    methods (Access = private, Hidden = true)
        function saveState(motor)
            %saveState Saves current motor state in dynamic property
            
            meta = motor.findprop('savedState');
            if isempty(meta)
                meta = motor.addprop('savedState');
                meta.Hidden = true;
                meta.Access = 'private';
            end
            
            motor.savedState = motor.state;
        end
        
        function applyState(motor)
            %applyState Sets motor state to saved state and deletes the dynamic property in
            %which the latter is stored
            
            assert(length(motor.findprop('savedState')) ~= 0);
            
            motor.state = motor.savedState;
            delete(motor.findprop('savedState'))
        end
        
        function addProperty(motor, propValue, propName, override)
            override = str2bool(override);
            
            meta = motor.findprop(propName);
            
            if isempty(meta)
                meta = motor.addprop(propName);
                meta.Hidden = true;
                meta.Access = 'private';
            elseif ~override
                error('Motor::addProperty: Motor already has this property.');
            end
            
            motor.(propName) = propValue;
        end
    end
    
    methods (Access = ?EV3)
        function connect(motor,commInterface)
            %connect Connects Motor-object to physical brick.
            %
            % Notes:
            %     * This method is automatically called by EV3.connect()
            %     * This method actually only saves a handle to a Brick-object which has been
            %       created beforehand (probably by an EV3-object). 
            %
            % Arguments:
            %     commInterface (CommunicationInterface): Handle to a communication interface
            %         device
            %
            
            if motor.connectedToBrick
                if isCommInterfaceValid(motor.commInterface)
                    error('Motor::connect: Motor-Object already has a comm handle.');
                else
                    warning(['Motor::connect: Motor.connectedToBrick is set to ''True'', but ',...
                             'comm handle is invalid. Deleting invalid handle and ' ,...
                             'resetting Motor.connectedToBrick now...']);
                         
                    motor.disconnect();
                    
                    error('Motor::connect: Disconnected due to internal error.');
                end
            end
            
            motor.commInterface = commInterface;
            motor.connectedToBrick = true;
            
            if motor.debug
               fprintf('(DEBUG) Motor-Object connected to comm handle.\n'); 
            end
        end
        
        function disconnect(motor)
            %disconnect Disconnects Motor-object from physical brick.
            %
            % Notes:
            %     * This method is automatically called by EV3.disconnect()
            %     * This method actually only sets the property, in which 
            %       the handle to the CommInterface-class was stored, to 0. 
            %
            
            motor.commInterface = 0;
            motor.connectedToBrick = false;
        end
        
        function resetPhysicalMotor(motor)
            %
            if ~motor.connectedToBrick || ~motor.physicalMotorConnected
                return; 
            end
            
            motor.resetTachoCount();
            motor.internalReset();
            motor.setBrake(0);
            %motor.stop();
        end
    end
end
