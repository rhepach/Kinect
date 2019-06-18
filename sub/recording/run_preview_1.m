function run_preview
    fig = evalin('base','hFig');
    t = timer('TimerFcn',@preview,...
              'Period', 0.2,'executionmode','fixedSpacing');
    start(t)
    
    function preview(g1,g2)
        fig = evalin('base','hFig');
        if (~ishandle(fig))
            stop(t)
            return
        end
        
        % get objects from MATLAB base workspace
        hColor(1) = evalin('base','hColor(1)');
        hDepth(1) = evalin('base','hDepth(1)');
        imgColor1 = evalin('base','imgColor1');
        imgDepth1 = evalin('base','imgDepth1');
       
        metaData_Depth1 = evalin('base','metaData_Depth1');
        
        hColor_Skelet_2D = evalin('base','hColor_Skelet_2D'); 
        hDepth_Skelet_2D = evalin('base','hDepth_Skelet_2D'); 
        % hSkelet_3D = evalin('base','hSkelet_3D'); 
        
        %set(hColor(1),'cdata',imresize(imgColor1,0.5))%(1:480,1:640,1:3))
        set(hColor(1),'cdata',imgColor1)
        set(hDepth(1),'cdata',imgDepth1) % (1:480,1:640)) %K1
        
        %metaData_Depth1 = metaData_Depth1(1,:);
        colors = ['b','g','r','y','m','c','k'];
        
        for N = 1:6
            if metaData_Depth1.IsSkeletonTracked(N) %K1
            %if metaData_Depth1.IsBodyTracked(N)     %K2
                
                % get skeletal Image 2D data
                jointIndices = metaData_Depth1.JointImageIndices(:,:,N); %K1
                % jointIndices = metaData_Depth1.ColorJointIndices(:,:,N); %K2
                
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
                set(hColor_Skelet_2D(1,N),'xdata',xdata,'ydata',ydata,...
                    'Color',colors(N))

                % get skeletal Depth 2D data
                jointIndices = metaData_Depth1.JointDepthIndices(:,:,N);%K1
                %jointIndices = metaData_Depth1.DepthJointIndices(:,:,N); %K2
                
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
                set(hDepth_Skelet_2D(1,N),'xdata',xdata,'ydata',ydata,...
                    'Color',colors(N))
            else
                % remove skeletal plots if nothing was tracked
                set(hColor_Skelet_2D(1,N),'xdata',NaN,'ydata',NaN)
                set(hDepth_Skelet_2D(1,N),'xdata',NaN,'ydata',NaN)
            end
        end
        %imshow(hColor_Skelet_2D);
        
        %{
        % Plot 3D Skeletal_Data
        for N = 1:6
            if metaData_Depth1.IsSkeletonTracked(N) %K1
            %if metaData_Depth1.IsBodyTracked(N) %K2
                points = metaData_Depth1.JointWorldCoordinates(:,:,N); %K1
                %points = metaData_Depth1.JointPositions(:,:,N); %K2
                
                % prepare data vectors to plot the skeletal data
                points = [points; nan(1,3,size(points,3))];
                %{
                if points(1,1)~=0
                    disp(points(1,:))
                end
                %}
                xdata = points([1 2 3 4 end...
                                3 5 6 7 8 end 3 9 10 11 12 end ...
                                1 13 14 15 16 end 1 17 18 19 20 end],1);
                ydata = points([1 2 3 4 end...
                                3 5 6 7 8 end 3 9 10 11 12 end...
                                1 13 14 15 16 end 1 17 18 19 20 end],2);
                zdata = points([1 2 3 4 end...
                                3 5 6 7 8 end 3 9 10 11 12 end...
                                1 13 14 15 16 end 1 17 18 19 20 end],3);
                set(hSkelet_3D(1,N),'xdata',xdata,'ydata',zdata,'zdata',...
                                    ydata,'Color',colors(N))
            else
                set(hSkelet_3D(1,N),'xdata',NaN,'ydata',NaN,'zdata',NaN)
            end
            
        end
        %}
        
       % set(hFig,'Name',sprintf('TimePerFrame %.4f sec. | (Frames:%05d) | TotalTime is %.2f sec.\n',toc-toc1,N1,toc))
    end

end