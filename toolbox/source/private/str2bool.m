function bool = str2bool(inp)
% Converts a boolean-string to a numeric 0/1.

    bool = 0;
    if ischar(inp)
        if strcmpi(inp, 'on')
            bool = 1;
        elseif ~strcmpi(inp, 'off')
            error('str2bool: Given parameter is not a valid string.');
        end
    elseif isnumeric(inp) || islogical(inp)
        bool = inp;
    end
end
