function isValid = isCommInterfaceValid(comm)
% Returns whether given brick object is valid or not.
    isValid = 0;
    if ~isempty(comm)
        % The second case (after the '||') is allowed as a default value (think of it as a nullptr).
        if (isa(comm, 'CommunicationInterface') && comm.isvalid) || ...
           (isnumeric(comm) && comm==0)
            isValid = 1;
        end
    end
end

