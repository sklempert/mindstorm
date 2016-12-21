function isValid = isPortStrValid(device, port)
% Returns whether given port-number is valid for given device
    if strcmpi(device, 'Motor')
        validPorts = {'A', 'B', 'C', 'D'};
    elseif strcmpi(device, 'Sensor')
        validPorts = {'1', '2', '3', '4'};
    elseif strcmpi(device, 'SyncMotor')
        validPorts = {'AB', 'AC', 'AD', 'BA', 'BC', 'BD', ...
            'CA', 'CB', 'CD', 'DA', 'DB', 'DC'};
    else
        error(['isPortValid: First argument has to be either ''Sensor'', ',...
            '''Motor'' or ''SyncMotor''']);
    end

    if ischar(port)
        isValid = ismember(port, validPorts);
    end
end

