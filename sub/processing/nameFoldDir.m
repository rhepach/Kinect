% nameFoldDir - returns cell array of subfolder names with .mat frame files;
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
    
    % in case of no subdirectories inside the folder (base case)
    if ~(any(iSub == 1)) 
        % append folder path to output variable
        folderNames{end+1} = d(1).folder;    
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