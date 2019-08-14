% sepData - store images & videos separate from raw data 
%           by moving videos (.mp4) & color/depth pic folders to 
%           another folder ('ImagesOnly').
%
% Usage:
%   >> sepData('.\Data\ExampleData\[...]\Recording_1')
%
% Input:
%   recPath - full path to current recording folder
% 
% Output:
%   This function has no output arguments.

function sepData(recPath)

    % get information from base workspace
    source = evalin('base','source'); % (relative) path to study data folder
    subject = evalin('base','Subject{s}'); % TimeStamp & SubjectName 
    baseline = evalin('base', 'Baseline{b}'); % e.g. Baseline 2
    
    % create new folder for each baseline subfolder in ImagesOnly 
    ImagesOnly = fullfile(source, 'ImagesOnly', subject, baseline); 
    if ~(exist(ImagesOnly))
        mkdir(ImagesOnly)
    end
    
    % list all subfolders & files in current recording folder 
    Folders = dir(fullfile(recPath, '..'));
    nameFolds = {Folders.name};
    nameFolds(ismember(nameFolds,{'.','..'})) = []; 
    
    % pattern = [".mp4", "Color", "Depth"]; % compatibility starting with R2017a
    
    % move .mp4 files & folders containing "Color" or "Depth"
    for iName = 1:length(nameFolds)
        % if contains(nameFolds(iName), pattern) % R2017a or later
        % if isempty(regexp(nameFolds(iName), 'Recording_[0-9]$'))
        if any([contains(nameFolds(iName), '.mp4'), ...
               contains(nameFolds(iName), 'Color'), ...
               contains(nameFolds(iName), 'Depth')])
            filePath = fullfile(Folders(iName).folder, nameFolds(iName));
            movefile(filePath{1}, ImagesOnly, 'f')        
        end
    end % all folders/files matching the pattern moved to ImagesOnly