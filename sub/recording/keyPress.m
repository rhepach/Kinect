% keyPress - calls corresponding function in case of keybord input.
% 
% Inputs:
%   e      - struct with field "Key" (= name of key in lower case)

function keyPress(src, e)
    
    switch e.Key
        case 'space' 
            switchRec(); % changes button (recording state) 
        case 'rightarrow'
            switchState(); % changes statebutton
    end
   
end


