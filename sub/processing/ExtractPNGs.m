% ExtractPNGs - Save colorframes or depthframes with or without skeletons.
% 
% Usage:
%    >> ExtractPNGs(metaData_Depth1, imgDepth1, k, 0, 1, 'Depth')
%           % folder of depthframes (.png) without skeleton
%    >> ExtractPNGs(metaData_Depth1, imgColor1, k, 1, 1, 'Color')
%           % folders of colorframes (.png) with and without skeleton
% 
% Inputs:
%     metaData_Depth1   - meta data from frame files (.mat)
%     imgData           - color or depth data from frame files (.mat)
%     k                 - double 1 | 2; indicates Kinect
%     x                 - char vector '0' | '1'; 1 = frames with skeleton
%     y                 - char vector '0' | '1'; 1 = frames 
%     type              - char vector 'Color' | 'Depth'; type of frame 
% 
% Outputs:
%     This function has no output arguments.  
% 
% Mapping of World coordinates 
%     HipCenter = 1;
%     Spine = 2;
%     ShoulderCenter = 3;
%     Head = 4;
%     ShoulderLeft = 5;
%     ElbowLeft = 6;
%     WristLeft = 7;
%     HandLeft = 8;
%     ShoulderRight = 9;
%     ElbowRight = 10;
%     WristRight = 11;
%     HandRight = 12;
%     HipLeft = 13;
%     KneeLeft = 14;
%     AnkleLeft = 15;
%     FootLeft = 16; 
%     HipRight = 17;
%     KneeRight = 18;
%     AnkleRight = 19;
%     FootRight = 20;
    
function ExtractPNGs(metaData_Depth1, imgData, k, x, y, type)
    % Check for user selection in GUI 
    if ~isequal([x,y],'00') 
        recPath = evalin('base','recPath');   
        colors = ['b','g','r','y','m','c','k'];
        frameNo = num2str(metaData_Depth1.FrameNumber);
        
        % create a figure without displaying it
        % since 'zbuffer' has been removed, use 'opengl' instead
        hFig = figure('Renderer','opengl','Colormap',jet(3000),...
                      'visible','off'); 

        % initialize plot
        hAxes = subplot(1,1,1,'Parent',hFig,'box','on',...
                        'XLim',[0.5 640.5],'Ylim',[0.5 480.5],...
                        'nextplot','add','YDir','Reverse','fontsize',7);
        
        hColor1 = image(NaN,'Parent',hAxes); 
        hColor_Skelet_2D(1,:) = line(nan(2,6),nan(2,6),'Parent',hAxes,...
                                'Marker','o','MarkerSize',5,'LineWidth',2);
        
        % add color or depth data to image object
        set(hColor1,'cdata',imgData) 
        
        % save pics without skeleton
        if (y == '1') 
            % creates folder (e.g. Recording1_Color_pics) 
            if(~exist(strcat(recPath,'_',type,'_pics/'),'dir')) 
                mkdir(strcat(recPath,'_',type,'_pics/')); 
            end % folder for png-files available 
            
            saveas(gcf, strcat(recPath,'_',type,'_pics/','FRM',frameNo,...
                                '_', num2str(k),'.png')); 
        end % Color-/Depthframe without skeleton saved to png-file
        
        % save pics with skeleton
        if (x == '1') 
            cnt = 0; % counter for non-empty matrices in JointImageIndices
            
            for n = 1:6 % all possible slots for tracked skeletons 
                if metaData_Depth1.IsSkeletonTracked(n) 
                    jointIndices = metaData_Depth1.JointImageIndices(:,:,n); 
                    % size(metaData_Depth1.JointImageIndices) = [20 2 6]
                    if ~isequal(jointIndices, zeros(20,2))
                        cnt = cnt + 1;
                    end
                    
                    % prepare data vectors to plot the skeletal data
                    points = [jointIndices; nan(1,2,size(jointIndices,3))];
                    xdata = points([1 2 3 4 end ... % body longitudinal axis
                                    3 5 6 7 8 end ... % left arm
                                    3 9 10 11 12 end ... % right arm
                                    1 13 14 15 16 end ... % left leg
                                    1 17 18 19 20 end],1); % right leg
                    ydata = points([1 2 3 4 end ... 
                                    3 5 6 7 8 end ... 
                                    3 9 10 11 12 end ... 
                                    1 13 14 15 16 end ... 
                                    1 17 18 19 20 end],2); 
                                
                    % add skeletal data to plot
                    set(hColor_Skelet_2D(1,n),...
                        'xdata',xdata,'ydata',ydata,'Color',colors(n),...
                        'Marker','o','MarkerSize',5,'LineWidth',2);
                end
            end
            
            % creates folder (e.g. Recording1_Color_skelPics) 
            if(~exist(strcat(recPath,'_',type,'_skelPics/'),'dir'))
                mkdir(strcat(recPath,'_',type,'_skelPics/'));
            end % folder for skelPics (png) available 
            
            if (cnt > 0) % any non-empty matrices in Joint Images
                saveas(gcf,strcat(recPath,'_',type,'_skelPics/','FRM',...
                                  frameNo,'_',num2str(k),'.png'));
            end % Color-/Depthframe with skeleton saved to png-file
            
        end
        close(gcf); % close current figure handle
    end
    
end
