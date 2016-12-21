function port = input2port(input)
% Converts a motor-inputport-number to motor-port-number.
    port = uint8(input)-16;
end