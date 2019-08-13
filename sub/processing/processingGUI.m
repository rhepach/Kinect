function varargout = processingGUI(varargin)
% PROCESSINGGUI MATLAB code for processingGUI.fig
%      PROCESSINGGUI, by itself, creates a new PROCESSINGGUI or raises the existing
%      singleton*.
%
%      H = PROCESSINGGUI returns the handle to a new PROCESSINGGUI or the handle to
%      the existing singleton*.
%
%      PROCESSINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROCESSINGGUI.M with the given input arguments.
%
%      PROCESSINGGUI('Property','Value',...) creates a new PROCESSINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before processingGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to processingGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help processingGUI

% Last Modified by GUIDE v2.5 13-Aug-2019 16:56:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @processingGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @processingGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before processingGUI is made visible.
function processingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to processingGUI (see VARARGIN)

set(gcf,'CloseRequestFcn',@CloseFcn)

% Choose default command line output for processingGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% setup variables for listbox
wdFile = evalin('base', 'wdFile');
source = evalin('base','source');

initial_dir = fullfile(wdFile, source);
if exist(initial_dir,'dir') == 0
   errordlg('Input argument must be a valid directory','Input Argument Error!')
   return
end

% Populate the listbox
load_listbox(initial_dir,handles)

% UIWAIT makes processingGUI wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = processingGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.out;
delete(hObject);



% --- Executes on button press in pushbutton1. (= ok button)
% get values from each toggle box & concatenate them into string
function pushbutton1_Callback(hObject, eventdata, handles)
    guidata(hObject, handles);
    grey = get(handles.grey,'Value');
    half = get(handles.half,'Value');
    skelPics = get(handles.pics,'Value');
    pics = get(handles.colorPics,'Value');
    skelDepth = get(handles.skelDepth,'Value');
    depth = get(handles.depth,'Value');
    skel = get(handles.skel,'Value');
    del = get(handles.checkbox6, 'Value');
    video = get(handles.extractVideo, 'Value');
    sep = get(handles.sepData, 'Value');
    out = strcat(num2str(grey), num2str(half), num2str(skelPics), ...
                num2str(pics),num2str(skelDepth),num2str(depth), ...
                num2str(skel), num2str(video), num2str(del), num2str(sep));
    handles.out = out;
    guidata(hObject, handles);
    close(handles.figure1);


function CloseFcn(hObject, eventdata, handles)

    
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, call UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on button press in grey. (greyscaled image frames)
function grey_Callback(hObject, eventdata, handles)
% hObject    handle to grey (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of grey


% --- Executes on button press in half. (half sized image frames)
function half_Callback(hObject, eventdata, handles)
% hObject    handle to half (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of half


% --- Executes on button press in colorPics. (Colorframes with Skeletons)
function pics_Callback(hObject, eventdata, handles)
% hObject    handle to colorPics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of colorPics


% --- Executes on button press in skel. (extract & save skeleton data)
function skel_Callback(hObject, eventdata, handles)
% hObject    handle to skel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of skel


% --- Executes on button press in checkbox6. (delete)
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in skelDepth. (Depthframes with Skeleton)
function skelDepth_Callback(hObject, eventdata, handles)
% hObject    handle to skelDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of skelDepth


% --- Executes on button press in depth. (Depthframes)
function depth_Callback(hObject, eventdata, handles)
% hObject    handle to depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of depth


% --- Executes on button press in colorPics. (Colorframes)
function colorPics_Callback(hObject, eventdata, handles)
% hObject    handle to colorPics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of colorPics


% --- Executes on selection change in listbox2. (folder content)
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2

get(handles.figure1,'SelectionType');
if strcmp(get(handles.figure1,'SelectionType'),'open')
    selectionIx = get(handles.listbox2,'Value');
    fileList = get(handles.listbox2,'String');
    fileName = fileList{selectionIx};
    if  handles.is_dir(handles.sorted_index(selectionIx))
        cd(fileName)
        load_listbox(pwd, handles)
    end
end

% ------------------------------------------------------------
% Read the current directory and sort the names
% ------------------------------------------------------------
function load_listbox(dir_path,handles)
cd (dir_path)
dir_struct = dir(dir_path);
[sorted_names,sorted_index] = sortrows({dir_struct.name}');
handles.file_names = sorted_names;
handles.is_dir = [dir_struct.isdir];
handles.sorted_index = sorted_index;
guidata(handles.figure1,handles)
set(handles.listbox2,'String',handles.file_names,...
	'Value',1)
%set(handles.text1,'String',pwd)


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in extractVideo.
function extractVideo_Callback(hObject, eventdata, handles)
% hObject    handle to extractVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of extractVideo


% --- Executes on button press in sepData.
function sepData_Callback(hObject, eventdata, handles)
% hObject    handle to sepData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sepData
