function bitfield = port2bitfield(varargin)
% Converts motor-port-number(s) to motor-bitfield.
    if nargin==1
        bitfield = uint8(2 ^ varargin{1});
    elseif nargin==2
        bitfield = uint8(2 ^varargin{1}+2^varargin{2});
    end
end
