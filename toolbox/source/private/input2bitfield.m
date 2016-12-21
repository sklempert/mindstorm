function bitfield = input2bitfield(varargin)
% Converts motor-inputport-number(s) to motor-bitfield.
    if nargin==1
        bitfield = port2bitfield(input2port(varargin{1}));
    elseif nargin==2
        bitfield = port2bitfield(input2port(varargin{1}), input2port(varargin{2}));
    end
end
