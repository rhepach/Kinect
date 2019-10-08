% nameFoldDir - returns cell array of subfolder names with .mat frame files 
%               (by matching file names to the pattern '^FRM*.mat$');
%               recursive function 
% 
% Usage:
%    >> [nameFolds] = nameFoldDir(sourcePath, folderNames)
% 
% Inputs:
%     sourcePath  - char vector path name | string scalar {default '.'} 
%     folderNames - initial value is empty cell array
% 
% Outputs:
%     nameFolds   - cell array of folder names with .mat frame files

function folderNames = nameFoldDir(sourcePath, folderNames)  
    d = dir(sourcePath); 
    d(ismember({d.name}, {'.', '..'})) = []; % remove "navigator" directories 
    iSub = [d(:).isdir]; % logical vector indicating subdirectories by 1
    
    % in case of no subdirectories inside the non-empty folder (base case)
    if ~(any(iSub == 1)) && ~(isempty(iSub)) 
        % check if any file names match the mat frame file name pattern
        f = {d.name};
        ix = find(~cellfun(@isempty, regexp(f, '.mat$')) & ...
                 (~cellfun(@isempty, regexp(f, '^FRM'))));
        
        % if mat frame files in folder append path to output variable
        if ~(isempty(ix))    
            folderNames{end+1} = d(1).folder;   
        end
          
    % in case of subdirectories inside the folder (recursion)    
    elseif any(iSub == 1)
        % function is called with each subdirectory inside the folder 
        for iSubfolder = 1:length(iSub)
            if iSub(iSubfolder) == 1 
                subfolderName = fullfile(sourcePath, d(iSubfolder).name);
                folderNames = nameFoldDir(subfolderName, folderNames);
            end
        end
    end 
end