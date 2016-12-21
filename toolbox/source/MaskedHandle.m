classdef MaskedHandle < handle
    methods (Hidden)
        function addlistener(varargin)
            addlistener@addlistener(varargin{:})
        end
        
        function findobj(varargin)
            findobj@findobj(varargin{:});
        end
        
%         function findprop(varargin)
%             findprop@findprop(varargin{:});
%         end

        function notify(varargin)
            notify@notify(varargin{:});
        end
        
        function ge(h1, h2)
            ge@ge(h1, h2); 
        end
        
        function gt(h1, h2)
            gt@gt(h1, h2); 
        end
        
        function le(h1, h2)
            le@le(h1, h2); 
        end
        
        function lt(h1, h2)
            lt@lt(h1, h2); 
        end
        
        function ne(h1, h2)
            ne@ne(h1, h2); 
        end
        
        function eq(h1, h2)
            eq@eq(h1, h2); 
        end  
    end
end

