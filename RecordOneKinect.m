 %function [dummy] = fun_kinects2_fast(SubjectName, RecordName)

%% Parameters 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% V1.0

% set parameters for recording
SubjectName = 'elevation'; 
%SubjectName = input('Enter Name of Subject\n', 's'); 

addpath('./sub/recording') 

Frames        = Inf  ; % set max. number of Frames ("Inf" for infinite)
RecordingTime = Inf  ; % set max. recording time (in secs, "Inf" for infinite)
Source        = 'Kinect'; % 'Kinect' - gets data from Kinect Hardware
elevationAngle = 0;    % set elevation angle for both cameras
                            
global flag;
flag.Record      = 0   ; % 1 = starts continuous recording
flag.Preview     = 1   ; % realtime preview
flag.Video       = 1   ; % MP4-Video recording

global vidopen;          
vidopen = 0;             % 0 = video file to be initialized

global RecordPath;       % Path to current Recording-Folder
global timesofrec;       % Counter for times of recording
timesofrec = 1;   

global button;           % Recording/Stop Button
global statebutton;      % Folder Button (Baseline/Test)
global cnt               % Counter for states of statebutton
cnt = 1;
global states;           % string for statebutton

% vector of foldernames (below subject folder level)
% push Button in right corner of GUI in order to select next folder name
states = [cellstr('Baseline 1'); cellstr('Baseline 2');...
          cellstr('Baseline 3');cellstr('Baseline 4');...
          cellstr('Baseline 5');cellstr('Baseline 6');...
          cellstr('Baseline 7');cellstr('Baseline 8');...
          cellstr('Test 1'); cellstr('Test 2')];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% recording 

% Reset kinect objects in memory
imaqreset

% Initialize Kinect Objects
clear vid;

% Initialize Kinect Hardware
vid(1) = videoinput('kinect', 1); % RGB camera 1
vid(2) = videoinput('kinect', 2); % Depth camera 1 

% create folder for Data
if ~(exist('Data', 'dir'))
   mkdir('Data')
end

% prepare folder names
TimeStamp = datestr(now,30);
subjectFolder = sprintf('%s_%s',TimeStamp,SubjectName);

%% initialize Realtime Preview

if flag.Preview
   % create a figure
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % 'zbuffer' used to be renderer option of choice! 
   % since it has been removed, change to opengl
%    hFig = figure('Renderer','zbuffer','Colormap',jet(3000),...
%                  'KeyPressFcn',@keyPress);
   hFig = figure('Renderer','opengl','Colormap',jet(3000),...
                 'KeyPressFcn',@keyPress);
            
   % initialize subplots
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

% initialize record button
button = uicontrol('style','pushbutton',...
                    'string', 'Record',...
                    'units', 'normalized',...
                    'position', [0.3 0 0.3 0.05],...
                    'callback', @switchRec); 

% initialize Folder Button
statebutton = uicontrol('style','pushbutton',...
                        'string', 'B1',...
                        'units', 'normalized',...
                        'position', [0.95 0.00 0.05 0.05],...
                        'callback', @switchState);
                 
% enable to close script via closing figure
set(gcf,'CloseRequestFcn',{@stopScript})

%% final preparation of kinect

% video object from Depth camera  
srcDepth = getselectedsource(vid(2));  

% configure camera settings     
set(srcDepth, 'TrackingMode', 'Skeleton') % track skeleton
set(srcDepth, 'BodyPosture', 'Standing')  % participants are standing
% set(srcDepth, 'DepthMode', 'Near')  

% set elevation angle
% set(get(vid(1),'Source'),'CameraElevationAngle', elevationAngle)   
% set(get(vid(2),'Source'),'CameraElevationAngle', elevationAngle)

% configure video object properties
triggerconfig(vid,'manual'); % data logging as soon as trigger() issued
vid.FramesPerTrigger = 1; % number of frames to acquire per trigger
vid.TriggerRepeat = Frames; % number of additional times to execute trigger
start(vid); % initiates data acquisition

% Initialize some internal variables and counter
tic
N1 = 0; % set Frame Counter                          

%% data logging

% exit data logging loop if any of the comparisons is true
while ~any([N1 >= Frames,toc > RecordingTime, timesofrec == -1])
   toc1 = toc;
   % Frame Counter
   N1 = N1 + 1;
   
   % trigger acquisition for all kinect objects.
   trigger(vid) 
   % get the acquired color & depth data + metadata from Kinect
   [imgColor1, ~ , ~ ] = getdata(vid(1)); % from RGB camera 
   [imgDepth1, ~ , metaData_Depth1] = getdata(vid(2)); % from Depth camera
   
   % start realtime preview
   if (N1 == 1), run_preview; end
   
   if flag.Record
       
      % create folder for corresponding number of recording 
      if exist(strcat('Data/',subjectFolder,'/',states{cnt},...
               '/Recording_',num2str(timesofrec)),'dir') == 0
         createDir(subjectFolder,strcat(states{cnt},'/Recording_',...
                   num2str(timesofrec)));
      end 
       
      % initialize video file & configure properties
      if (flag.Video && vidopen == 0)
         path = fullfile('Data',subjectFolder,states{cnt});
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
      
      % save data
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
%dummy;

% figure ; surf(double(imgDepth),imgColor,'EdgeColor','none','FaceColor','texturemap')
