function mode = DeviceMode(type, modeNo)
% Converts a mode number to corresponding mode-enum in given type.
    if ~strcmp(class(modeNo), 'uint8')
        error('MATLAB:RWTHMindstormsEV3:noclass:DeviceMode:invalidInputType',...
            'Argument ''modeNo'' is of type ''%s''. Valid types are: uint8.', ...
            class(modeNo));
    end
    
    try
        switch type
            case DeviceType.NXTTouch
                mode = DeviceMode.NXTTouch(modeNo);
            case DeviceType.NXTLight
                mode = DeviceMode.NXTLight(modeNo);
            case DeviceType.NXTSound
                mode = DeviceMode.NXTSound(modeNo);
            case DeviceType.NXTColor
                mode = DeviceMode.NXTColor(modeNo);
            case DeviceType.NXTUltraSonic
                mode = DeviceMode.NXTUltraSonic(modeNo);
            case DeviceType.NXTTemperature
                mode = DeviceMode.NXTTemperature(modeNo);
            case DeviceType.LargeMotor
                mode = DeviceMode.Motor(modeNo);
            case DeviceType.MediumMotor
                mode = DeviceMode.Motor(modeNo);
            case DeviceType.Touch
                mode = DeviceMode.Touch(modeNo);
            case DeviceType.Color
                mode = DeviceMode.Color(modeNo);
            case DeviceType.UltraSonic
                mode = DeviceMode.UltraSonic(modeNo);
            case DeviceType.Gyro
                mode = DeviceMode.Gyro(modeNo);
            case DeviceType.InfraRed
                mode = DeviceMode.InfraRed(modeNo);
            case DeviceType.HTColor
                mode = DeviceMode.HTColor(modeNo);
            case DeviceType.HTCompass
                mode = DeviceMode.HTCompass(modeNo);
            case DeviceType.HTAccelerometer
                mode = DeviceMode.HTAccelerometer(modeNo);
            otherwise
                mode = DeviceMode.Default.Undefined; % Need to think about this...
        end
    catch 
        error('MATLAB:RWTHMindstormsEV3:noclass:DeviceMode:invalidInputValue',...
              'ModeNo ''%d'' not valid for given type.', modeNo);
    end
end

