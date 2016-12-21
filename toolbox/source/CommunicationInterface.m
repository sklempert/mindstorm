% Brick Interface to Lego Minstorms EV3 brick
%
% Methods::
% brick                 Constructor, establishes communications
% delete                Destructor, closes connection
% send                  Send data to the brick
% receive               Receive data from the brick
% 
%
% uiReadVBatt           Returns battery level as a voltage
% uiReadLBatt           Returns battery level as a percentage
%
% drawTest              Shows the drawing capabilities of the brick
%
%
% soundTest     @MMI:   Returns state of speaker
% soundReady	@MMI:   Halts the execution of commands on Brick until speakers are ready
% soundPlayTone         Plays a tone at a volume with a frequency and duration
% soundStopTone @MMI:   Stops current sound playback
%
% beep                  Plays a beep tone with volume and duration
% playThreeTone         Plays three tones one after the other
%
%
% inputDeviceList          @MMI:    Returns list of sensor types on each port
% inputDeviceGetName                Returns the device name at a layer and NO
% inputDeviceGetTypeMode   @MMI:    Returns type and mode of device at a layer and NO
% inputDeviceSetTypeMode   @MMI:    Sets type and mode of device which is recognized by old
%                                   type and mode.
% inputDeviceGetModeName   @MMI:    Returns the device's mode at a layer and NO
% inputDeviceGetConnection @MMI:	Returns the connection type (=sensor type) at a layer and NO
% inputDeviceGetMinMax     @MMI:	Returns the min and max SI value of device at a layer and NO
% inputDeviceGetChanges    @MMI:	Returns positive changes(=button releases) since last clear at a layer and NO
% inputDeviceGetFormat     @MMI:	Returns no. of datasets, returned data type in
%                                   active sensor mode, no. of sensor modes and no. of
%                                   visible sensor modes at a layer and NO
% inputDeviceGetBumps      @MMI:    Returns negatives changes (=button presses) since last clear at a layer and NO
% inputDeviceSymbol                 Returns the symbol for the device at a layer, NO and mode
% inputDeviceClrChanges    @MMI:    Clears changes(&bumps) at a layer and NO
% inputDeviceClrAll                 Clears all the sensor data at a layer
% inputReady               @MMI:    Halts the execution of commands on Brick until given devices are ready
% inputTest                @MMI:    Returns the state of the device at a layer and NO
% inputRead                @MMI:    Reads a connected sensor at a layer, NO, type and mode in percentage
% inputReadSI                       Reads a connected sensor at a layer, NO, type and mode in SI units
%
% plotSensor            Plots a sensor readings over time
% displayColor          Displays the color from a color sensor
%
%
% outputStop            Stops motor at a layer, NOS and brake
% outputStopAll         Stops all the motors
% outputPower           Sets motor output power at a layer, NOS and speed
% outputSpeed     @MMI: Sets motor output speed at a layer, NOS and speed
% outputStart           Starts motor at a layer, NOS and speed
% outputTest            Returns the state of the motor at a layer and NOS
% outputStepSpeed       Moves a motor to set position with layer, NOS, speed, 
%                       ramp up angle, constant angle, ramp down angle and brake
% outputStepPower @MMI: Moves a motor to set position with layer, NOS, power,
%                       ramp up angle, constant angle, ramp down angle and brake
% outputTimeSpeed @MMI: Moves a motor for set time at a layer, NOS, speed,
%                       ramp up time, constant time, ramp down time and brake
% outputTimePower @MMI: Moves a motor for set time at a layer, NOS, power,
%                       ramp up time, constant time, ramp down time and brake
% outputStepSync  @MMI: Moves two motors synchronized at a layer, NOS,
%                       power, turn ratio, tacho limit, and brake 
% outputTimeSync  @MMI: Moves two motors synchronized at a layer, NOS,
%                       power, turn ratio, time limit, and brake 
% outputClrCount        Clears a motor tachometer at a  layer and NOS
% outputGetCount        Returns the tachometer at a layer and NO
% outputReset     @MMI: 
% outputRead      @MMI: 
% outputPolarity  @MMI: Sets a motor's polarity ('rotational direction')
% outputReady     @MMI: Halts the execution of commands on Brick until given
%                       motors have stopped
%
%
% comTest  @MMI:        Returns state of communication adapter of device.
% comReady @MMI:        Halts the execution of commands of Brick until
%                       communication adapter is ready
% comGetBrickName       Returns the name of the brick
% comSetBrickName       Sets the name of the brick
% comGetMACAddress@MMI: Returns the MAC-address of the brick
% comGetBTID      @MMI: Returns BT-address information
%
% mailBoxWrite          Writes a mailbox message from the brick to another device
% fileUpload            Uploads a file to the brick
% fileDownload          Downloads a file from the brick
% listFiles             Lists files on the brick from a directory  
% createDir             Creates a directory on the brick
% deleteFile            Deletes a file from the brick
% writeMailBox          Writes a mailbox message to the brick
% readMailBox           Reads a mailbox message sent from the brick
%
%
% threeToneByteCode     Generates the bytecode for the playThreeTone function 
%
% Example::
%           b = Brick('ioType','usb')
%           b = Brick('ioType','wifi','wfAddr','192.168.1.104','wfPort',5555,'wfSN','0016533dbaf5')
%           b = Brick('ioType','bt','serPort','/dev/rfcomm0')


classdef CommunicationInterface < handle
    
    properties
        % Debug 
        debug;
    end
    
    properties (SetAccess = 'private')
        % IO connection type
        ioType;
        % Bluetooth brick device name
        btDevice = '';
        % Bluetooth brick communication channel
        btChannel = 0;
        % Wifi brick IP address
        wfAddr = '';
        % Wifi brick TCP port
        wfPort = ''; 
        % Brick serial number
        wfSN = ''; 
        % Bluetooth serial port
        serPort;
    end
    
    properties (Hidden, Access = 'private')
        % Connection handle
        conn; 
    end
    
    methods
        function commInterface = CommunicationInterface(varargin) 
             % Brick.Brick Create a Brick object
             %
             % b = Brick(OPTIONS) is an object that represents a connection
             % interface to a Lego Mindstorms EV3 brick.
             %
             % Options::
             %  'debug',D       Debug level, show communications packet
             %  'ioType',P      IO connection type, either usb, wifi or bt
             %  'btDevice',bt   Bluetooth brick device name
             %  'btChannel',cl  Bluetooth connection channel
             %  'wfAddr',wa     Wifi brick IP address
             %  'wfPort',pr     Wifi brick TCP port, default 5555
             %  'wfSN',sn       Wifi brick serial number (found under Brick info on the brick OR through sniffing the UDP packets the brick emits on port 3015)
             %  'serPort',SP    Serial port connection
             %
             % Notes::
             % - Can connect through: usbBrickIO, wfBrickIO, btBrickIO or
             % instrBrickIO.
             % - For usbBrickIO:
             %      b = Brick('ioType','usb')
             % - For wfBrickIO:
             %      b = Brick('ioType','wifi','wfAddr','192.168.1.104','wfPort',5555,'wfSN','0016533dbaf5')
             % - For btBrickIO:
             %      b = Brick('ioType','bt','serPort','/dev/rfcomm0')
             % - For instrBrickIO (wifi)
             %      b = Brick('ioType','instrwifi','wfAddr','192.168.1.104','wfPort',5555,'wfSN','0016533dbaf5')
             % - For instrBrickIO (bluetooth)
             %      b = Brick('ioType','instrbt','btDevice','EV3','btChannel',1)
             
             commInterface.setProperties(varargin{:});
%              % Init the properties
%              opt.debug = 0;
%              opt.btDevice = 'EV3';
%              opt.btChannel = 1;
%              opt.wfAddr = '192.168.1.104';
%              opt.wfPort = 5555;
%              opt.wfSN = '0016533dbaf5';
%              opt.ioType = 'usb';
%              opt.serPort = '/dev/rfcomm0';
%              
%              % Read in the options
%              opt = tb_optparse(opt, varargin);
%              commInterface.debug = opt.debug;
%              commInterface.ioType = opt.ioType;

             try
                 if(strcmp(commInterface.ioType,'usb')) % USB
                    commInterface.conn = usbBrickIO(commInterface.debug);
                 elseif(strcmp(commInterface.ioType,'wifi')) % WiFi
                    commInterface.wfAddr = opt.wfAddr;
                    commInterface.wfPort = opt.wfPort;
                    commInterface.wfSN = opt.wfSN;
                    commInterface.conn = wfBrickIO(commInterface.debug,commInterface.wfAddr,commInterface.wfPort,commInterface.wfSN);
                 elseif(strcmp(commInterface.ioType,'bt')) % Bluetooth
%                     commInterface.serPort = opt.serPort;
                    commInterface.conn = btBrickIO(commInterface.debug,commInterface.serPort);
                 elseif(strcmp(commInterface.ioType,'instrwifi')) % Instrumentation and Control: WiFi 
                    commInterface.wfAddr = opt.wfAddr;
                    commInterface.wfPort = opt.wfPort;
                    commInterface.wfSN = opt.wfSN;
                    commInterface.conn = instrBrickIO(commInterface.debug,'wf',commInterface.wfAddr,commInterface.wfPort,commInterface.wfSN);
                 elseif(strcmp(commInterface.ioType,'instrbt')) % Instrumentation and Control: Bluetooth 
                    commInterface.btDevice = opt.btDevice;
                    commInterface.btChannel = opt.btChannel;
                    commInterface.conn = instrBrickIO(commInterface.debug,'bt',commInterface.btDevice,commInterface.btChannel);
                 end
             catch ME
                 commInterface.conn = [];
                 rethrow(ME);
             end
        end
        
        function delete(brick)
            % Brick.delete Delete the Brick object
            %
            % delete(b) closes the connection to the brick
            
            if isa(brick.conn, 'handle') && isvalid(brick.conn)
                brick.conn.delete();
            end
        end
        
        function set.debug(brick, debug)
            % If debug is set in this layer, also set BrickIO.debug in lower layer
            brick.debug = debug;
            brick.conn.debug = debug;
        end
        
        function setProperties(brick, varargin)
            p = inputParser();
            p.KeepUnmatched = true;
            
            % Set default values
            defaultIOType = 'usb';
            defaultSerPort = '/dev/rfcomm0';
            defaultDebug = false;
            
            % Define anonymous function that will return whether given value in varargin is valid
            %validTypes = ;
            checkIOType = @(x) ismember(x, {'usb', 'bt'});
            checkDebug = @(x) isBool(x);
            
            % Add parameters
            p.addRequired('ioType', checkIOType);
            p.addOptional('serPort', defaultSerPort);
            p.addOptional('debug', defaultDebug, checkDebug);
            
            % Parse input...
            p.parse(varargin{:});
            
            % Set properties
            brick.ioType = p.Results.ioType;
            brick.serPort = p.Results.serPort;
            brick.debug = p.Results.debug;
        end
        
        function send(brick, cmd)
            % Brick.send Send data to the brick
            %
            % Brick.send(cmd) sends a command to the brick through the
            % connection handle.
            %
            % Notes::
            % - cmd is a command object.
            %
            % Example::
            %           b.send(cmd)
            
            % Send the message through the brickIO write function
            brick.conn.write(cmd.msg);
            
            % (MMI) When spamming the brick with commands, at some point, it will start
            % behaving 'strange'. Sometimes, commands will be executed only with 
            % a delay, some commands may even be bypassed. 
            % (Maybe too many commands screw up the brick's internal command queue?..)
            % Temporary workaround: Wait 5ms after each sent packet. 
            % pause(0.005);
            
            % Verbose output
            if brick.debug > 0
               fprintf('sent (hex):    [ ');
               for ii=1:length(cmd.msg)
                   fprintf('%s ',dec2hex(cmd.msg(ii)))
               end
               fprintf(']\n');
               fprintf('sent (dec):    [ ');
               for ii=1:length(cmd.msg)
                   fprintf('%d ',cmd.msg(ii))
               end
               fprintf(']\n');
            end
        end
       
        function rmsg = receive(brick)
            % Brick.receive Receive data from the brick
            %
            % rmsg = Brick.receive() receives data from the brick through
            % the connection handle.
            %
            % Notes: 
            %  - If received packet is corrupt, up to five new packets are read (if all are 
            %    corrupt, an error is thrown) 
            %
            % Example::
            %           rmsg = b.receive()
            %
            
            % Read the message through the brickIO read function
            rmsg = brick.conn.read();
            
            % Check if reply is corrupt or error byte is set
            try
                reply = Command(rmsg);
            catch ME
                corrupt = 1;
                if ~isempty(strfind(ME.identifier, 'CorruptPacket'))
                    % Read packet was corrupt - retry
                    %id = [ID(), ':', 'CorruptPacket'];
                    %warning(id, 'Read corrupt packet. Retrying...');
                    if brick.debug
                        fprintf('received (corrupt) (hex):    [ ');
                        for ii=1:length(rmsg)
                            fprintf('%s ',dec2hex(rmsg(ii)))
                        end
                        fprintf(']\n');
                        fprintf('received (corrupt) (dec):    [ ');
                        for ii=1:length(rmsg)
                            fprintf('%d ',rmsg(ii))
                        end
                        fprintf(']\n');
                    end
                    
                    retries = 5;
                    while corrupt && retries
                        rmsg = brick.conn.read();
                        try
                            reply = Command(rmsg);
                            corrupt = 0;
                        catch
                            retries = retries-1;
                        end
                    end
                end
                
                if corrupt
                    rethrow(ME);
                end
            end
            
            if reply.checkForError()
                msg = 'Error byte is set. The Brick couldn''t handle the last packet';
                id = [ID(), ':', 'CommandError'];
                warning(id, msg);
            end
            
            % Verbose output
            if brick.debug > 0
               fprintf('received (hex):    [ ');
               for ii=1:length(rmsg)
                   fprintf('%s ',dec2hex(rmsg(ii)))
               end
               fprintf(']\n');
               fprintf('received (dec):    [ ');
               for ii=1:length(rmsg)
                   fprintf('%d ',rmsg(ii))
               end
               fprintf(']\n');
            end      
        end
        
        function voltage = uiReadVbatt(brick)
            % Brick.uiReadVbatt Return battery level (voltage)
            % 
            % voltage = uiReadVbatt returns battery level as a voltage. (DATAF)
            %
            % Example::
            %           voltage = b.uiReadVbatt()
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,4,0);
            cmd.opUI_READ_GET_VBATT(0);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            voltage = typecast(uint8(msg(6:9)),'single');           
            if brick.debug > 0
                fprintf('Battery voltage: %.02fV\n', voltage);
            end
        end
        
        function level = uiReadLbatt(brick)
            % Brick.uiReadLbatt Return battery level (percentage)
            % 
            % Brick.uiReadLbatt() returns battery level as a
            % percentage from 0 to 100%. (DATA8)
            %
            % Example::
            %           level = b.uiReadLbatt()
          
            cmd = Command();
            cmd.addHeaderDirectReply(42,1,0);
            cmd.opUI_READ_GET_LBATT(0);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            level = msg(6);
            if brick.debug > 0
                fprintf('Battery level: %d%%\n', level);
            end
        end
        
        function drawTest(brick)
            % Brick.drawTest Draw test shapes
            %
            % Brick.drawTest() shows the drawing capabilities of the brick.
            %
            % Example::
            %           b.drawTest()
            
            cmd = Command();
            cmd.addHeaderDirect(42,4,1);
            % save the UI screen
            cmd.opUI_DRAW_STORE(0);
            % change the led pattern
            cmd.opUI_WRITE_LED(Device.LedGreenFlash);
            % clear the screen (top line still remains with remote cmds)
            cmd.opUI_DRAW_FILLWINDOW(0,0,0);
            % draw four pixels
            cmd.opUI_DRAW_PIXEL(vmCodes.vmFGColor,12,15);
            cmd.opUI_DRAW_PIXEL(vmCodes.vmFGColor,12,20);
            cmd.opUI_DRAW_PIXEL(vmCodes.vmFGColor,18,15);
            cmd.opUI_DRAW_PIXEL(vmCodes.vmFGColor,18,20);
            % draw line
            cmd.opUI_DRAW_LINE(vmCodes.vmFGColor,0,25,vmCodes.vmLCDWidth,25);
            cmd.opUI_DRAW_LINE(vmCodes.vmFGColor,15,25,15,127);
            % draw circle
            cmd.opUI_DRAW_CIRCLE(1,40,40,10);
            % draw rectangle
            cmd.opUI_DRAW_RECT(vmCodes.vmFGColor,70,30,20,20);
            % draw filled cricle
            cmd.opUI_DRAW_FILLCIRCLE(vmCodes.vmFGColor,40,70,10);
            % draw filled rectangle
            cmd.opUI_DRAW_FILLRECT(vmCodes.vmFGColor,70,60,20,20);
            % draw inverse rectangle
            cmd.opUI_DRAW_INVERSERECT(30,90,60,20);
            % change font
            cmd.opUI_DRAW_SELECT_FONT(2);
            % draw text
            cmd.opUI_DRAW_TEXT(vmCodes.vmFGColor,100,40,'EV3');
            % change font
            cmd.opUI_DRAW_SELECT_FONT(1);
            % reprint
            cmd.opUI_DRAW_TEXT(vmCodes.vmFGColor,100,70,'EV3');
            % change font
            cmd.opUI_DRAW_SELECT_FONT(0);
            % reprint
            cmd.opUI_DRAW_TEXT(vmCodes.vmFGColor,100,90,'EV3');
            % voltage string
            cmd.opUI_DRAW_TEXT(vmCodes.vmFGColor,100,110,'v =');
            % store voltage
            cmd.opUI_READ_GET_VBATT(0);
            % print the voltage value (global)
            cmd.opUI_DRAW_VALUE(vmCodes.vmFGColor,130,110,0,5,3);
            % update the window
            cmd.opUI_DRAW_UPDATE;
            % 5 second timer (so you can see the changing LED pattern)
            cmd.opTIMER_WAIT(5000,0);
            % wait for timer
            cmd.opTIMER_READY(0);
            % reset the LED
            cmd.opUI_WRITE_LED(Device.LedGreen);
            % return UI screen
            cmd.opUI_DRAW_RESTORE(0);
            % return
            cmd.opUI_DRAW_UPDATE;
            cmd.addLength();
            brick.send(cmd)
        end
        
        % Implemented @ MMI
        function state = soundTest(brick)
            % Brick.soundTest Test speaker
            %
            % Brick.soundTest tests, if a sound file or tone is beeing
            % played back.
            %
            % Notes::
            % - state is 0 when ready and 1 when busy (playing tone or
            %   sound file). (DATA8)
            %
            % Example::
            %           b.soundTest()
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,1,0);
            cmd.opSOUND_TEST(0);
            cmd.addLength();
            brick.send(cmd);
            % receive the state
            msg = brick.receive()';
            % speaker state is the 6th byte
            state = msg(6);    
        end
        
        % Implemented @ MMI
        function soundReady(brick)
            % Brick.soundReady Wait for speaker
            %
            % Brick.soundReady(layer,nos) halts program until current 
            % sound playback is done by waiting until reply is received.
            %
            % Example::
            %           b.soundReady()
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,0,0);
            cmd.opSOUND_READY();
            cmd.addLength();
            brick.send(cmd);  
            % receive reply 
            brick.receive();           
        end
        
        function soundPlayTone(brick, volume, frequency, duration)  
            % Brick.soundPlayTone Play a tone on the brick
            %
            % Brick.soundPlayTone(volume,frequency,duration) plays a tone at a
            % volume, frequency and duration.
            %
            % Notes::
            % - volume is the tone volume from 0 to 100. (DATA8)
            % - frequency is the tone frequency in Hz from 250 - 10000. (DATA16)
            % - duration is the tone duration in ms. (DATA16)
            %
            % Example:: 
            %           b.soundPlayTone(5,400,500)

            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opSOUND_TONE(volume,frequency,duration);
            cmd.addLength();
            brick.send(cmd);
        end
        
        % Implemented @ MMI
        function soundStopTone(brick)
            % Brick.soundStopTone Stop current sound playback
            %
            % Brick.soundStopTone() stops current sound playbacks.
            %
            % Example::
            %           b.soundStopTone()
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opSOUND_BREAK;
            cmd.addLength();
            brick.send(cmd);            
        end
                 
        function beep(brick,volume,duration)
            % Brick.beep Play a beep on the brick
            %
            % Brick.beep(volume,duration) plays a beep tone with volume and
            % duration.
            %
            % Notes::
            % - volume is the beep volume from 0 to 100, by default 10. (DATA8)
            % - duration is the beep duration in ms, by default 100. (DATA16)
            %
            % Example:: 
            %           b.beep(5,500)
            
            if nargin < 2
                volume = 10;
            end
            if nargin < 3
                duration = 100;
            end
            brick.soundPlayTone(volume, 1000, duration);
        end
        
        function playThreeTones(brick)
            % Brick.playThreeTones Play three tones on the brick
            %
            % Brick.playThreeTones() plays three tones consequentively on
            % the brick with one upload command.
            %
            % Example::
            %           b.playThreeTones();
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opSOUND_TONE(5,440,500);
            cmd.opSOUND_READY();
            cmd.opSOUND_TONE(10,880,500);
            cmd.opSOUND_READY();
            cmd.opSOUND_TONE(15,1320,500);
            cmd.opSOUND_READY();
            cmd.addLength();
            % print message
            fprintf('Sending three tone message ...\n');
            brick.send(cmd);    
        end
        
        % Implemented @ MMI
        function types = inputDeviceList(brick)
            % Brick.inputDeviceList Get an array of sensor types 
            %
            % Brick.inputDeviceList() returns an array of sensor types on 
            % each sensor port.
            %
            % Notes::
            % - types is the 1x4-array of sensor types 
            %
            % Example::
            %           types = b.inputDeviceList();
            %
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,5,0);
            cmd.opINPUT_DEVICE_LIST(4,0,4);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            % return the type array
            types = [msg(6), msg(7), msg(8), msg(9)];
        end
        
        function name = inputDeviceGetName(brick,layer,no)
            % Brick.inputDeviceGetName Get the input device name
            %
            % Brick.inputDeviceGetName(layer,no) returns the name of the
            % device connected.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or port
            %   number minus 1.
            % - name is the device's name (string)
            % 
            % Example::
            %           name = b.inputDeviceGetName(0,SensorPort.Sensor1)
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,12,0);
            cmd.opINPUT_DEVICE_GET_NAME(layer,no,12,0);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            % return the device name
            name = sscanf(char(msg(6:end)),'%s');
        end
        
        % Implemented @ MMI
        function [type, mode] = inputDeviceGetTypeMode(brick,layer,no)
            % Brick.inputDeviceGetTypeMode Get the input device's type and
            % mode
            %
            % Brick.inputDeviceGetTypeMode(layer,no) returns the input device's
            % type and mode, coded as in Device.m, at a layer and NO.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or port
            %   number minus 1.
            % - type,mode are the type and current mode of the device (each DATA8)
            %   -> refer to typedata.rcf for more information
            %
            % Example::
            %          [type,mode] = b.inputDeviceTypeMode(0,SensorPort.Sensor1)
            cmd = Command();
            cmd.addHeaderDirectReply(42,2,0);
            cmd.opINPUT_DEVICE_GET_TYPEMODE(layer,no,0,1);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            % return the type and mode
            type = msg(6);
            mode = msg(7);
        end
        
        % Implemented @ MMI
        function inputDeviceSetTypeMode(brick,oldType,oldMode,newType,newMode)
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,0,0);
            cmd.opINPUT_DEVICE_SET_TYPEMODE(oldType,oldMode,newType,newMode);
            cmd.addLength();
            brick.send(cmd);
        end
        
        % Implemented @ MMI
        function mode = inputDeviceGetModeName(brick,layer,no,mode)
            % Brick.inputDeviceGetModeName Get the input device mode name
            %
            % Brick.inputDeviceGetModeName(layer,no,mode) returns the name of the
            % device's mode. (If expected sensor is connected, think of this as
            % an enum to string conversion.)
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or port
            %   number minus 1.
            % - mode is the name of the current sensor mode (string)
            %
            % Example::
            %           mode = b.inputDeviceGetModeName(0,SensorPort.Sensor1,Device.Bumps)
            %               -> mode = BUMPS afterwards, if touch sensor is connected.
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,12,0);
            cmd.opINPUT_DEVICE_GET_MODENAME(layer,no,mode,12,0);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            % return the mode name
            mode = sscanf(char(msg(6:end)),'%s');
        end
        
        % Implemented @ MMI
        function conn = inputDeviceGetConnection(brick,layer,no)
            % Brick.inputDeviceGetConnection Get the input device
            % connection type
            %
            % Brick.inputDeviceGetConnection(layer,no) returns the connection
            % type at a layer and NO.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or port
            %   number minus 1.
            % - connection is the connection type of the sensor (DATA8)
            %   -> compare with Device.CONN_[..]
            %
            % Example::
            %           conn = b.inputDeviceGetConnection(0,SensorPort.Sensor1)
            %               -> conn = Device.CONN_NONE (if no sensor is detected at Port1)
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,1,0);
            cmd.opINPUT_DEVICE_GET_CONNECTION(layer,no,0);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            % return the connection type
            conn = msg(6);
        end
        
        % Implemented @ MMI
        function [min,max] = inputDeviceGetMinMax(brick,layer,no)
            % Brick.inputDeviceGetMinMax Get min&max SI or pct values.
            %
            % Brick.inputDeviceGetMinMax(layer,no) returns the min and
            % max SI or pct values at a layer and NO.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or port
            %   number minus 1.
            % - min,max are the minimum/maximum SI/pct values of a sensor (each DATAF)
            %
            % Example::
            %           [min,max] = brick.inputDeviceGetMinMax(0,SensorPort.Sensor1);
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,8,0);
            cmd.opINPUT_DEVICE_GET_MINMAX(layer,no,0,4);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            % return the values
            min = typecast(uint8(msg(6:9)),'single');
            max = typecast(uint8(msg(10:13)),'single');
            
            if brick.debug > 0
                 fprintf('Minimum: %.02f\n', min);
                 fprintf('Maximum: %.02f\n', max);
            end
        end
        
        % Implemented @ MMI
        function changes = inputDeviceGetChanges(brick,layer,no)
            % Brick.inputDeviceGetChanges Get changes since last clear.
            %
            % Brick.inputDeviceGetChanges (layer,no) returns positive changes(=button releases) at a layer and NO.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or port
            %   number minus 1.
            % - changes are the button releases since last clear. (DATAF)
            %
            % Example::
            %       changes = brick.inputDeviceGetChanges(0,SensorPort.Sensor1)
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,4,0);
            cmd.opINPUT_DEVICE_GET_CHANGES(layer,no,0);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            % return the changes
            changes = typecast(uint8(msg(6:9)),'single');
            if brick.debug > 0
                 fprintf('Changes (button releases) since clear: %.02f\n', changes);
            end
        end
        
        % Implemented @ MMI
        function [datasets,format,modes,view] = inputDeviceGetFormat(brick,layer,no)
            % Brick.inputDeviceGetFormat Get format of sensor data.
            %
            % Brick.inputDeviceGetFormat (layer,no) returns no of
            % datasets, format, no of modes, no of 'visible' modes
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or port
            %   number minus 1.
            % - datasets equals no of returned datasets (usually 1). (DATA8)
            % - format equals format of returned data (0:8 Bit, 1:16 Bit,
            %   2: 32 Bit, 3: 32 Bit Float). (DATA8)
            % - modes equals no of sensor modes at NO (refer to types.html,
            %   typedata.rcf). (DATA8)
            % - view equals no of sensor modes visible within port view
            %   app on brick. (DATA8)
            %
            % Example::
            %       changes = brick.inputDeviceGetFormat(0,SensorPort.Sensor1)            
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,4,0);
            cmd.opINPUT_DEVICE_GET_FORMAT(layer,no,0,1,2,3);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            % return the data
            datasets = msg(6);
            format = msg(7);
            modes = msg(8);
            view = msg(9);
        end
        
        % Implemented @ MMI
        function bumps = inputDeviceGetBumps(brick,layer,no)
            % Brick.inputDeviceGetBumps Get bumps since last clear.
            %
            % Brick.inputDeviceGetBumps (layer,no) returns bumps (button presses, = 'negative 
            % changes') at a layer and NO.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or port
            % number minus 1.
            % - bumps are the button presses since last clear. (DATAF)
            %
            % Example::
            %       changes = brick.inputDeviceGetBumps(0,SensorPort.Sensor1)
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,4,0);
            cmd.opINPUT_DEVICE_GET_BUMPS(layer,no,0);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            % return the bumps
            bumps = typecast(uint8(msg(6:9)),'single');
            if brick.debug > 0
                 fprintf('Bumps (button presses) since clear: %.02f\n', bumps);
            end
        end
        
        function name = inputDeviceSymbol(brick,layer,no)
            % Brick.inputDeviceSymbol Get the input device symbol
            %
            % Brick.inputDeviceSymbol(layer,no) returns the symbol used for
            % the device in its current mode.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or sensor port
            % number minus 1.
            % - name is the symbol of the sensor at NO (refer to types.html,
            %   typedata.rcf)
            %
            % Example::
            %           name = b.inputDeviceSymbol(0,SensorPort.Sensor1)
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,5,0);
            cmd.opINPUT_DEVICE_GET_SYMBOL(layer,no,5,0);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            % return the symbol name
            name = sscanf(char(msg(6:end)),'%s');
        end
        
        % Implemented @ MMI
        function inputDeviceClrChanges(brick,layer,no)
            % Brick.inputDeviceClrChanges Clear changes.
            %
            % Brick.inputDeviceClrChanges(layer,no) clear changes(&bumps)
            % at a layer and NO.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or sensor port
            % number minus 1.
            %
            % Example::
            %           name = b.inputDeviceClrChanges(0,SensorPort.Sensor1)
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opINPUT_DEVICE_CLR_CHANGES(layer,no);
            cmd.addLength();
            brick.send(cmd);
        end
        
        function inputDeviceClrAll(brick,layer)
            % Brick.inputDeviceClrAll Clear the sensors
            %
            % Brick.inputDeviceClrAll(layer) clears the sensors connected
            % to layer. (@MMI: and tacho counts!)
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            %
            % Example::
            %           name = b.inputDeviceClrAll(0)
            
            cmd = Command();
%             cmd.addHeaderDirectReply(42,5,0);
            cmd.addHeaderDirect(42,0,0);
            cmd.opINPUT_DEVICE_CLR_ALL(layer);
            cmd.addLength();
            brick.send(cmd);
        end
        
        % Implemented @ MMI
        function inputReady(brick,layer,no)
            % Brick.inputReady Wait for device
            %
            % Brick.inputReady(layer,nos) halts program until device at no
            % is ready by waiting until reply is received
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or sensor port
            % number minus 1.            
            %
            % Example::
            %           b.inputReady(0,SensorPort.Sensor1)
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,0,0);
            cmd.opINPUT_READY(layer,no);
            cmd.addLength();
            brick.send(cmd);
            % receive reply
            brick.receive();            
        end
        
        % Implemented @ MMI
        function state = inputTest(brick,layer,no)
            % Brick.inputTest Test a device
            %
            % Brick.inputTest(layer,nos) tests a device state at a layer and
            % NO.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or sensor port
            % number minus 1.   
            % - state is 0 when ready and 1 when busy. (e.g. changing mode) (DATA8)s
            %
            % Example::
            %           state = b.inputTest(0,SensorPort.Sensor1)
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,1,0);
            cmd.opINPUT_TEST(layer,no,0);
            cmd.addLength();
            brick.send(cmd);
            % receive the state
            msg = brick.receive()';
            % device state is the 6th (final) byte
            state = msg(6);
        end
        
        % Implemented @ MMI
        function reading = inputRead(brick,layer,no,mode)
            % Brick.inputRead Input read in percentage
            % 
            % reading = Brick.inputRead(layer,no,mode) reads a 
            % connected sensor at a layer, NO and mode in percentage of max
            % values. 
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or sensor port
            % number minus 1.
            % - mode is the sensor mode from types.html. (-1=don't change)
            % - reading is the read value in pct (DATA8)
            %
            % Example::
            %            reading = b.inputRead(0,SensorPort.Sensor1,Device.USDistCM)
            %            reading = b.inputRead(0,SensorPort.Sensor1,Device.ColReflect)
            %                 -> returns the same value as b.inputReadSI..
            %            reading = b.inputRead(0,SensorPort.Sensor1,Device.Bumps)
            %                 -> returns seemingly pointless values (as
            %                 expected)
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,1,0);
            cmd.opINPUT_READ(layer,no,0,mode,0);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            reading = msg(6);
            if brick.debug > 0
                 fprintf('Sensor reading: %.02f\n', reading);
            end
        end
        
        function reading = inputReadSI(brick,layer,no,mode)
            % Brick.inputReadSI Input read in SI units
            % 
            % reading = Brick.inputReadSI(layer,no,mode) reads a 
            % connected sensor at a layer, NO and mode in SI units.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or sensor port
            % number minus 1.
            % - mode is the sensor mode from types.html. (-1=don't change)
            % - reading is the read value in SI units. (DATAF)
            %
            % Example::
            %            reading = b.inputReadSI(0,SensorPort.Sensor1,Device.USDistCM)
            %            reading = b.inputReadSI(0,SensorPort.Sensor1,Device.Pushed)
           
            cmd = Command();
            cmd.addHeaderDirectReply(42,4,0);
            cmd.opINPUT_READSI(layer,no,0,mode,0);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            reading = typecast(uint8(msg(6:9)),'single');
            if brick.debug > 0
                 fprintf('Sensor reading: %.02f\n', reading);
            end
        end
        
        function reading = inputReadSIType(brick,layer,no,type,mode)
            % Brick.inputReadSI Input read in SI units
            % 
            % reading = Brick.inputReadSI(layer,no,mode) reads a 
            % connected sensor at a layer, NO and mode in SI units.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or sensor port
            % number minus 1.
            % - mode is the sensor mode from types.html. (-1=don't change)
            % - reading is the read value in SI units. (DATAF)
            %
            % Example::
            %            reading = b.inputReadSI(0,SensorPort.Sensor1,Device.USDistCM)
            %            reading = b.inputReadSI(0,SensorPort.Sensor1,Device.Pushed)
           
            cmd = Command();
            cmd.addHeaderDirectReply(42,4,0);
            cmd.opINPUT_READSI(layer,no,type,mode,0);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            reading = typecast(uint8(msg(6:9)),'single');
            if brick.debug > 0
                 fprintf('Sensor reading: %.02f\n', reading);
            end
        end
        
        function plotSensor(brick,layer,no,mode)
            % Brick.plotSensor plot the sensor output 
            %
            % Brick.plotSensor(layer,no,mode) plots the sensor output
            % to MATLAB. 
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or sensor port
            % number minus 1.
            % - mode is the sensor mode from types.html. (-1=don't change)
            %
            % Example::
            %           b.plotSensor(0,SensorPort.Sensor1,Device.USDistCM)
            %           b.plotSensor(0,SensorPort.Sensor1,Device.GyroAng)
            
            % start timing
            tic;
            % create figure
            hfig = figure('name','EV3 Sensor');
            % init the the data
            t = 0;
            x = 0;
            hplot = plot(t,x);
            % one read to set the mode
            reading = brick.inputReadSI(layer,no,mode);
            % set the title
            name = brick.inputDeviceGetName(layer,no);
            title(['Device name: ' name]);
            % set the y label
            name = brick.inputDeviceSymbol(layer,no);
            ylabel(['Sensor value (' name(1:end-1) ')']);
            % set the x label
            xlabel('Time (s)');
            % set the x axis
            xlim([0 10]);
            % wait until the figure is closed
            while(findobj('name','EV3 Sensor') == 1)
                % get the reading
                reading = brick.inputReadSI(layer,no,mode);
                t = [t toc];
                x = [x reading];
                set(hplot,'Xdata',t)
                set(hplot,'Ydata',x)
                drawnow
                % reset after 10 seconds
                if (toc > 10)
                   % reset
                   t = 0;
                   x = x(end);
                   tic
                end
            end
        end
            
        function displayColor(brick,layer,no)
            % Brick.displayColor display sensor color 
            %
            % Brick.displayColor(layer,no) displays the color read from the
            % color sensor in a MATLAB figure.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is the output port number from [0..3] or sensor port
            % number minus 1.
            %
            % Example::
            %           b.displayColor(0,SensorPort.Sensor1)
            
            % create figure
            hfig = figure('name','EV3 Color Sensor');
            % wait until the figure is closed
            while(findobj('name','EV3 Color Sensor') == 1)
                % read the color sensor in color detection mode
                color = brick.inputReadSI(layer,no,Device.ColColor);
                % change the figure background according to the color
                switch color
                    case Device.NoColor
                        set(hfig,'Color',[0.8,0.8,0.8])
                    case Device.BlackColor
                        set(hfig,'Color',[0,0,0])
                    case Device.BlueColor
                        set(hfig,'Color',[0,0,1])
                    case Device.GreenColor
                        set(hfig,'Color',[0,1,0])
                    case Device.YellowColor
                        set(hfig,'Color',[1,1,0])
                    case Device.RedColor
                        set(hfig,'Color',[1,0,0])
                    case Device.WhiteColor
                        set(hfig,'Color',[1,1,1])
                    case Device.BrownColor
                        set(hfig,'Color',[0.6,0.3,0])
                    otherwise
                        set(hfig,'Color',[0.8,0.8,0.8])
                end
                drawnow
            end
        end
        
        function outputStop(brick,layer,nos,brake)
            % Brick.outputPower Stops a motor
            %
            % Brick.outputPower(layer,nos,brake) stops motor at a layer 
            % NOS and brake.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NOS is a bit field representing output 1 to 4 (0x01, 0x02, 0x04, 0x08).
            % - brake is [0..1] (0=Coast,  1=Brake).
            %
            % Example::
            %           b.outputStop(0,MotorBitfield.MotorA,BrakeMode.Brake)
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opOUTPUT_STOP(layer,nos,brake)
            cmd.addLength();
            brick.send(cmd);
        end
        
        function outputStopAll(brick)
            % Brick.outputStopAll Stops all motors
            %
            % Brick.outputStopAll(layer) stops all motors on layer 0.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - Sends 0x0F as the NOS bit field to stop all motors.
            %
            % Example::
            %           b.outputStopAll(0)
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opOUTPUT_STOP(0,15,BrakeMode.Brake);
            cmd.addLength();
            brick.send(cmd);
        end
        
        function outputPower(brick,layer,nos,power)
            % Brick.outputPower Set the motor output power
            % 
            % Brick.outputPower(layer,nos,power) sets motor output power at
            % a layer, NOS and power.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NOS is a bit field representing output 1 to 4 (0x01, 0x02, 0x04, 0x08).
            % - power is the output power with [+-0..100%] range.
            %
            % Example::
            %           b.outputPower(0,MotorBitfield.MotorA,50)
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opOUTPUT_POWER(layer,nos,power);
            cmd.addLength();
            brick.send(cmd);
        end
        
        % Implemented @ MMI
        function outputSpeed(brick,layer,nos,speed)
            % Brick.outputSpeed Set the motor output speed
            % 
            % Brick.outputSpeed(layer,nos,speed) sets motor output speed at
            % a layer, NOS and speed.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NOS is a bit field representing output 1 to 4 (0x01, 0x02, 0x04, 0x08).
            % - speed is the output speed with [+-0..100%] range.
            % Example::
            %           b.outputSpeed(0,MotorBitfield.MotorA,50)            
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opOUTPUT_SPEED(layer,nos,speed);
            cmd.addLength();
            brick.send(cmd);
        end
        
        function outputStart(brick,layer,nos)
            % Brick.outputStart Starts a motor
            %
            % Brick.outputStart(layer,nos) starts a motor at a layer and
            % NOS.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NOS is a bit field representing output 1 to 4 (0x01, 0x02, 0x04, 0x08).
            %
            % Example::
            %           b.outputStart(0,MotorBitfield.MotorA)
          
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opOUTPUT_START(layer,nos);
            cmd.addLength();
            brick.send(cmd);
        end 
        
        function state = outputTest(brick,layer,nos)
            % Brick.outputTest Test a motor
            %
            % Brick.outputTest(layer,nos) tests a motor state at a layer and
            % NOS.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NOS is a bit field representing output 1 to 4 (0x01, 0x02, 0x04, 0x08).
            % - state is 0 when ready and 1 when busy. (DATA8)
            %
            % Example::
            %           state = b.outputTest(0,MotorBitfield.MotorA)
          
            cmd = Command();
            cmd.addHeaderDirectReply(42,1,0);
            cmd.opOUTPUT_TEST(layer,nos,0);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive();
            % motor state is the final byte
            state = msg(end);
        end
        
        % Implemented @ MMI
        function outputReady(brick,layer,nos)
            % Brick.outputReady Wait for motor
            %
            % Brick.outputReady(layer,nos) halts program until motor at nos
            % is ready by waiting until reply is received.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NOS is a bit field representing output 1 to 4 (0x01, 0x02, 0x04, 0x08).
            %
            % Example::
            %           b.outputReady(0,MotorBitfield.MotorA)
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,0,0);
            cmd.opOUTPUT_READY(layer,nos);
            cmd.addLength();
            brick.send(cmd);
            % receive reply
            brick.receive();
        end
        
        % Implemented @ MMI
        function outputPolarity(brick, layer, nos, pol)
            % Brick.outputPolarity Set a motor's polarity
            %
            % Brick.outputPolarity(layer,nos,pol) sets a motor's polarity
            % to pol
            %
            % Notes::
            % - layer is the usb chain layer (usually 0)
            % - NOS is a bit field representing output 1 to 4 (0x01, 0x02, 0x04, 0x08)
            % - pol is the polarity [-1,0,1], -1 makes the motor run
            %   backwards, 1 makes the motor run forwards, 0 makes the motor
            %   run the opposite direction when starting next time
            %
            % Example::
            %           b.outputPolarity(0, MotorBitfield.MotorA, -1);
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opOUTPUT_POLARITY(layer,nos,pol);
            cmd.addLength();
            brick.send(cmd);
        end
        
        % Implemented @ MMI
        function outputStepPower(brick,layer,nos,power,step1,step2,step3,brake)
            % Brick.outputStepPower Output a step power 
            %
            % Brick.outputStepPower(layer,nos,power,step1,step2,step3,brake)
            % moves a motor to set position with layer, NOS, power, ramp up
            % angle, constant angle, ramp down angle and brake.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NOS is a bit field representing output 1 to 4 (0x01, 0x02, 0x04, 0x08).
            % - power is the output power with [+-0..100%] range.
            % - step1 is the steps used to ramp up.
            % - step2 is the steps used for constant speed.
            % - step3 is the steps used for ramp down.
            % - brake is [0..1] (0=Coast,  1=Brake).
            %
            % Example::
            %           b.outputStepPower(0,MotorBitfield.MotorA,50,50,360,50,BrakeMode.Coast)
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opOUTPUT_STEP_POWER(layer,nos,power,step1,step2,step3,brake);
            cmd.addLength();
            brick.send(cmd);
        end
        
        % Implemented @ MMI
        function outputTimePower(brick,layer,nos,power,step1,step2,step3,brake)
            % Brick.outputTimePower Output a time power 
            %
            % Brick.outputTimePower(layer,nos,power,step1,step2,step3,brake)
            % moves a motor for set time with layer, NOS, power, ramp up
            % angle, constant angle, ramp down angle and brake.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NOS is a bit field representing output 1 to 4 (0x01, 0x02, 0x04, 0x08).
            % - power is the output power with [+-0..100%] range.
            % - step1 is the time in ms used for ramp up.
            % - step2 is the time in ms used for constant speed.
            % - step3 is the time in ms used for ramp down.
            % - brake is [0..1] (0=Coast,  1=Brake).
            %
            % Example::
            %           b.outputTimePower(0,MotorBitfield.MotorA,50,50,360,50,BrakeMode.Coast)
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opOUTPUT_TIME_POWER(layer,nos,power,step1,step2,step3,brake);
            cmd.addLength();
            brick.send(cmd);
        end
        
        function outputStepSpeed(brick,layer,nos,speed,step1,step2,step3,brake)
            % Brick.outputStepSpeed Output a step speed 
            %
            % Brick.outputStepSpeed(layer,nos,speed,step1,step2,step3,brake)
            % moves a motor to set position with layer, NOS, speed, ramp up
            % angle, constant angle, ramp down angle and brake.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NOS is a bit field representing output 1 to 4 (0x01, 0x02, 0x04, 0x08).
            % - speed is the output speed with [+-0..100%] range.
            % - step1 is the steps used to ramp up.
            % - step2 is the steps used for constant speed.
            % - step3 is the steps used for ramp down.
            % - brake is [0..1] (0=Coast,  1=Brake).
            %
            % Example::
            %           b.outputStepSpeed(0,MotorBitfield.MotorA,50,50,360,50,BrakeMode.Coast)
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opOUTPUT_STEP_SPEED(layer,nos,speed,step1,step2,step3,brake);
            cmd.addLength();
            brick.send(cmd);
        end
        
        % Implemented @ MMI
        function outputTimeSpeed(brick,layer,nos,speed,step1,step2,step3,brake)
            % Brick.outputTimeSpeed Output a time speed 
            %
            % Brick.outputTimeSpeed(layer,nos,speed,step1,step2,step3,brake)
            % moves a motor for set time with layer, NOS, speed, ramp up
            % angle, constant angle, ramp down angle and brake.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NOS is a bit field representing output 1 to 4 (0x01, 0x02, 0x04, 0x08).
            % - speed is the output speed with [+-0..100%] range.
            % - step1 is the time in ms used for ramp up.
            % - step2 is the time in ms used for constant speed.
            % - step3 is the time in ms used for ramp down.
            % - brake is [0..1] (0=Coast,  1=Brake).
            %
            % Example::
            %           b.outputTimeSpeed(0,MotorBitfield.MotorA,50,50,360,50,BrakeMode.Coast)
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opOUTPUT_TIME_SPEED(layer,nos,speed,step1,step2,step3,brake);
            cmd.addLength();
            brick.send(cmd);
        end
        
        % Implemented @ MMI
        function outputStepSync(brick,layer,nos,power,turn,step,brake)
            % Brick.outputStepSync Output a synced step power
            %
            % Brick.outputStepSync(brick,layer,nos,power,turn,step,brake) 
            % moves two motors synchronized to set position with layer,
            % NOS, power, turn ratio, tacho limit and brake
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NOS is a bit field representing output 1 to 4 (0x01, 0x02, 0x04, 0x08).
            %   -> only works with output to multiple nos: e.g. 0x01+0x02
            % - power is the output power with [+-0..100%] range.
            % - (Excerpt of c_output.c): Turn ratio is how tight you turn and to what direction 
            %                            you turn (in [+-200]).
            %   -> 0 value is moving straight forward
            %   -> Negative values turns to the left
            %   -> Positive values turns to the right
            %   -> Value -100 stops the left motor
            %   -> Value +100 stops the right motor
            %   -> Values less than -100 makes the left motor run the opposite
            %       direction of the right motor (Spin)
            %   -> Values greater than +100 makes the right motor run the opposite
            %       direction of the left motor (Spin) (/end excerpt)
            % - step is the tacho limit (read on 'faster' motor) 0=Inf
            % - brake is [0..1] (0=Coast,  1=Brake).
            %
            % Example::
            %           b.outputStepSync(0,MotorBitfield.MotorA+MotorBitfield.MotorB,50,50,360,BrakeMode.Coast)           
           
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opOUTPUT_STEP_SYNC(layer,nos,power,turn,step,brake);
            cmd.addLength();
            brick.send(cmd);
        end
        
        % Implemented @ MMI
        function outputTimeSync(brick,layer,nos,power,turn,time,brake)
            % Brick.outputTimeSync Output a synced time power
            %
            % Brick.outputTimeSync(brick,layer,nos,power,turn,time,brake) 
            % moves two motors synchronized for set time with layer,
            % NOS, power, turn ratio, time limit and brake
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NOS is a bit field representing output 1 to 4 (0x01, 0x02, 0x04, 0x08).
            %   -> output to multiple nos: e.g. 0x01+0x02
            % - power is the output power with [+-0..100%] range.
            % - (Excerpt of c_output.c): Turn ratio is how tight you turn and to what direction you turn
            %   -> 0 value is moving straight forward
            %   -> Negative values turns to the left
            %   -> Positive values turns to the right
            %   -> Value -100 stops the left motor
            %   -> Value +100 stops the right motor
            %   -> Values less than -100 makes the left motor run the opposite
            %       direction of the right motor (Spin)
            %   -> Values greater than +100 makes the right motor run the opposite
            %       direction of the left motor (Spin) (/end excerpt)
            % - time is the time limit in milliseconds, 0=Inf
            % - brake is [0..1] (0=Coast,  1=Brake).
            %
            % Example::
            %           b.outputTimeSync(0,MotorBitfield.MotorA+MotorBitfield.MotorB,50,50,360,BrakeMode.Coast)   
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opOUTPUT_TIME_SYNC(layer,nos,power,turn,time,brake);
            cmd.addLength();
            brick.send(cmd);
        end    
        
        function outputClrCount(brick,layer,nos)
            % Brick.outputClrCount Clear output count
            % 
            % Brick.outputClrCount(layer,nos) clears a motor tachometer at a
            % layer and NOS.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NOS is a bit field representing output 1 to 4 (0x01, 0x02, 0x04, 0x08).
            %
            % Example::
            %            b.outputClrCount(0,MotorBitfield.MotorA)
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opOUTPUT_CLR_COUNT(layer,nos);
            cmd.addLength();
            brick.send(cmd);
        end
        
        % Implemented @ MMI
        function outputReset(brick,layer,nos)
            % Brick.outputReset Resets internal tacho count
            %
            % Brick.outputReset(layer,nos) clears a second tachometer which is used internally
            % for, e.g., stopping with a tacholimit.
            %
            % Notes::
            % - layer is the usb chain layer (usuallly 0).
            % - NOS is a bit field representing output 1 to 4 (0x01, 0x02, 0x04, 0x08).
            %
            % Example::
            %             b.outputReset(0,MotorBitfield.MotorA)
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opOUTPUT_RESET(layer,nos);
            cmd.addLength();
            brick.send(cmd);
        end
        
        % Bugfix @ MMI
        function tacho = outputGetCount(brick,layer,no)
            % Brick.outputGetCount(layer,no) Get output count
            % 
            % tacho = Brick.outputGetCount(layer,no) returns the tachometer 
            % at a layer and NO.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is output motor number [0...3] ( != NOS)
            %   -> use MotorPort.MotorA
            % - tacho is the returned tachometer value. (DATA32)
            %
            % Example::
            %           tacho = b.outputGetCount(0,MotorPort.MotorA)


            cmd = Command();
            cmd.addHeaderDirectReply(42,4,0);
            cmd.opOUTPUT_GET_COUNT(layer,no,0);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            tacho = typecast(uint8(msg(6:9)),'int32');
            if brick.debug > 0
                fprintf('Tacho: %d degrees\n', tacho);
            end
        end
        
        % Implemented @ MMI 
        % Still buggy (WIP)
        function [speed, tacho] = outputRead(brick,layer,no)
            % Brick.outputRead(layer,no) Get tacho count and speed.
            % 
            % [speed, tacho] = Brick.outputRead(layer,no) returns the tachometer 
            % and speed at a layer and NO.
            %
            % Notes::
            % - layer is the usb chain layer (usually 0).
            % - NO is output motor number [0...3] ( != NOS)
            % - tacho is the returned tachometer value. (DATA32)
            % - speed is the returned speed value. (DATA8)
            % 
            % TODO:: 
            % - returned tacho value is wrong/does not work.
            % - returned speed value is OK until about speed=82
            %   -> calling this function while motor is faster seems to even screw the motor
            %       itself: it won't get any faster after current speed.
            %
            % Example::
            %           [speed,tacho] = b.outputRead(0,MotorPort.MotorA)
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,5,0); 
            cmd.opOUTPUT_READ(layer,no,0,4); %%
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            % Current thoughts: the bug could be in the firmware (DUNDUNDUN).
            % The docu states: "Offset in the response buffer (global variables) must be
            % aligned (float/32bits first and 8 bits last)." [/lms2012/doc/html/directcommands.html]
            %-> problem: the firmware
            % implementation of this function puts speed (DATA8) first and tacho (DATA32) second.
            % Furthermore, the speed is correct only if I, following the rule,
            % do what I do at '%%': I tell the brick that I need a DATA32 and THEN a DATA8.
            % This would fulfill the stated rule, but would only work if the
            % firmware would put tacho first and speed second.
            % If I tell the brick that I need a DATA8 and THEN a DATA32, ignoring the rule
            % and going with the firmware version, I get an error in the response. (error flag)
            %speed = msg(6);
            %tacho = typecast(uint8(msg(7:10)),'int32');
            tacho = typecast(uint8(msg(6:9)),'int32');
            try
                speed = msg(10);
            catch
                speed = 0;  % Sometimes, the response packet lacks the 10th byte...?!
            end
            if brick.debug > 0
                fprintf('Speed: %d\n', speed);
                fprintf('buggy Tacho: %d degrees\n', tacho);
            end
        end
        
        % Implemented @ MMI
        function state = comTest(brick,hardware,name)
            % Brick.comTest Get state of conn devices
            %
            % Brick.comTest(hardware,name) returns state of communication
            % adapter of device.
            %
            % Notes::
            % - hardware is the communication adapter to be tested. 
            %   -> 1: USB, 2: BT, 3: Wifi
            % - name is the name of the device ('0': own adapter) (?)
            % - state is 0 when ready and 1 when busy. (DATA8)
            %
            % Example::
            %           state = b.comTest(1, '0');
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,1,0);
            cmd.opCOM_TEST(hardware,name,0);
            cmd.addLength();
            brick.send(cmd);
            % receive the state
            msg = brick.receive()';
            % return the state
            state = msg(end);
        end
        
        % Implemented @ MMI
        function comReady(brick,hardware,name)
            % Brick.comReady Wait for adapter
            %
            % Brick.comReady(layer,nos) halts program until
            % communication adapter of device is ready.
            %
            % Notes::
            % - hardware is the communication adapter to be tested. 
            %   -> 1: USB, 2: BT, 3: Wifi
            % - name is the name of the device ('0': own adapter) (?)
            %
            % Example::
            %           b.comReady(2, '0');
            
            cmd = Command();
            cmd.addHeaderDirectReply(42,0,0);
            cmd.opCOM_READY(hardware,name);
            cmd.addLength();
            brick.send(cmd);
            % receive reply
            brick.receive();
        end
        
        function name = comGetBrickName(brick)
            % Brick.comGetBrickName Get brick name
            %
            % Brick.comGetBrickName() returns the name of the brick.
            %
            % Example::
            %           name = b.comGetBrickName()
          
            cmd = Command();
            cmd.addHeaderDirectReply(42,10,0);
            cmd.opCOMGET_GET_BRICKNAME(10,0);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            % return the brick name
            name = sscanf(char(msg(6:end)),'%s');
        end
        
        function comSetBrickName(brick,name)
            % Brick.comSetBrickName Set brick name
            %
            % Brick.comSetBrickName(name) sets the name of the brick.
            %
            % Example::
            %           b.comSetBrickName('EV3')
          
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opCOMSET_SET_BRICKNAME(name);
            cmd.addLength();
            brick.send(cmd);
        end
        
        function mac = comGetMACAddress(brick)
            % Brick.comGetMACAddress Get brick MAC address
            %
            % Brick.comGetMACAddress() returns the name of the brick.
            %
            % Example::
            %           mac = b.comGetMACAddress()
          
            cmd = Command();
            cmd.addHeaderDirectReply(42,36,0);
            cmd.opCOMGET_NETWORK(3,36,0,8,20);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            % return the brick name
            mac = sscanf(char(msg(4:10)),'%s');
        end
        
        function id = comGetBTID(brick)
            % Brick.comGetBTID Get brick BT address
            %
            % Brick.comGetBTID() returns the BT address
            %
            % Example::
            %           mac = b.comGetBTID()
          
            cmd = Command();
            cmd.addHeaderDirectReply(42,12,0);
            cmd.opCOMGET_ID(2,12,0);
            cmd.addLength();
            brick.send(cmd);
            % receive the command
            msg = brick.receive()';
            % return the brick name
            id = sscanf(char(msg(6:end)),'%s');
        end
        
        function mailBoxWrite(brick,brickname,boxname,type,msg)
            % Brick.mailBoxWrite Write a mailbox message
            %
            % Brick.mailBoxWrite(brickname,boxname,type,msg) writes a
            % mailbox message from the brick to a remote device.
            %
            % Notes::
            % - brickname is the name of the remote device.
            % - boxname is the name of the receiving mailbox.
            % - type is the sent message type being either 'text',
            % 'numeric' or 'logic'.
            % - msg is the message to be sent.
            %
            % Example::
            %           b.mailBoxWrite('T500','abc','logic',1)
            %           b.mailBoxWrite('T500','abc','numeric',4.24)
            %           b.mailBoxWrite('T500','abc','text','hello!')
            
            cmd = Command();
            cmd.addHeaderDirect(42,0,0);
            cmd.opMAILBOX_WRITE(brickname,boxname,type,msg);
            cmd.addLength();
            brick.send(cmd);
        end      

        function fileUpload(brick,filename,dest)
            % Brick.fileUpload Upload a file to the brick
            %
            % Brick.fileUpload(filename,dest) upload a file from the PC to
            % the brick.
            %
            % Notes::
            % - filename is the local PC file name for upload.
            % - dest is the remote destination on the brick relative to the
            % '/home/root/lms2012/sys' directory. Directories are created
            % in the path if they are not present.
            %
            % Example::
            %           b.fileUpload('prg.rbf','../apps/tst/tst.rbf')
            
            fid = fopen(filename,'r');
            % read in the file in and convert to uint8
            input = fread(fid,inf,'uint8=>uint8');
            fclose(fid); 
            % begin upload
            cmd = Command();
            cmd.addHeaderSystemReply(10);
            cmd.BEGIN_DOWNLOAD(length(input),dest);
            cmd.addLength();
            brick.send(cmd);
            % receive the sent response
            rmsg = brick.receive();
            handle = rmsg(end);
            pause(1)
            % send the file
            cmd.clear();
            cmd.addHeaderSystemReply(11);
            cmd.CONTINUE_DOWNLOAD(handle,input);
            cmd.addLength();
            brick.send(cmd);
            % receive the sent response
            rmsg = brick.receive();
            % print message 
            fprintf('%s uploaded\n',filename);
        end
        
        function fileDownload(brick,dest,filename,maxlength)
            % Brick.fileDownload Download a file from the brick
            %
            % Brick.fileDownload(dest,filename,maxlength) downloads a file 
            % from the brick to the PC.
            %
            % Notes::
            % - dest is the remote destination on the brick relative to the
            % '/home/root/lms2012/sys' directory.
            % - filename is the local PC file name for download e.g.
            % 'prg.rbf'.
            % - maxlength is the max buffer size used for download.
            % 
            % Example::
            %           b.fileDownload('../apps/tst/tst.rbf','prg.rbf',59)
            
            % begin download
            cmd = Command();
            cmd.addHeaderSystemReply(12);
            cmd.BEGIN_UPLOAD(maxlength,dest);
            cmd.addLength();
            brick.send(cmd);
            % receive the sent response
            rmsg = brick.receive();
            % extract payload
            payload = rmsg(13:end);
            % print to file
            fid = fopen(filename,'w');
            % read in the file in and convert to uint8
            fwrite(fid,payload,'uint8');
            fclose(fid); 
        end
        
        function listFiles(brick,pathname,maxlength)
            % Brick.listFiles List files on the brick
            %
            % Brick.listFiles(brick,pathname,maxlength) list files in a 
            % given directory.
            %
            % Notes::
            % - pathname is the absolute path required for file listing.
            % - maxlength is the max buffer size used for file listing.
            % - If it is a file:
            %   32 chars (hex) of MD5SUM + space + 8 chars (hex) of filesize + space + filename + new line is returned.
            % - If it is a folder:
            %   foldername + / + new line is returned.
            %
            % Example::
            %           b.listFiles('/home/root/lms2012/',100)
            
            cmd = Command();
            cmd.addHeaderSystemReply(13);
            cmd.LIST_FILES(maxlength,pathname);
            cmd.addLength();
            brick.send(cmd);
            rmsg = brick.receive();
            % print
            fprintf('%s',rmsg(13:end));
        end    
        
        function createDir(brick,pathname)
            % Brick.createDir Create a directory on the brick
            % 
            % Brick.createDir(brick,pathname) creates a diretory on the 
            % brick from the given pathname.
            %
            % Notes::
            % - pathname is the absolute path for directory creation.
            %
            % Example::
            %           b.createDir('/home/root/lms2012/newdir')
            
            cmd = Command();
            cmd.addHeaderSystemReply(14);
            cmd.CREATE_DIR(pathname);
            cmd.addLength();
            brick.send(cmd);
            rmsg = brick.receive();
        end
        
        function deleteFile(brick,pathname)
            % Brick.deleteFile Delete file on the brick
            % 
            % Brick.deleteFile(brick,pathname) deletes a file from the
            % brick with the given pathname. 
            %
            % Notes::
            % - pathname is the absolute file path for deletion.
            % - will only delete files or empty directories.
            %
            % Example::
            %           b.deleteFile('/home/root/lms2012/newdir')
            
            cmd = Command();
            cmd.addHeaderSystemReply(15);
            cmd.DELETE_FILE(pathname);
            cmd.addLength();
            brick.send(cmd);
            rmsg = brick.receive();
        end
        
        function writeMailBox(brick,title,type,msg)
            % Brick.writeMailBox Write a mailbox message
            %
            % Brick.writeMailBox(title,type,msg) writes a mailbox message to
            % the connected brick.
            %
            % Notes::
            % - title is the message title sent to the brick.
            % - type is the sent message type being either 'text',
            % 'numeric', or 'logic'.
            % - msg is the message to be sent to the brick.
            %
            % Example::
            %           b.writeMailBox('abc','text','hello!')
            
            cmd = Command();
            cmd.addHeaderSystem(16);
            cmd.WRITEMAILBOX(title,type,msg);
            cmd.addLength();
            brick.send(cmd);
        end
        
        function [title,msg] = readMailBox(brick,type)
            % Brick.readMailBox Read a mailbox message
            %
            % [title,msg] = Brick.readMailBox(type) reads a mailbox
            % message sent from the brick.
            %
            % Notes::
            % - type is the sent message type being either 'text',
            % 'numeric' or 'logic'.
            % - title is the message title sent from the brick.
            % - msg is the message sent from the brick.
            %
            % Example::
            %           [title,msg] = b.readMailBox('text')
            
            mailmsg = brick.receive();
            % extract message title (starts at pos 8, pos 7 is the size)
            title = char(mailmsg(8:7+mailmsg(7)));
            % parse message according to type
            switch type
                case 'text'
                    msg = char(mailmsg(mailmsg(7)+10:end));
                case 'numeric'
                    msg = typecast(uint8(mailmsg(mailmsg(7)+10:end)),'single');
                case 'logic'
                    msg = mailmsg(mailmsg(7)+10:end);
                otherwise
                    fprintf('Error! Type must be ''text'', ''numeric'' or ''logic''.\n');
                    msg = '';
            end
        end
            
        function threeToneByteCode(brick,filename)
            % Brick.threeToneByteCode Create three tone byte code
            %
            % Brick.threeToneByteCode() generates the byte code for the
            % play three tone function. This is an example of how byte code
            % can be generated as an rbf file which can be uploaded to the brick.
            %
            % Notes::
            % - filename is the name of the file to store the byte code in
            % (the rbf extension is added to the filename automatically)
            %
            % Example::
            %           b.threeToneByteCode('threetone')
            
            cmd = Command();
            % program header
            cmd.PROGRAMHeader(0,1,0);                   % VersionInfo,NumberOfObjects,GlobalBytes
            cmd.VMTHREADHeader(0,0);                    % OffsetToInstructions,LocalBytes
            % commands                                  % VMTHREAD1{
            cmd.opSOUND_TONE(5,440,500);                % opSOUND
            cmd.opSOUND_READY();                        % opSOUND_READY
            cmd.opSOUND_TONE(10,880,500);               % opSOUND
            cmd.opSOUND_READY();                        % opSOUND_READY
            cmd.opSOUND_TONE(15,1320,500);              % opSOUND
            cmd.opSOUND_READY();                        % opSOUND_READY
            cmd.opOBJECT_END;                           % }
            % add file size in header
            cmd.addFileSize;
            % generate the byte code
            cmd.GenerateByteCode(filename);
        end
    end
end
