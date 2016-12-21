function id = ID()
% Generates a string that serves as an error-ID for a calling function

toolbox = 'RWTHMindstormsEV3';

% Get stack trace
stackTrace = dbstack();

% Element on top of stack is this function (ID()), second element is caller
% If no second element, caller is probably console -> not valid
if length(stackTrace) <= 1
    ME = MException('RWTHMindstormsEV3:ID', ...
        ['ID() is only function on stack - can not create ID. (You can''t call ID() from ',...
         'the console).']);
    throw(ME);
end
callerList = strsplit(stackTrace(2).name, '.');

% The anticipated format of the caller is classname.functionname
functionName = callerList{length(callerList)};

% Create id
if length(callerList) > 1
    className = callerList{length(callerList)-1};
    id = [toolbox, ':', className, ':', functionName];
else
    id = [toolbox, ':', functionName];
end

end

