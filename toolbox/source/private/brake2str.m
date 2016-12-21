function brake = brake2str(inp)
% Converts given brakeMode-enum to corresponding string.
    if ~ischar(inp)
        switch inp
            case BrakeMode.Coast
                brake = 'Coast';
            case BrakeMode.Brake
                brake = 'Brake';
            otherwise
                error('brake2str: Given parameter is not a valid brake mode.');
        end
    else
        warning('brake2str: Given parameter already is a string.');
        brake = inp;
    end
end

