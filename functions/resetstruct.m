function [struct] = resetstruct(varargin)
% [struct] = resetstruct(struct,set_to)
%
% This function sets all fields of a structure to zero. Each element
% retains the same size.
%
%
% -------------------------------------------------------------------------
% ------------------------------- INPUTS ----------------------------------
%   struct = structure with nonzero fields
%   set_to = string describing value to set all elements of the structure
%            accepted values: 'zero', 'one', 'nan'
% -------------------------------------------------------------------------
%
%
% -------------------------------------------------------------------------
% ------------------------------ OUTPUTS ----------------------------------
%   struct = structure with all fields set to zero
% -------------------------------------------------------------------------

if nargin==2
    struct = varargin{1};
    set_to = varargin{2};
elseif nargin==3
    struct = varargin{1};
    index  = varargin{2};
    set_to = varargin{3};
end

if strcmp(set_to,'zero') || strcmp(set_to,'one') || strcmp(set_to,'nan')
    %you enetered an acceptable input!
else
    error(['The ''set_to'' variable must be a string. Accepted values'...
        ' are: ''zero'', ''one'', or ''nan''.'])
end

if isstruct(struct)
    names = fieldnames(struct);
else
    in = input(['The input is not a structure. Reset values anyways?'...
        ' (Y/N)\n'],'s');
    if strcmp(in,'Y') || strcmp(in,'y')
        switch set_to
            case 'zero'
                struct = 0;
            case 'one'
                struct = 1;
            case 'nan'
                struct = NaN;
        end
    end
    
    return;
end

for i = 1:length(names)    
    if nargin==2
        if isstruct(struct.(names{i}))
            struct.(names{i}) = resetstruct(struct.(names{i}),set_to);
        else
            sz = size(struct.(names{i}));
            switch set_to
                case 'zero'
                    struct.(names{i}) = zeros(sz);
                case 'one'
                    struct.(names{i}) = ones(sz);
                case 'nan'
                    struct.(names{i}) = NaN(sz);
            end
        end
    elseif nargin==3
        if isstruct(struct.(names{i}))
            struct.(names{i}) = resetstruct(struct.(names{i}),index,set_to);
        else
            switch set_to
                case 'zero'
                    struct.(names{i})(index) = 0;
                case 'one'
                    struct.(names{i})(index) = 1;
                case 'nan'
                    struct.(names{i})(index) = NaN;
            end
        end
    end
end



