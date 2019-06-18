%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Matlab processing script. Generally step two in the analysis of Kinect
% body posture data.
% 
% Currently used in:
%
% Study: ProShame (2018)
% Researchers: Jan Engelmann, Bianca Dietrich, Stella Gerdemann, 
% Jenny Tippmann, & Robert Hepach
% 
% Study: Posture CrossCultural (2018)
% Researchers: Antje von Suchodoletz & Robert Hepach
% 
% Important information: This script is part of an ongoing line of research
% and it is continuously updated. Those familiar with Matlab
% will notice redundancies in the code and room for improvement. You are,
% of course, free to make changes to the script for your own purposes but
% you do so at your own risk.
%
% If you use the script or find it generally useful kindly support our
% research by citing our work (see bottom of the script).
%
% The checksum for the latest tested version is: 
%
% Script written by Anja Neumann.
% Script maintained by Robert Hepach.
% Contact: robert.hepach@uni-leipzig.de
%
% Last changes 08.11.2018 by Robert Hepach
% Fixed delete function for images within mat-files to reduce file size. 
%
% This is written for Mac OS (i.e., specification of folder structure).
%
% See bottom of the script for known bugs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% Inputs: 
%   guiData - Output from GUI
%             char string; logical values indicating selection by '1'
% 
%   >> guiData(1) - greyscale images
%   >> guiData(2) - halfsize images
%   >> guiData(3) - extract colorframes with skeleton
%   >> guiData(4) - extract colorframes 
%   >> guiData(5) - extract depthframes with skeleton
%   >> guiData(6) - extract depthframes
%   >> guiData(7) - extract & save skeleton data
%   >> guiData(8) - delete original color & depth images (irreversible)

%% Setup  
%Clear workspace.
clear all;

% should be path to current .m-file; !relative paths for data & functions
wdFile = pwd;

% Add directory with required functions. 
addpath('.\sub_110619\processing');
% addpath('C:\Users\ks56cyvu\Desktop\MProjekt\sub_110619\processing');

% Location of recordings. Change accordindly!
source = ('.\Data');
% source = ('C:\Users\ks56cyvu\Desktop\MProjekt\Data');

% Initiate GUI.
data = [];
guiData = processingGUI(data); % selected options in GUI

newFile = [0 1]; % Input for skData2txt; initial value to create new file
del = {}; % will be filled with recPaths if "delete originals" chosen
j = 1; % counter variable for del 

%%
% Check for user selection in toggle boxes (any option chosen).
if ~isequal(guiData, '00000000') 
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
                
                Files  = dir(fullfile(recPath,'FRM*.mat')); 
                nFrames = numel(Files); 
                
                % start processing if any frames in recording folder
                if (nFrames > 0)
                    disp(Recording{r});
                    
                    % store recPaths in del if "delete originals" chosen
                    if (guiData(8) == '1')  
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
                        newFile = skData2txt(newFile);
                    end % txt-File filled 
                end 
            end
        end   
    end
    
    % delete color- & depthsinformation from original mat-files
    if (guiData(8) == '1') 
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

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Known bugs (18.06.2019)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Hepach, R., Vaish, A., & Tomasello, M. (2015). Novel paradigms to measure
% variability of behavior in early childhood: posture, gaze, and pupil 
% dilation. Frontiers in psychology, 6, 858.
% 
% Hepach, R., Vaish, A., & Tomasello, M. (2017). The fulfillment of others’
% needs elevates children’s body posture. Developmental psychology, 53(1), 
% 100.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
