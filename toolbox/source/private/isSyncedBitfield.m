function [isSynced, bit1, bit2] = isSyncedBitfield(bitfield)
% A SyncMotor-port is the sum of the two ports to sync
% -> As motor ports are represented by bitfields, check how many bits are set (2
% bits = 2 ports).
% -> Just checking 'port' against allowed values would have been too easy :)
    bit1 = 0; bit2 = 0;

    setBits = [];
    for i=1:4
        if bitget(bitfield, i) == 1
            setBits = [setBits, i];
        end
    end

    isSynced = (bitfield<=15)&&(length(setBits)==2);
    if isSynced
        bit1 = setBits(1);
        bit2 = setBits(2);
    end
end

