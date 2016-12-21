function isValid = isDeviceValid(deviceType, device)
% Returns whether given device object is valid or not.
    isValid = 0;
    try 
        if ~isempty(device)
            if isa(device, deviceType) && device.isvalid
                isValid = 1;
            end
        end
    catch ME
        % Ignore
    end
end
