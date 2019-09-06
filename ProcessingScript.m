%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% V1.0 (14.08.2019)
%
% MATLAB processing script. Generally step two in the recording and 
% analysis of Kinect body posture data.
%
% Prerequisites:
%   To use the processing script specify the directory to the study data 
%   folder in the variable "source". 
%   The structure below the indicated folder should comprise three levels. 
%   The first level would be the subject level with one folder for each 
%   subject. Each subject folder comprises Baseline/Test folders in which 
%   the Recording folders with the single .mat frame files should be stored.
%   Note that the required subfunctions should be located in the folder
%   "processing" which is a subfolder of "sub". 
%
% Usage:
%   Before you are ready to start the processing script, it is necessary to
%   change the directory to the study data folder. Therefore you have to 
%   modify the variable "source". Thus the directory to the ExampleData 
%   folder has to be replaced with the path to your own study data folder 
%   (e.g. "myData").
%
%   Once you run the script a window will pop up - the processing GUI.
%   By ticking the individual checkboxes the corresponding processing will 
%   be executed as soon as the ok button will be pressed.
%   The listbox on the right-hand side of the GUI could be used to browse 
%   through the content of the folders. Selecting a folder inside the
%   listbox won't change the indicated folder with the data to be processed. 
%
% This is written for Mac OS (i.e., specification of folder structure).
%
% Last changes August 2019 by K. Speck
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs: 
%   guiData - Output from GUI
%             char string; logical values indicating selection by '1'
% 
%   >> guiData(1)   - greyscale images
%   >> guiData(2)   - halfsize images
%   >> guiData(3)   - extract colorframes with skeleton
%   >> guiData(4)   - extract colorframes 
%   >> guiData(5)   - extract depthframes with skeleton
%   >> guiData(6)   - extract depthframes
%   >> guiData(7)   - extract & save skeleton data
%   >> guiData(8)   - extract video (.mp4) from color images
%   >> guiData(9)   - delete original color & depth data (irreversible)
%   >> guiData(10)  - move videos & image Folders in separate folder
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup  
%Clear workspace.
clear all;

% should be path to current .m-file; !relative paths for data & functions
wdFile = pwd;

% Location of recordings. Change accordingly!
source = ('./Data/ExampleData');

% Add directory with required functions. 
addpath('./sub/processing');

% Initiate GUI.
data = [];
guiData = processingGUI(data); % selected options in GUI

% prepares input for data extraction function (skData2txt.m)
% initial value to create new .txt file
newFile = [0 1]; 
% prepare fileName
sourceSplit = strsplit(source, '/'); 
studyName = sourceSplit{end};
TimeStamp = datestr(now, 30);
fileName = strcat('SummaryData/', TimeStamp, '_SkeletonData_', ...
                  studyName,'.txt');

% preparations for "delete originals"
del = {}; % will be filled with recPaths if "delete originals" chosen
j = 1; % counter variable for del 

%%
% Check for user selection in toggle boxes (any option chosen).
if ~isequal(guiData, '0000000000') 
    % set working directory (might be changed by GUI)
    cd(wdFile)
    
    % enter directory structure (subject - baseline - recording)
    Subject = nameFoldDir(source); % subject folders in Data
    for s=1:length(Subject)
        disp(Subject{s});
        
        % get baseline/test folders
        Baseline = nameFoldDir(strcat(source,'/',Subject{s})); 
        for b=1:length(Baseline)
            disp(Baseline{b});
            
            % get recording folders
            Recording = nameFoldDir(strcat(source,'/',Subject{s},'/',...
                                           Baseline{b})); 
            for r=1:length(Recording)
                
                % full path to current recording folder
                recPath = strcat(source,'/',Subject{s},'/',Baseline{b},...
                                        '/',Recording{r}); 
                
                % list all frame files in current recording folder                    
                Files  = dir(fullfile(recPath,'FRM*.mat')); 
                nFrames = numel(Files); 
                
                % start processing if any frames in recording folder
                if (nFrames > 0)
                    disp(Recording{r});
                    
                    % store recPaths in del if "delete originals" chosen
                    if (guiData(9) == '1')  
                        del{j,1} = recPath; 
                        j = j + 1; 
                    end 
                    
                    % processing for each frame file (.mat) 
                    for iFrames = 1:nFrames 
                        
                        % get frame file data (.mat)
                        f = Files(iFrames).name; 
                        load(fullfile(recPath,f));  
                        
                        % resize &/| greyscale colorframes
                        resizeMatF(guiData(1:2));
                        
                        % extract Colorimages with/without skeleton 
                        if (exist('imgColor1','var') && exist('metaData_Depth1','var')) 
                            ExtractPNGs(metaData_Depth1, imgColor1,1,...
                                        guiData(3),guiData(4),'Color');
                        end % color png-files generated
                        
                        % extract Depthimages with/without skeleton 
                        if (exist('imgDepth1','var') && exist('metaData_Depth1','var'))
                            ExtractPNGs(metaData_Depth1, imgDepth1,1,...
                                        guiData(5),guiData(6),'Depth');
                        end % depth png-files generated
                        
                    end
                    
                    % write Skeleton-Data to txt-File
                    if (guiData(7) == '1')
                        newFile = skData2txt(newFile, fileName);
                    end % txt-File filled 
                    
                    % write color frames to video file 
                    if (guiData(8) == '1'), extractVideo(recPath); end
                    
                    % separate generated images & videos from raw data
                    if (guiData(10) == '1'), sepData(recPath); end
                end 
            end
        end   
    end
    
    % delete color- & depthsinformation from original mat-files
    if (guiData(9) == '1') 
        % for each recording folder stored in del
        for d = 1:size(del,1) 
            dirData = dir(del{d,1}); % paths to frame files (.mat)
            dirData([dirData.isdir]) = [];  
            
            % for each frame file in current recording folder
            for e = 1:size(dirData,1)
                cFile = load(fullfile(del{d}, dirData(e).name));
                
                metaData_Depth1 = NaN;
                if isfield(cFile, 'metaData_Depth1')
                    metaData_Depth1 = cFile.metaData_Depth1;
                end % depth meta data extracted
                
                % overwrite current mat-file (with only metaData) 
                save(fullfile(del{d},'/',dirData(e).name),...
                     'metaData_Depth1');
            end        
        end
    end
end
