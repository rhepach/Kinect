% createDir - creates folder for current number of recording
%             + sets RecordPath to created folder.
% 
% Inputs:
%   study       - string; usually name of study
%   subject     - string; usually Time Stamp & Subject Name
%   rec         - string; usually Baseline Folder, Recording, Number of Recording

function createDir(study, subject, recording)
    global RecordPath;
    
    % creates folder for current number of recording
    mkdir(strcat('Data','/',study,'/',subject),recording)
    % sets RecordPath to created folder
    RecordPath = fullfile(strcat('Data','/',study,'/',subject),recording);
    
end