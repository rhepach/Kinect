% keyPress - calls corresponding function in case of keybord input.
% 
% Inputs:
%   e      - struct with field "Key" (= name of key in lower case)

function keyPress(src, e)
    global button;
    
    switch e.Key
        case 'space' 
            switchRec(button, []); % changes recording state 
        case 'rightarrow'
            switchState(button, []); % changes statebutton
    end
   
end


