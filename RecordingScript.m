%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% V1.0 (14.08.2019)
%
% MATLAB recording script. Generally step one in the recording and analysis 
% of Kinect body posture data.
% 
% Prerequisites:
%   To use the recording script the Kinect should already be connected to 
%   your computer via a USB-port. Concerning the general setup of your
%   Kinect: Power On your Kinect first and then connect it to the computer.
%   Note that the required subfunctions should be located in the folder
%   "recording" which is a subfolder of "sub". 
%
% Usage:
%   Once you run the script an input in the command window will be 
%   requested. 
%   The indicated study name will be used to create the study data folder. 
%   Setting a default study name (line ) allows you to skip the manual 
%   input by pressing Enter. 
%   Subsequently the subject name will be requested. The input will be
%   used to create the subject folder (inside the study data folder) and 
%   will contain the entire recorded data of the subject.
%   By pressing the "Record" button the recording could be started/stopped.
%   For each recording period a separat recording folder with .mat frame 
%   files will be generated. By pressing the button in the right corner a
%   new folder above the recording folder level will be generated.
%   You could control the GUI by pressing the space bar to start/stop
%   recording and the right arrow to change the Baseline/Test Folder. 
%   
% Options:
%   Due to the current settings of flag.Video & vidopen a video file will
%   be generated and stored during recording. 
%   By setting flag.Video = 0 and vidopen = 1 the video creation could be 
%   turned off leading to a minor benefit in the frame rate. 
%   During data processing a video could be extracted by ticking the
%   checkbox "Generate Video (.mp4) from color images". 
%
%   By changing the values of gui.states inside the cellstr functions you 
%   could define the names of the folders below the subject level. 
%
% Last changes August 2019 by K. Speck
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters 

% set parameters for recording
studyName = input('Enter Name of Study\n', 's');

if isempty(studyName) % set default study name 
    studyName = 'exampleData'; % studyName
end

subjectName = input('Enter Name of Subject\n', 's');

% Add directory with required functions. 
addpath('./sub/recording') 

Frames        = Inf  ; % set max. number of Frames 
RecordingTime = Inf  ; % set max. recording time (in secs)
elevationAngle = 0;    % set elevation angle for both cameras
                            
global flag;
flag.Record      = 0   ; % 1 = starts continuous recording
flag.Preview     = 1   ; % realtime preview
flag.Video       = 1   ; % MP4-Video recording

global vidopen;          
vidopen = 0;             % 0 = video file to be initialized

global RecordPath;       % path to current recording folder
global timesofrec;       % counter for times of recording 
timesofrec = 1;          % used for folder names & in stop script function

% GUI related variables
global gui;              % see section "GUI functionality" for buttons                  
gui.states = [cellstr('Baseline 1'); cellstr('Baseline 2');...
          cellstr('Baseline 3');cellstr('Baseline 4');...
          cellstr('Baseline 5');cellstr('Baseline 6');...
          cellstr('Baseline 7');cellstr('Baseline 8');...
          cellstr('Test 1'); cellstr('Test 2')];
                         % vector of strings; folder name (below subject 
                         % folder level) & statebutton label
gui.cnt = 1;             % counter for states of statebutton   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% recording 

% reset kinect objects in memory
imaqreset

% initialize Kinect objects
clear vid;

% initialize Kinect hardware
vid(1) = videoinput('kinect', 1); % RGB camera 
vid(2) = videoinput('kinect', 2); % depth camera  

% prepare folder names
TimeStamp = datestr(now,30);
studyFolder = sprintf('%s_%s', 'Data', studyName);
subjectFolder = sprintf('%s_%s_%s',TimeStamp, studyName, subjectName);

% create folder for Data
if ~(exist('Data', 'dir'))
   mkdir('Data')
end

% create subfolder for Data of specific study
if ~(exist(fullfile('Data', studyFolder)))
    mkdir(fullfile('Data', studyFolder))
end

%% initialize Realtime Preview

if flag.Preview
   % create a figure
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % since 'zbuffer' has been removed, changed renderer to 'opengl'
   hFig = figure('Renderer','opengl','Colormap',jet(3000),...
                 'KeyPressFcn',@keyPress);
            
   % initialize subplots
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Plot 1 - colorimage with skeleton
   hAxes = subplot(1,2,1,'Parent',hFig,'box','on',...
                'XLim',[0.5 640.5],'Ylim',[0.5 480.5],'nextplot','add',...
                'YDir','Reverse','fontsize',7);
   title(hAxes,'Color / 2D Skeletal')
   hColor = image(NaN,'Parent',hAxes);
   hColor_Skelet_2D(1,:) = line(nan(2,6),nan(2,6),'Parent',hAxes,...
                                'Marker','o','MarkerSize',5,'LineWidth',2);
   %
   % Plot 2 - depthimage with skeleton
   hAxes = subplot(1,2,2,'Parent',hFig,'box','on',...
                'XLim',[0.5 640.5],'Ylim',[0.5 480.5],'nextplot','add',...
                'YDir','Reverse','fontsize',7);
   title(hAxes,'Depth / 2D Skeletal')
   hDepth = image(NaN,'Parent',hAxes);
   hDepth_Skelet_2D(1,:) = line(nan(2,6),nan(2,6),'Parent',hAxes,...
                                'Marker','o','MarkerSize',5,'LineWidth',2);
end

%% GUI functionality

% initialize Recording/Stop button (change: push or spacebar)
gui.button = uicontrol('style','pushbutton',...
                       'string', 'Record',... % initial button label
                       'units', 'normalized',...
                       'position', [0.3 0 0.3 0.05],...
                       'callback', @switchRec); % calls function in case of button press 

% initialize folder button (see states; change: push or right arrow)
gui.statebutton = uicontrol('style','pushbutton',...
                            'string', 'B1',... % initial button label
                            'units', 'normalized',...
                            'position', [0.95 0.00 0.05 0.05],...
                            'callback', @switchState); % calls function in case of button press                     
                        
% enable to close script via closing figure
set(gcf,'CloseRequestFcn',{@stopScript})

%% final preparation of kinect

% video object from Depth camera  
srcDepth = getselectedsource(vid(2));  

% display text in command window if FrameRate of Kinect drops to 15 fps
if srcDepth.FrameRate == 15
    disp(['Camera FrameRate set to ' num2str(srcDepth.FrameRate) ...
          ' frames. Are there any opportunities to get better lighting?'])
end

% configure camera settings     
set(srcDepth, 'TrackingMode', 'Skeleton') % track skeleton
set(srcDepth, 'BodyPosture', 'Standing')  % participants are standing
% set(srcDepth, 'DepthMode', 'Near')  

% set elevation angle
set(get(vid(1),'Source'),'CameraElevationAngle', elevationAngle)   
set(get(vid(2),'Source'),'CameraElevationAngle', elevationAngle)

% configure video object properties
triggerconfig(vid,'manual'); % data logging as soon as trigger() issued
vid.FramesPerTrigger = 1; % number of frames to acquire per trigger
vid.TriggerRepeat = Frames; % number of additional times to execute trigger
start(vid); % initiates data acquisition

% internal variables and counter
tic
N1 = 0; % set Frame Counter                          

%% data logging

% exit data logging loop if any of the comparisons is true
while ~any([N1 >= Frames,toc > RecordingTime, timesofrec == -1])
   toc1 = toc;
   N1 = N1 + 1; % Frame Counter
   
   % trigger acquisition for all kinect objects.
   trigger(vid) 
   % get the acquired color & depth data + metadata from Kinect
   [imgColor1, ~ , ~ ] = getdata(vid(1)); % from RGB camera 
   [imgDepth1, ~ , metaData_Depth1] = getdata(vid(2)); % from Depth camera
   
   % start realtime preview
   if (N1 == 1), run_preview; end
   
   if flag.Record
       
      % create folder for corresponding number of recording 
      if exist(strcat('Data/',studyFolder,'/',subjectFolder,'/',...
                      gui.states{gui.cnt},...
                      '/Recording_',num2str(timesofrec)),'dir') == 0
         createDir(studyFolder,subjectFolder,strcat(gui.states{gui.cnt},...
                   '/Recording_',num2str(timesofrec)));
      end 
       
      % initialize video file & configure properties
      if (flag.Video && vidopen == 0)
         path = fullfile('Data',studyFolder,subjectFolder,gui.states{gui.cnt});
         VideoFilename = fullfile(path,sprintf('%s_%s.%s','Recording',...
                                  num2str(timesofrec),'mp4'));
         vidObj = VideoWriter(VideoFilename,'MPEG-4'); % creates video file
         vidObj.Quality = 100;
         vidObj.FrameRate = 30;
         open(vidObj)
         vidopen = 1;           
      end
      
      % remove "SegmentationData"-field 
      metaData_Depth1 = rmfield(metaData_Depth1,'SegmentationData'); 
      
      % save current FrameRate of RGB & depth camera in metaData 
      srcC = getselectedsource(vid(1));
      srcD = getselectedsource(vid(2));
      metaData_Depth1.FrameRate = [srcC.FrameRate srcD.FrameRate];
      
      % save data (3 objects)
      matfile = fullfile(RecordPath,sprintf('FRM%07d_%s.mat',N1,...
                         datestr(metaData_Depth1.AbsTime,'HHMMSS')));   
      save(matfile,'imgColor1','imgDepth1','metaData_Depth1','-v6');
        
      % write data from array to video file
      if (flag.Video && vidopen)
         writeVideo(vidObj, imgColor1);
      end
   end
  
   % Statistics / Timer / Counterstop
   if flag.Preview
      set(hFig,...
          'Name',sprintf('TimePerFrame %.4f sec. | (Frames:%05d) | TotalTime is %.2f sec.\n',...
          toc-toc1, N1, toc))
   else
      fprintf('TimePerFrame %.4f sec. | (Frames:%05d) | TotalTime is %.2f sec.\n',...
          toc-toc1,N1,toc)
   end
   
end

%% wrap up

% Stop Kinects
stop(vid);

% Stop Video writer
if (flag.Video && exist('vidObj', 'var')) 
   close(vidObj);
end

delete(gcf);