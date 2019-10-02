% ExtractVideo - Turn color frame files into video (.mp4) 
%                & save .mp4-video in BaselineFolder.
% 
% Usage:
%     extractVideo('.\Data\SubjectFolder\BaselineFolder\Recording_1')
% 
% Inputs:
%     recPath  - full path to current recording folder
% 
% Outputs:
%     This function has no output arguments. 

function extractVideo(recPath)
    % prepare video file name 
    rec = evalin('base', 'Recording'); % e.g. Recording_3
    TimeStamp = datestr(now, 30); % char vector; day & time
    
    % create video file name
    VideoFilename = fullfile(recPath, '..', sprintf('%s_%s_%s.%s',...
                    'Recording', num2str(rec(end)), TimeStamp,'mp4'));
    
    % create video file + settings
    vidObj = VideoWriter(VideoFilename,'MPEG-4'); 
    vidObj.Quality = 100;
    vidObj.FrameRate = 30;
    open(vidObj)
    
    Files  = dir(fullfile(recPath,'FRM*.mat')); % frame files
    nFrames = numel(Files); 
    
    for iFrame = 1:nFrames
        f = Files(iFrame).name; 
        load(fullfile(recPath,f)); 
        
        % write data from array to video file
        writeVideo(vidObj, imgColor1);
    end
    
    close(vidObj)
end
