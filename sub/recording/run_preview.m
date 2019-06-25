% run_preview - Initiates & starts timer object.
% 
% nested function:
% preview     - feed initialized realtime preview with Kinect data 
%

function run_preview

    % initialize timer object;
    % calls preview function with 0.2 seconds delay between executions
    t = timer('TimerFcn',@preview,...
              'Period', 0.2,'executionmode','fixedSpacing');
    
    % start timer object
    start(t)
    
    function preview(g1,g2)
        fig = evalin('base','hFig');
        if (~ishandle(fig))
            stop(t)
            return
        end
        
        colors = ['b','g','r','y','m','c','k'];
        
        % get initialized image objects from MATLAB base workspace
        hColor(1) = evalin('base','hColor(1)');
        hDepth(1) = evalin('base','hDepth(1)');
        
        % get affiliated Kinect data for color & depth frame 
        imgColor1 = evalin('base','imgColor1');
        imgDepth1 = evalin('base','imgDepth1');
       
        % get initialized line objects
        hColor_Skelet_2D = evalin('base','hColor_Skelet_2D'); 
        hDepth_Skelet_2D = evalin('base','hDepth_Skelet_2D'); 
        % hSkelet_3D = evalin('base','hSkelet_3D'); 
        
        % get affiliated Kinect data for skeletal plots
        metaData_Depth1 = evalin('base','metaData_Depth1');
        
        % fill object with color & depth data respectively
        set(hColor(1),'cdata',imgColor1)
        set(hDepth(1),'cdata',imgDepth1) 
        
        for N = 1:6
            if metaData_Depth1.IsSkeletonTracked(N) 
                
                % get skeletal Image 2D data
                jointIndices = metaData_Depth1.JointImageIndices(:,:,N); 
                
                % prepare data vectors to plot the skeletal data
                points = [jointIndices;nan(1,2,size(jointIndices,3))];
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
                            
                % pass skeletal data on to color line object
                set(hColor_Skelet_2D(1,N),'xdata',xdata,'ydata',ydata,...
                    'Color',colors(N))

                % get skeletal Depth 2D data
                jointIndices = metaData_Depth1.JointDepthIndices(:,:,N);
                
                % prepare data vectors to plot the skeletal data
                points = [jointIndices;nan(1,2,size(jointIndices,3))];
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
                            
                % pass skeletal data on to depth line object 
                set(hDepth_Skelet_2D(1,N),'xdata',xdata,'ydata',ydata,...
                    'Color',colors(N))
            else
                % no data (NaN) for skeletal plots if nothing was tracked
                set(hColor_Skelet_2D(1,N),'xdata',NaN,'ydata',NaN)
                set(hDepth_Skelet_2D(1,N),'xdata',NaN,'ydata',NaN)
            end
        end
        
        %{
        % Plot 3D Skeletal_Data
        for N = 1:6
            if metaData_Depth1.IsSkeletonTracked(N) %K1

                points = metaData_Depth1.JointWorldCoordinates(:,:,N); 
                
                % prepare data vectors to plot the skeletal data
                points = [points; nan(1,3,size(points,3))];
                %{
                if points(1,1)~=0
                    disp(points(1,:))
                end
                %}
                xdata = points([1 2 3 4 end... % body longitudinal axis
                                3 5 6 7 8 end ... % left arm
                                3 9 10 11 12 end ... % right arm
                                1 13 14 15 16 end ... % left leg
                                1 17 18 19 20 end],1); % right leg
                ydata = points([1 2 3 4 end...
                                3 5 6 7 8 end 3 9 10 11 12 end...
                                1 13 14 15 16 end 1 17 18 19 20 end],2);
                zdata = points([1 2 3 4 end...
                                3 5 6 7 8 end 3 9 10 11 12 end...
                                1 13 14 15 16 end 1 17 18 19 20 end],3);
                
                % pass skeletal data on to 3-D line object
                set(hSkelet_3D(1,N),'xdata',xdata,'ydata',ydata,...
                                    'zdata',zdata,'Color',colors(N))
            else
                % no data (NaN) for skeletal plots if nothing was tracked
                set(hSkelet_3D(1,N),'xdata',NaN,'ydata',NaN,'zdata',NaN)
            end
            
        end
        %}
        
       % set(hFig,'Name',sprintf('TimePerFrame %.4f sec. | (Frames:%05d) | TotalTime is %.2f sec.\n',toc-toc1,N1,toc))
    end

end