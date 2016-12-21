function port = bitfield2port(bitfield)
% Converts motor-bitfield to motor-port-number(s).
    [isSynced, b1, b2] = isSyncedBitfield(bitfield);
    if isSynced
        port = [b1-1, b2-1];
    else
        port = uint8(log2(double(bitfield)));
    end
end