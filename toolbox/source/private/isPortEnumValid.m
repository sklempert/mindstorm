function isValid = isPortEnumValid(device, port)
% Returns whether given port-number is valid for given device
    isValid = false;
    
    if ~ischar(device)
        error(['isPortValid: First argument has to be a string (''Sensor'', ',...
            '''Motor'' or ''SyncMotor'')']);
    end
    
    try
        if strcmpi(device, 'Motor')
            if ~isa(port, 'MotorBitfield')
                MotorBitfield(port); 
            end
            isValid = true;  % Otherwise, an error would have already been thrown
        elseif strcmpi(device, 'Sensor')
            if ~isa(port, 'SensorPort')
                SensorPort(port); 
            end
            isValid = true;  % Otherwise, an error would have already been thrown
        elseif strcmpi(device, 'SyncMotor')
            isValid = isSyncedBitfield(port);
        end
    catch ME
        % Ignore
    end
end
