% skData2txt - Write skeleton data to textfile in folder "summaryData".
% 
% Usage:
%    >> [0 0] = skData2txt([0 1]) % (opens or) creates file;
%                                 % discards any existing content in file
%    >> [0 0] = skData2txt([0 0]) % opens (or creates) file;
%                                 % appends new data to the end of the file
% 
% Inputs:
%   newFile     - vector of class double; [0 1] (initial value) | [0 0]
%   fileName    - char vector; path to summaryData folder; 
%                              name includes TimeStamp & StudyName 
%
% Outputs:
%   newFile     - vector of class double; [0 0]
%
% Content of .txt file (tab separated)
%   Subject    - subject folder name with time stamp & subject name 
%                e.g "20190807T151654_002"
%   Trial      - baseline folder name (level 2) e.g. "Baseline 2"
%   Recording  - identifier extracted from recording folder name (level 3)
%                e.g. 1_3 in case of "Recording_1_3"
%   Frame      - frame number & time stamp extracted from .mat file name
%   Kinect     - indicates which Kinect (1 or 2); set to 1 
%   Sk_color   - color in colors depending on slot of tracked skeleton (1:6)
%   20 Skeleton Points (see skPoints):
%   Hip_Center - JointWorldCoordinate from meta data for hip center 
%   Spine      - JointWorldCoordinate from meta data for spine
%   ...

function[newFile] = skData2txt(newFile, fileName)
   colors = {'blue','green','red','yellow','magenta','cyan','black'};
   skPoints = {'Hip_Center', 'Spine', 'Shoulder_Center', 'Head', ...
               'Shoulder_Left','Elbow_Left','Wrist_Left','Hand_Left',...
               'Shoulder_Right','Elbow_Right','Wrist_Right','Hand_Right',...
               'Hip_Left','Knee_Left','Ankle_Left','Foot_Left',...
               'Hip_Right','Knee_Right','Ankle_Right','Foot_Right'};
   
   % get information from base workspace
   subject = evalin('base','Subject'); % Timestamp_SubjectName
   trial = evalin('base','Baseline'); % e.g. Baseline 2
   rec = evalin('base','Recording'); % e.g. Recording_3
   recPath = evalin('base','recPath'); % path to current recording folder
   
   % extract recording identifier
   rec = strsplit(rec,'_');  
   rec = {rec{2:length(rec)}}; % exclude 'Recording' from identifier
   recIx = strjoin(rec, '_'); % recording identifier 
   
   
   % create folder for summarized (skeleton) Data
   if ~(exist('SummaryData', 'dir'))
       mkdir('SummaryData')
   end
  
   % create new file "SkeletonData" 
   if (sum(newFile) ~= 0) 
       skDataFile = fopen(fileName,'w'); 
       
       % write header (tab-separated) - basic information
       fprintf(skDataFile,'%s\t%s\t%s\t%s\t',... 
               'Subject','Trial','Recording','Frame','Kinect','Sk_color'); 
       
       % skeletal points on 3 dimensions each (e.g. Hip_Center_X, Spine_Y)
       xyz = {'X','Y','Z'}; 
       for i = 1:size(skPoints, 2) 
           for j = 1:size(xyz, 2) 
                fprintf(skDataFile,'%s\t',... 
                        strcat(skPoints{1,i},'_',xyz{1,j})); 
           end % 3 variables per skPoint added to header 
       end % header for skDataFile written in SkeletonData.txt 
       
       fprintf(skDataFile,'\n'); 
       newFile(1,2) = 0; % newFile = [0 0]; to avoid overwrite 
   
   % open file "SkeletonData" & append data to end of file 
   else 
        skDataFile = fopen(fileName,'a'); 
        newFile(1,2) = 0; % newFile = [0 0]; to avoid overwrite  
   end   
   
   % list all frame files in current recording folder 
   Files  = dir(fullfile(recPath,'FRM*.mat')); 
   nFrames = numel(Files);
   
   for iFrame = 1:nFrames
        f = Files(iFrame).name;
        load(fullfile(recPath,f)); % data from frame file (.mat)
        fName = f(1:end-4); % file name without '.mat'
        
        if (exist('metaData_Depth1', 'var') == 1 && isstruct(metaData_Depth1) == 1)
            jwc = metaData_Depth1.JointWorldCoordinates;
            
            % append joint coordinates (skeletal data) to .txt-file
            for k = 1:6 % all possible slots for tracked skeletons in jwc             
                if ~isequal(jwc(:,:,k), zeros(20, 3)) 
                    % Subject   Trial	Recording identifier
                    fprintf(skDataFile,'%s\t%s\t%s\t', subject, trial, recIx);
                    % Frame Kinect  Sk_color
                    fprintf(skDataFile,'%s\t%d\t%s\t', fName(4:end), 1, colors{k});
                    % joint coordinates (3 at once)
                    fprintf(skDataFile,'%f\t%f\t%f\t', jwc(:,:,k).'); 
                    
                    % This illustrates how the above row works 
                    % to write three elements in a column 'at once'
                    % temp = jwc(:,:,k).'; 
                    % fprintf(f,'%f\t', temp(:).');
                    
                    fprintf(skDataFile,'\n');
                end
            end
        end
        
   end   
   fclose(skDataFile);
end