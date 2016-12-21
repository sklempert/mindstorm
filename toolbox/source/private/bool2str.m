function bool = bool2str(inp)
% Converts given bool-numeric to corresponding string.

    bool = 'off';
    if ischar(inp)
        bool = inp;
    elseif isnumeric(inp)
        if inp==1
            bool = 'on';
        elseif inp~=0
            error('bool2str: Not a valid boolean.');
        end
    elseif islogical(inp)
        if inp==true
            bool = 'on';
        end
    end

end

