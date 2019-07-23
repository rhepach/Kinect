% switchRec - changes recording state depending on current state.

function switchRec(object_handle, event)   
    global flag; 
    global timesofrec;
    global button;
    global vidopen;
    
    % in case of no recording in progress
    if flag.Record == 0 
        flag.Record = 1; % starts recording
        flag.Preview = 0; % Preview already initialized 
        set(button,'string','Stop'); % change string on Recording-Button
    
    % in case of recording in progress
    elseif flag.Record == 1 
        flag.Record = 0; % stops recording
        flag.Preview = 1; % preview preparation for next recording
        set(button,'string','Record'); % change string on Recording-Button
        timesofrec = timesofrec + 1;
        vidopen = 0;
    end 
    
end



