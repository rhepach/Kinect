% switchRec - changes recording state, 
%                     flags (preview & vidopen) &
%                     button label depending on current state.

function switchRec(object_handle, event)   
    global flag; 
    global timesofrec;
    global gui;
    global vidopen;
    
    % in case of no recording in progress
    if flag.Record == 0 
        flag.Record = 1; % starts recording
        flag.Preview = 0; % preview already initialized 
        
        set(gui.button,'string','Stop'); % change label of button 
    
    % in case of recording in progress
    elseif flag.Record == 1 
        flag.Record = 0; % stops recording
        flag.Preview = 1; % preview preparation for next recording
        vidopen = 0; % to initialize new video for next recording
        
        set(gui.button,'string','Record'); % change label of button 
        timesofrec = timesofrec + 1; % counter for number of recordings

    end 
    
end



