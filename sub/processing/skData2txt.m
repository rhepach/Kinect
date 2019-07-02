% skData2txt - Write skeleton data to textfile.
% 
% Usage:
%    >> [0 0] = skData2txt([0 1]) % (opens or) creates file "SkeletonData";
%                                 % discards any existing content in file
%    >> [0 0] = skData2txt([0 0]) % opens (or creates) file "SkeletonData";
%                                 % appends new data to the end of the file
% 
% Inputs:
%   newFile     - vector of class double; [0 1] (initial value) | [0 0]
% 
% Outputs:
%   newFile     - vector of class double; [0 0]

function[newFile] = skData2txt(newFile)
   skPoints = {'Hip_Center', 'Spine', 'Shoulder_Center', 'Head', ...
               'Shoulder_Left','Elbow_Left','Wrist_Left','Hand_Left',...
               'Shoulder_Right','Elbow_Right','Wrist_Right','Hand_Right',...
               'Hip_Left','Knee_Left','Ankle_Left','Foot_Left',...
               'Hip_Right','Knee_Right','Ankle_Right','Foot_Right'};
   colors = {'blue','green','red','yellow','magenta','cyan','black'};
   
   source = evalin('base','source'); 
  
   % create new file "SkeletonData" 
   if (sum(newFile) ~= 0) 
       skDataFile = fopen(strcat(source,'/SkeletonData','.txt'),'w'); 
       
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
        skDataFile = fopen(strcat(source,'/SkeletonData','.txt'),'a'); 
        newFile(1,2) = 0; % newFile = [0 0]; to avoid overwrite  
   end   
   
   % get information from base workspace
   subject = evalin('base','Subject{s}'); 
   trial = evalin('base','Baseline{b}'); 
   rec = evalin('base','Recording{r}'); % e.g. Recording_3
   rec = split(rec,'_'); % rec{end} = number of recording (e.g. 3) 
   recPath = evalin('base','recPath');
   
   Files  = dir(fullfile(recPath,'FRM*.mat')); % frame files
   nFrames = numel(Files);
   
   for iFrame = 1:nFrames
        f = Files(iFrame).name;
        load(fullfile(recPath,f)); % data from frame file (.mat)
        fName = f(1:end-4); % file name without '.mat'
        
        if (exist('metaData_Depth1', 'var') == 1 && isstruct(metaData_Depth1) == 1)
            jwc = metaData_Depth1.JointWorldCoordinates;
            
            % append joint coordinates (skeletal data) to .txt-file
            for k = 1:6 % 6 = number of matrices in jwc             
                if ~isequal(jwc(:,:,k), zeros(20, 3)) 
                    % Subject   Trial	Recording
                    fprintf(skDataFile,'%s\t%s\t%s\t', subject, trial, rec{end});
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