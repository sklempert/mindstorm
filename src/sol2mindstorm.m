function [ transformed_solution ] = sol2mindstorm( solution )

transformed_solution = {}
for i=1:numel(solution)
    move = solution{i};
    switch move(1)
        case 'U'
            transformed_solution{end+1} = ['X' ,''''];
            transformed_solution{end+1} = ['X' ,''''];
            if (numel(move)>1)
                transformed_solution{end+1} = ['D' , move(2)];
            else
                transformed_solution{end+1} = 'D';
            end
            transformed_solution{end+1} = ['X' ,''''];
            transformed_solution{end+1} = ['X' ,''''];           
        case 'L'
            transformed_solution{end+1} = ['Y' ,''''];
            transformed_solution{end+1} = ['X' ,''''];
            if (numel(move)>1)
                transformed_solution{end+1} = ['D' , move(2)];
            else
                transformed_solution{end+1} = 'D';
            end
            transformed_solution{end+1} = ['Y' ,''''];
            transformed_solution{end+1} = ['Y' ,''''];
            transformed_solution{end+1} = ['X' ,''''];
            transformed_solution{end+1} = ['Y' ,''''];
        case 'F'
            transformed_solution{end+1} = ['X' ,''''];
            if (numel(move)>1)
                transformed_solution{end+1} = ['D' , move(2)];
            else
                transformed_solution{end+1} = 'D';
            end
            transformed_solution{end+1} = 'Y';
            transformed_solution{end+1} = 'Y';
            transformed_solution{end+1} = ['X' ,''''];
            transformed_solution{end+1} = 'Y';
            transformed_solution{end+1} = 'Y';
        case 'R'
            transformed_solution{end+1} = 'Y';
            transformed_solution{end+1} = ['X' ,''''];
            if (numel(move)>1)
                transformed_solution{end+1} = ['D' , move(2)];
            else
                transformed_solution{end+1} = 'D';
            end
            transformed_solution{end+1} = 'Y';
            transformed_solution{end+1} = 'Y';
            transformed_solution{end+1} = ['X' ,''''];
            transformed_solution{end+1} = 'Y';
        case 'B'
            transformed_solution{end+1} = 'Y';
            transformed_solution{end+1} = 'Y';
            transformed_solution{end+1} = ['X' ,''''];
            if (numel(move)>1)
                transformed_solution{end+1} = ['D' , move(2)];
            else
                transformed_solution{end+1} = 'D';
            end
            transformed_solution{end+1} = 'Y';
            transformed_solution{end+1} = 'Y';
            transformed_solution{end+1} = ['X' ,''''];
        case 'D'
            transformed_solution{end+1} = move;
        otherwise
            error(['Untransformable move ', move, ' found in solution']);
    end
end

