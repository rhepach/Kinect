% stopScript - stops script if figure was closed.

function stopScript(object_handle, event)
    global timesofrec;
    timesofrec = -1; % exit while-loop that triggers data logging 
end