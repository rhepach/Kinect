% switchRec - changes recording state according to current state.

function switchRec(object_handle, event)   
    global flag; 
    global timesofrec;
    global button;
    global vidopen;
    % global tmr;
    
    if flag.Record == 0 % in case of no recording in progress
        flag.Record = 1; % starts recording
        flag.Preview = 0; % Preview already initialized 
        %start(tmr)
        %vidopen = 1;
        set(button,'string','Stop'); % change string on Recording-Button
        
    elseif flag.Record == 1 % in case of recording in progress
        flag.Record = 0; % stops recording
        flag.Preview = 1; % preview preparation for next recording
        %stop(tmr)
        set(button,'string','Record'); % change string on Recording-Button
        timesofrec = timesofrec + 1;
        vidopen = 0;
    end 
    
end



