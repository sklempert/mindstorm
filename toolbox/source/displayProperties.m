function displayProperties(device)
cl = class(device);
if ~strcmp(cl, 'Motor') && ~strcmp(cl, 'Sensor') && ~strcmp(cl, 'EV3')
    error('displayProperties: Invalid device given (has to Motor, Sensor or EV3'); 
end

warning('off','all');

props = properties(device);  % Save list with property names as strings
dependentProps = {};

fprintf('   <a href="matlab:helpPopup %s">%s</a> with properties:\n\n', cl, cl);
fprintf('\tWritable\n');
% Print writable properties, leave out all the rest, leave out all the reeeest
for i = 1:length(props)
    p = props{i};
    meta = device.findprop(p);
    if meta.Dependent == 1
        dependentProps{end+1} = p;
        continue;
    elseif ~strcmp(meta.SetAccess, 'public') || ~strcmp(meta.GetAccess, 'public')
        continue;
    end

    if ~isempty(enumeration(device.(p)))  % Test if parameter is enumeration
        fprintf('\t%15s:   %s\n', p, char(device.(p)));
    elseif isnumeric(device.(p)) || islogical(device.(p))
        fprintf('\t%15s:   %d\n', p, device.(p));
    elseif ischar(device.(p))
        fprintf('\t%15s:   %s\n', p, device.(p));
    else
        %fprintf('Mep\n');
        %error('testing');
    end
end

fprintf('\n\tRead-only\n');
% Print dependent properties
for i = 1:length(dependentProps)
    p = dependentProps{i};

    if isempty(p)
        continue;
    end
    
    value = device.(p);
    if ~isempty(enumeration(value))  % Test if parameter is enumeration
        fprintf('\t%15s:   %s\n', p, char(value));
    elseif isnumeric(device.(p)) || islogical(value)
        if isfloat(value)
            fprintf('\t%15s:   %1.1f\n', p, value);
        else
            fprintf('\t%15s:   %d\n', p, value);
        end
    elseif ischar(device.(p))
        fprintf('\t%15s:   %s\n', p, value);
    elseif islogical(device.(p))

    end
end

warning('on','all');

end

