function input = port2input(port)
% Converts a motor-port-number to motor-inputport-number.
    input = uint8(port)+16;
end