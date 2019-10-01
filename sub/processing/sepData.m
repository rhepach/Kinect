% sepData - store images & videos separate from raw data 
%           by moving videos (.mp4) & color/depth pic folders to 
%           another folder ('ImagesOnly_20190702T122833').
%
% Usage:
%   >> sepData('./Data/ExampleData/[...]/Recording_1', '20190702T122833')
%
% Input:
%   recPath     - full path to current recording folder
%   TimeStamp   - char vector; date & time 
% 
% Output:
%   This function has no output arguments.

function sepData(recPath)

    % get information from base workspace
    source = evalin('base','source'); % (relative) path to study data folder
    subject = evalin('base','Subject{s}'); % TimeStamp & SubjectName 
    baseline = evalin('base', 'Baseline{b}'); % e.g. Baseline 2
    
    % new folder path (if any content to move available)
    ImagesOnly = fullfile(source, ['ImagesOnly_'  TimeStamp], ...
                          subject, baseline);
    
    % list all subfolders & files in current recording folder 
    Folders = dir(fullfile(recPath, '..'));
    nameFolds = {Folders.name};
    
    % take into account only data corresponding to the current recPath
    rec = strsplit(recPath, filesep);
    pattern = rec{end};
    ix = strfind(nameFolds, pattern);
    index = find(not(cellfun('isempty', ix)));
    nameFolds = nameFolds(index); 
 
    % compatibility for R2017a or later
%     pattern = [".mp4", "Color", "Depth"];
        
    % move .mp4 files & folders containing "Color" or "Depth"
    for iName = 1:length(nameFolds)
        
%         if contains(nameFolds(iName), pattern) % R2017a or later
        if any([contains(nameFolds(iName), '.mp4'), ...
               contains(nameFolds(iName), 'Color'), ...
               contains(nameFolds(iName), 'Depth')])
           
            % create new folder for each baseline subfolder in ImagesOnly 
            if ~(exist(ImagesOnly))
                mkdir(ImagesOnly)
            end
            
            filePath = fullfile(Folders(iName).folder, nameFolds(iName));
            movefile(filePath{1}, ImagesOnly, 'f')        
        end
    end % all folders/files matching the pattern moved to ImagesOnly