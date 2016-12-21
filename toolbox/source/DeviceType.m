classdef DeviceType < uint8
    enumeration
        NXTTouch (1)
        NXTLight (2)
        NXTSound (3)
        NXTColor (4)
        NXTUltraSonic (5)
        NXTTemperature (6)
        LargeMotor (7)
        MediumMotor (8)
        Touch (16)
        Color (29)
        UltraSonic (30)
        Gyro (32)
        InfraRed (33)
        HTColor (54)
        HTCompass (56)
        HTAccelerometer (58)
        Unknown (125)
        None (126)
        Error (127)
    end
end
