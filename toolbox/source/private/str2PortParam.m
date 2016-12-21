function varargout = str2PortParam(device, port)
% Converts a port-string to corresponding enum-types.
%
% Syntax
%  
%
% Arguments
%  * device ('Motor', 'SyncMotor', 'Sensor'): Device type to which port belongs
%  * port ('A',..,'D'; '1',..,'4'; 'AB',..,'DC'): Port as a string
%
% Output
%  * [device='Motor'] varargout{1} - varargout{3}: Bitfield, Port, Input
%  * [device='SyncMotor'] varargout{1} - varargout{5}: Bitfield, Port1, Input1, Port2,
%                                                         Input2
%  * [device='Sensor'] varargout{1}: Port
%
% Exceptions
%  *
%  *
%  *
%
% Examples
%
%
% Signature
%
%
%

    if ~ischar(device)
        error(['str2PortParam: First argument has to be a string (''Sensor'', ',...
            '''Motor'' or ''SyncMotor'')']);
    end

    if strcmpi(device, 'Motor')
        if strcmpi(port, 'A')
            varargout{1} = MotorBitfield.MotorA;
            varargout{2} = MotorPort.MotorA;
            varargout{3} = MotorInput.MotorA;
        elseif strcmpi(port, 'B')
            varargout{1} = MotorBitfield.MotorB;
            varargout{2} = MotorPort.MotorB;
            varargout{3} = MotorInput.MotorB;
        elseif strcmpi(port, 'C')
            varargout{1} = MotorBitfield.MotorC;
            varargout{2} = MotorPort.MotorC;
            varargout{3} = MotorInput.MotorC;
        elseif strcmpi(port, 'D')
            varargout{1} = MotorBitfield.MotorD;
            varargout{2} = MotorPort.MotorD;
            varargout{3} = MotorInput.MotorD;
        else
            error('str2PortParam: Given port is not a valid motor port.');
        end
    elseif strcmpi(device, 'Sensor')
        if strcmpi(port, '1')
            varargout{1} = SensorPort.Sensor1;
        elseif strcmpi(port, '2')
            varargout{1} = SensorPort.Sensor2;
        elseif strcmpi(port, '3')
            varargout{1} = SensorPort.Sensor3;
        elseif strcmpi(port, '4')
            varargout{1} = SensorPort.Sensor4;
        else
            error('str2PortParam: Given parameter not a valid sensor port.');
        end
    elseif strcmpi(device, 'SyncMotor')
        if strcmpi(port,'AB')
            varargout{1} = MotorBitfield.MotorA+MotorBitfield.MotorB;
            varargout{2} = MotorPort.MotorA;
            varargout{3} = MotorInput.MotorA;
            varargout{4} = MotorPort.MotorB;
            varargout{5} = MotorInput.MotorB;
        elseif strcmpi(port,'AC')
            varargout{1} = MotorBitfield.MotorA+MotorBitfield.MotorC;
            varargout{2} = MotorPort.MotorA;
            varargout{3} = MotorInput.MotorA;
            varargout{4} = MotorPort.MotorC;
            varargout{5} = MotorInput.MotorC;
        elseif strcmpi(port,'AD')
            varargout{1} = MotorBitfield.MotorA+MotorBitfield.MotorD;
            varargout{2} = MotorPort.MotorA;
            varargout{3} = MotorInput.MotorA;
            varargout{4} = MotorPort.MotorD;
            varargout{5} = MotorInput.MotorD;
        elseif strcmpi(port,'BA')
            varargout{1} = MotorBitfield.MotorB+MotorBitfield.MotorA;
            varargout{2} = MotorPort.MotorB;
            varargout{3} = MotorInput.MotorB;
            varargout{4} = MotorPort.MotorA;
            varargout{5} = MotorInput.MotorA;
        elseif strcmpi(port,'BC')
            varargout{1} = MotorBitfield.MotorB+MotorBitfield.MotorC;
            varargout{2} = MotorPort.MotorB;
            varargout{3} = MotorInput.MotorB;
            varargout{4} = MotorPort.MotorC;
            varargout{5} = MotorInput.MotorC;
        elseif strcmpi(port,'BD')
            varargout{1} = MotorBitfield.MotorB+MotorBitfield.MotorD;
            varargout{2} = MotorPort.MotorB;
            varargout{3} = MotorInput.MotorB;
            varargout{4} = MotorPort.MotorD;
            varargout{5} = MotorInput.MotorD;
        elseif strcmpi(port,'CA')
            varargout{1} = MotorBitfield.MotorC+MotorBitfield.MotorA;
            varargout{2} = MotorPort.MotorC;
            varargout{3} = MotorInput.MotorC;
            varargout{4} = MotorPort.MotorA;
            varargout{5} = MotorInput.MotorA;
        elseif strcmpi(port,'CB')
            varargout{1} = MotorBitfield.MotorC+MotorBitfield.MotorB;
            varargout{2} = MotorPort.MotorC;
            varargout{3} = MotorInput.MotorC;
            varargout{4} = MotorPort.MotorB;
            varargout{5} = MotorInput.MotorB;
        elseif strcmpi(port,'CD')
            varargout{1} = MotorBitfield.MotorC+MotorBitfield.MotorD;
            varargout{2} = MotorPort.MotorC;
            varargout{3} = MotorInput.MotorC;
            varargout{4} = MotorPort.MotorD;
            varargout{5} = MotorInput.MotorD;
        elseif strcmpi(port,'DA')
            varargout{1} = MotorBitfield.MotorD+MotorBitfield.MotorA;
            varargout{2} = MotorPort.MotorD;
            varargout{3} = MotorInput.MotorD;
            varargout{4} = MotorPort.MotorA;
            varargout{5} = MotorInput.MotorA;
        elseif strcmpi(port,'DB')
            varargout{1} = MotorBitfield.MotorD+MotorBitfield.MotorB;
            varargout{2} = MotorPort.MotorD;
            varargout{3} = MotorInput.MotorD;
            varargout{4} = MotorPort.MotorB;
            varargout{5} = MotorInput.MotorB;
        elseif strcmpi(port,'DC')
            varargout{1} = MotorBitfield.MotorD+MotorBitfield.MotorC;
            varargout{2} = MotorPort.MotorD;
            varargout{3} = MotorInput.MotorD;
            varargout{4} = MotorPort.MotorC;
            varargout{5} = MotorInput.MotorC;
        else
            error('str2PortParam: Given port is not a valid sync motor port.');
        end
    else
        error(['str2PortParam: First argument has to be either ''Sensor'', ',...
               '''Motor'' or ''SyncMotor''']);
    end
end

