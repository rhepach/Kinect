% nameFoldDir - returns cell array of subfolder names 
% 
% Usage:
%    >> [nameFolds] = nameFoldDir(sourcePath)
% 
% Inputs:
%     sourcePath  - char vector path name | string scalar {default '.'} 
% 
% Outputs:
%     nameFolds   - cell array of subfolder names

function nameFolds = nameFoldDir(sourcePath)  
    d = dir(sourcePath); 
    iSub = [d(:).isdir]; % logical vector indicating subdirectories by 1
    nameFolds = {d(iSub).name}; % subfolder names
    nameFolds(ismember(nameFolds,{'.','..'})) = []; 
end