function portStr = port2str(varargin)
% Converts a port-enum to corresponding-string.
    p = inputParser();
    
    validDevices = {'Motor', 'Sensor', 'SyncMotor'};
    validPortTypes = {'Bitfield', 'PortNo', 'InputPortNo'};
    checkDevice = @(x) ismember(x, validDevices);
    checkPortType = @(x) ismember(x, validPortTypes);
    
    p.addRequired('device', checkDevice);
    p.addRequired('port');
    p.addOptional('portType', 'Bitfield', checkPortType);
    
    p.parse(varargin{:});
    
    device = p.Results.device;
    port = p.Results.port;
    portType = p.Results.portType;
    
    if ~isPortEnumValid(device, port)
        error('port2str: Given parameter is not a valid port-enum'); 
    end
    
    if strcmpi(device, 'Motor')
        if strcmpi(portType, 'Bitfield')
            if port == MotorBitfield.MotorA
                portStr = 'A';
            elseif port == MotorBitfield.MotorB
                portStr = 'B';
            elseif port == MotorBitfield.MotorC
                portStr = 'C';
            elseif port == MotorBitfield.MotorD
                portStr = 'D';            
            end
        elseif strcmpi(portType, 'PortNo')
            if port == MotorPort.MotorA
                portStr = 'A';
            elseif port == MotorPort.MotorB
                portStr = 'B';
            elseif port == MotorPort.MotorC
                portStr = 'C';
            elseif port == MotorPort.MotorD
                portStr = 'D';            
            end
        elseif strcmpi(portType, 'InputPortNo')
            if port == MotorInput.MotorA
                portStr = 'A';
            elseif port == MotorInput.MotorB
                portStr = 'B';
            elseif port == MotorInput.MotorC
                portStr = 'C';
            elseif port == MotorInput.MotorD
                portStr = 'D';            
            end
        end
    elseif strcmpi(device, 'Sensor')
        if port == SensorPort.Sensor1
            portStr = '1';
        elseif port == SensorPort.Sensor2
            portStr = '2';
        elseif port == SensorPort.Sensor3
            portStr = '3';
        elseif port == SensorPort.Sensor4
            portStr = '4'; 
        end
    elseif strcmpi(device, 'SyncMotor')
        switch port
            case MotorBitfield.MotorA+MotorBitfield.MotorB
                portStr = 'AB';
            case MotorBitfield.MotorA+MotorBitfield.MotorC
                portStr = 'AC';
            case MotorBitfield.MotorA+MotorBitfield.MotorD
                portStr = 'AD';
            case MotorBitfield.MotorB+MotorBitfield.MotorC
                portStr = 'BC';
            case MotorBitfield.MotorB+MotorBitfield.MotorD
                portStr = 'BD';
            case MotorBitfield.MotorC+MotorBitfield.MotorD
                portStr = 'CD';
        end
    end
end