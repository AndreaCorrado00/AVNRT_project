function class = get_class_name(map_type)
%GET_CLASS_NAME Returns the qualitative classification for a given map type.
%
%   class = GET_CLASS_NAME(map_type) returns the descriptive class name
%   associated with the specified map type identifier.
%
%   Input:
%       map_type (char or string): Identifier of the map type. Expected values are:
%           - 'MAP_A'
%           - 'MAP_B'
%           - 'MAP_C'
%
%   Output:
%       class (char): A qualitative label corresponding to the input map type:
%           - 'MAP_A' → 'Indifferent'
%           - 'MAP_B' → 'Effective'
%           - 'MAP_C' → 'Dangerous'
%
%   Notes:
%       - If the input does not match any known map type, the result will be empty.
%         Consider adding input validation or error handling if needed.
%
% Author: Andrea Corrado
% -------------------------------------------------------------------------

classes=["MAP_A","Indifferent";
         "MAP_B","Effective";
         "MAP_C","Dangerous";];

class=classes(strcmp(map_type,classes(:,1)),2);