classdef ConnectionType < uint8
    %ConnectionType Type resp. status of connection at a certain port.
    enumeration
        Unknown (111)
        DaisyChain (117)
        NXTColor (118)
        NXTDumb (119)
        NXTIIC (120)
        InputDumb (121)
        InputUART (122)
        OutputDumb (123)
        OutputIntelligent (124)
        OutputTacho (125)
        None (126)
        Error (127)
    end
end
