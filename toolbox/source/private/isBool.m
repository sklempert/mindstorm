function isValid = isBool(inp)
% Returns whether given boolean is valid or not.
    if ischar(inp)
        isValid = strcmpi(inp, 'on') || strcmpi(inp, 'off');
    elseif isnumeric(inp)
        isValid = inp==1 || inp==0;
    else
        isValid = islogical(inp);
    end
end

