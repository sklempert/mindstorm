classdef MotorState
    properties
        startedNotBusy = false;  % Set to true if motor started w/o tacholimit and unsynced
        sendPowerOnSet = false;  % If true, OUTPUT_POWER is sent when setting power
        
        % Bitfield representing which opCodes should be sent on Motor.start() 
        % The corresponding opCodes for each bit are (in Big Endian):
        %   * 1st Bit: OUTPUT_POWER (sets power on physical Brick)
        %   * 2nd Bit: OUTPUT_STOP (stops Brick; workaround for a bug, see motor.start, Note 2)
        sendOnStart = 0;
    end
    
    methods
        function display(state)
            fprintf('#### Motor State ####\n');
            props = properties(state);
            for i = 1:length(props)
                p = props{i};
                fprintf('%16s:   %d\n', p, state.(p));
            end    
            fprintf('#####################\n');
        end
        
        function isequal = eq(state1, state2)
            props = properties(state1);
            
            isequal = 1;
            for i = 1:length(props)
                p = props{i};
                if state1.(p) ~= state2.(p)
                    isequal = 0;
                    break;
                end
            end    
        end
    end
    
end

