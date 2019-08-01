% switchState - changes label of statebutton 
%               & resets times of recording to 1.

function switchState(object_handle, event)
    global timesofrec;
    global gui
    
    if gui.cnt < length(gui.states)
        timesofrec = 1; % sets counter for recordings back to 1 
        gui.cnt = gui.cnt + 1;
        
        % changes label of statebutton (e.g. B1, B2, ... T1, T2)
        set(gui.statebutton,'string',...
           [gui.states{gui.cnt}(1),gui.states{gui.cnt}(end)]);
    end
    
end