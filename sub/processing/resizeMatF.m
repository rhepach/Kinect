% resizeMatF - Save resized &/| greyscaled colorframes to .mat file.
%              (e.g. Recording_3_greyhalf.mat)
%              FrameArray: each row is a frame; each column a variable
% 
% Usage:
%    >> resizeMatF('01') % halfsized imagedata
%    >> resizeMatF('10') % grayscaled imagedata 
%    >> resizeMatF('11') % halfsized & grayscaled imagedata
% 
% Inputs:
%     xx       - char vector; '01' | '10' | '11'
% 
% Outputs:
%     This function has no output arguments.

function resizeMatF(xx)
    % Check for user selection in toggle boxes.
    if ~isequal(xx,'00')
        % setup for access to frame data
        recPath = evalin('base','recPath'); % path to recording folder  
        
        % list all frame files in current recording folder
        Files = dir(fullfile(recPath,'FRM*.mat')); 
        nFrames = numel(Files);  
        
        frameArray = cell(nFrames, 4); 
        opt = ''; % get value according to case; will be used for file name 
        
        % processing for each frame file (.mat)
        for iFrame = 1:nFrames 
            % get data 
            f = Files(iFrame).name;
            load(fullfile(recPath,f)); 
            
            fName = f(1:end-4); % file name without '.mat'
            frameArray{iFrame,1} = fName; % each row contains one frame
            
            varNames = who('-file',fullfile(recPath,fName)); 
            % search for color data in all variables of .mat-file 
            for j = 1:length(varNames)
                if contains(varNames{j}, 'imgColor') 
                    colData = eval(varNames{j});  
                    
                    % convert color data depending on selection in GUI 
                    % first column in frameArray = frame name -> j+1
                    switch xx
                        case '11' % greyscale & resize color data
                            greyData = rgb2gray(colData);
                            frameArray{iFrame,j+1} = imresize(greyData,0.5);
                            opt = 'greyhalf'; 
                        case '10' % greyscale color data
                            frameArray{iFrame,j+1} = rgb2gray(colData);
                            opt = 'grey';
                        case '01' % halfsize color data 
                            frameArray{iFrame,j+1} = imresize(colData,0.5);
                            opt = 'half';
                    end 
                
                % copy original variable if no match with pattern 'imgColor'
                else 
                    frameArray{iFrame,j+1} = eval(varNames{j}); 
                end 
            end 
        end % processing finished for every frame file in recording folder 
        
        % write converted data to .mat-file (e.g. Recording_1_grey.mat)
        matfile = fullfile(strcat(recPath,'_',opt)); 
        save(matfile,'frameArray','-v7.3'); 
    end
end