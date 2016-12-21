function inputPort = bitfield2input(bitfield)
% Converts a motor-bitfield to motor-inputport-number(s).
    [isSynced, ~, ~] = isSyncedBitfield(bitfield);
    if isSynced
        ports = bitfield2port(bitfield);
        inputPort = [port2input(ports(1)), port2input(ports(2))];
    else
        inputPort = port2input(bitfield2port(bitfield));
    end
end