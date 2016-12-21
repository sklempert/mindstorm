function isValid = isModeValid(mode, type)
% Returns whether given mode is a valid mode in given type.
    isValid = true;
    
    if strcmp(class(mode), 'DeviceMode.Default')
        return;
    end

    switch type
        case DeviceType.NXTTouch
            if ~strcmp(class(mode), 'DeviceMode.NXTTouch')
                isValid = false;
            end
        case DeviceType.NXTLight
            if ~strcmp(class(mode), 'DeviceMode.NXTLight')
                isValid = false;
            end
        case DeviceType.NXTSound
            if ~strcmp(class(mode), 'DeviceMode.NXTSound')
                isValid = false;
            end
        case DeviceType.NXTColor
            if ~strcmp(class(mode), 'DeviceMode.NXTColor')
                isValid = false;
            end
        case DeviceType.NXTUltraSonic
            if ~strcmp(class(mode), 'DeviceMode.NXTUltraSonic')
                isValid = false;
            end
        case DeviceType.NXTTemperature
            if ~strcmp(class(mode), 'DeviceMode.NXTTemperature')
                isValid = false;
            end
        case DeviceType.LargeMotor
            if ~strcmp(class(mode), 'DeviceMode.Motor')
                isValid = false;
            end
        case DeviceType.MediumMotor
            if ~strcmp(class(mode), 'DeviceMode.Motor')
                isValid = false;
            end
        case DeviceType.Touch
            if ~strcmp(class(mode), 'DeviceMode.Touch')
                isValid = false;
            end
        case DeviceType.Color
            if ~strcmp(class(mode), 'DeviceMode.Color')
                isValid = false;
            end
        case DeviceType.UltraSonic
            if ~strcmp(class(mode), 'DeviceMode.UltraSonic')
                isValid = false;
            end
        case DeviceType.Gyro
            if ~strcmp(class(mode), 'DeviceMode.Gyro')
                isValid = false;
            end
        case DeviceType.InfraRed
            if ~strcmp(class(mode), 'DeviceMode.InfraRed')
                isValid = false;
            end
        case DeviceType.HTColor
            if ~strcmp(class(mode), 'DeviceMode.HTColor')
                isValid = false;
            end
        case DeviceType.HTCompass
            if ~strcmp(class(mode), 'DeviceMode.HTCompass')
                isValid = false;
            end
        case DeviceType.HTAccelerometer
            if ~strcmp(class(mode), 'DeviceMode.HTAccelerometer')
                isValid = false;
            end
        otherwise
            isValid = false;
    end
end

