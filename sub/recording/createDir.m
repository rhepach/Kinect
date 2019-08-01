% createDir - creates folder for current number of recording
%             + sets RecordPath to created folder.
% 
% Inputs:
%   x     - string; Time Stamp & Subject Name
%   b     - string; Baseline Folder, Recording, Number of Recording
%
function createDir(x,b)
    global RecordPath;
    
    % creates folder for current number of recording
    mkdir(strcat('Data','/',x),b)
    % sets RecordPath to created folder
    RecordPath = fullfile(strcat('Data','/',x),b);
    
end