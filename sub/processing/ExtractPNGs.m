% ExtractPNGs - Save colorframes or depthframes with or without skeletons.
% 
% Usage:
%    >> ExtractPNGs(recPath, f, '01', 'Depth')
%           % folder of depthframes (.png) without skeleton
%    >> ExtractPNGs(recPath, f, '11', 'Color')
%           % folders of colorframes (.png) with and without skeleton
% 
% Inputs:
%   recPath     - path to current recording folder  
%   f           - name of .mat frame file
%   gui         - char vector of length 2; '0' | '1' = chosen option;
%                 1st index: image with skeleton; 
%                 2nd index: image without skeleton
%   type        - char vector 'Color' | 'Depth'; type of frame                         
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
    
function ExtractPNGs(recPath, f, gui, type)
    % Check for user selection in GUI 
    if ~isequal(gui,'00') 
        
        % load data (hidden inside function)
        load(fullfile(recPath,f));  
        
        % check if color/depth data still available in file
        if (exist(['img' type '1'],'var') && exist('metaData_Depth1','var'))
            
            colors = ['b','g','r','y','m','c','k']; % distinguish skeletons
            fName = f(1:end-4); % file name without '.mat'
        
            % create a figure without displaying it
            % since 'zbuffer' has been removed, use 'opengl' instead
            % 'opengl' uses GPU & leads to warnings in case of parallel computing 
            hFig = figure('Renderer','painters','Colormap',jet(3000),...
                          'visible','off'); 

            % initialize plot
            hAxes = subplot(1,1,1,'Parent',hFig,'box','on',...
                            'XLim',[0.5 640.5],'Ylim',[0.5 480.5],...
                            'nextplot','add','YDir','Reverse','fontsize',7);
        
            hColor1 = image(NaN,'Parent',hAxes); 
            hColor_Skelet_2D(1,:) = line(nan(2,6),nan(2,6),'Parent',hAxes,...
                                    'Marker','o','MarkerSize',5,'LineWidth',2);
        
            % add color or depth data to image object
            set(hColor1,'cdata',eval(['img' type '1']));
        
            % save pics without skeleton
            if (gui(2) == '1') 
                % creates folder (e.g. Recording1_Color_pics) 
                if(~exist(strcat(recPath,'_',type,'_pics/'),'dir')) 
                    mkdir(strcat(recPath,'_',type,'_pics/')); 
                end % folder for png-files available 
            
                saveas(gcf, strcat(recPath,'_',type,'_pics/', fName, '.png')); 
            end % Color-/Depthframe without skeleton saved to png-file
        
            % save pics with skeleton
            if (gui(1) == '1') 
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
                    saveas(gcf,strcat(recPath,'_',type,'_skelPics/',...
                                      fName,'.png'));
                end % Color-/Depthframe with skeleton saved to png-file
            
            end
            close(gcf); % close current figure handle
        end
    end    
end
