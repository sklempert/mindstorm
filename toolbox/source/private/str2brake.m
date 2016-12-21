function brake = str2brake(inp)
% Converts a brake-string to corresponding enum-type.
    if ischar(inp)
        if strcmpi(inp, 'Coast')
            brake = BrakeMode.Coast;
        elseif strcmpi(inp, 'Brake')
            brake = BrakeMode.Brake;
        else
            error(['str2brake: Given parameter %s is not a valid brake mode. ',...
                   '(''Brake'' or ''Coast'')'], inp);
        end
    else 
        error('str2brake: Given parameter is not a string.');
    end
end
