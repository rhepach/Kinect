% switchState - changes statebutton + resets times of recording to 1.

function switchState(object_handle, event)
    global timesofrec;
    global states;
    global statebutton;
    global cnt;
    
    if cnt < length(states)
        timesofrec = 1; % sets Counter for Recordings back to one 
        cnt = cnt + 1;
        % changes string on statebutton (e.g. B1, B2, ... T1, T2)
        set(statebutton,'string',[states{cnt}(1),states{cnt}(end)]);
    end
    
end