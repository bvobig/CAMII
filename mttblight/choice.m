function varargout = choice(varargin)
% CHOICE M-file for choice.fig
%      CHOICE by itself, creates a new CHOICE or raises the
%      existing singleton*.
%
%      H = CHOICE returns the handle to a new CHOICE or the handle to
%      the existing singleton*.
%
%      CHOICE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHOICE.M with the given input arguments.
%
%      CHOICE('Property','Value',...) creates a new CHOICE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before choice_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to choice_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help choice

% Last Modified by GUIDE v2.5 25-Apr-2006 23:07:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @choice_OpeningFcn, ...
                   'gui_OutputFcn',  @choice_OutputFcn, ...
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

% --- Executes just before choice is made visible.
function choice_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to choice (see VARARGIN)

% Choose default command line output for choice
handles.output = 'Yes';

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% UIWAIT makes choice wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = choice_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = resume_choice(handles);
% Update handles structure
guidata(hObject, handles);
% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


function choice = resume_choice(handles)

choice.dens = get(handles.densbox,'Value');
choice.dur = get(handles.durbox,'Value');
choice.meanp = get(handles.meanpbox,'Value');
choice.stdp = get(handles.stdpbox,'Value');
choice.meanv = get(handles.meanvbox,'Value');
choice.ac = get(handles.acbox,'Value');
choice.ton = get(handles.tonbox,'Value');
choice.maj = get(handles.majbox,'Value');
choice.min = get(handles.minbox,'Value');
choice.art = get(handles.artbox,'Value');
choice.dis = get(handles.disbox,'Value');
choice.sync = get(handles.syncbox,'Value');
choice.syntempo = get(handles.syntempobox,'Value');
choice.tempo = get(handles.tempobox,'Value');
choice.col = get(handles.colbox,'Value');
choice.silence = get(handles.silencebox,'Value');
choice.wlen = str2num(get(handles.winedit,'String'));

choice.total = choice.dens+choice.dur+choice.meanp+choice.stdp+choice.meanv+choice.ac+choice.tempo+choice.ton+choice.maj+choice.min+choice.art...
              +choice.dis+choice.sync+choice.syntempo;
choice.totalindiv = choice.dens+choice.dur+choice.meanp+choice.stdp+choice.meanv+choice.ton+choice.maj+choice.min+choice.art...
              +choice.dis+min(choice.ac+choice.tempo,1)+choice.silence;
choice.totalcomm = min(choice.sync+choice.syntempo,1);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = 0;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end 

% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 0;
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.figure1);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    handles.output = resume_choice(handles);
    guidata(hObject, handles);
    uiresume(handles.figure1);
end    

% --- Executes on button press in densbox.
function densbox_Callback(hObject, eventdata, handles)
% hObject    handle to densbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of densbox


% --- Executes on button press in colbox.
function colbox_Callback(hObject, eventdata, handles)
% hObject    handle to colbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of colbox


% --- Executes on button press in durbox.
function durbox_Callback(hObject, eventdata, handles)
% hObject    handle to durbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of durbox


% --- Executes on button press in meanpbox.
function meanpbox_Callback(hObject, eventdata, handles)
% hObject    handle to meanpbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of meanpbox


% --- Executes on button press in stdpbox.
function stdpbox_Callback(hObject, eventdata, handles)
% hObject    handle to stdpbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stdpbox


% --- Executes on button press in acbox.
function acbox_Callback(hObject, eventdata, handles)
% hObject    handle to acbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of acbox


% --- Executes on button press in meanvbox.
function meanvbox_Callback(hObject, eventdata, handles)
% hObject    handle to meanvbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of meanvbox


% --- Executes on button press in disbox.
function disbox_Callback(hObject, eventdata, handles)
% hObject    handle to disbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of disbox


% --- Executes on button press in tonbox.
function tonbox_Callback(hObject, eventdata, handles)
% hObject    handle to tonbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tonbox


% --- Executes on button press in artbox.
function artbox_Callback(hObject, eventdata, handles)
% hObject    handle to artbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of artbox


% --- Executes on button press in majbox.
function majbox_Callback(hObject, eventdata, handles)
% hObject    handle to majbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of majbox


% --- Executes on button press in minbox.
function minbox_Callback(hObject, eventdata, handles)
% hObject    handle to minbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of minbox


% --- Executes on button press in tempobox.
function tempobox_Callback(hObject, eventdata, handles)
% hObject    handle to tempobox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tempobox


% --- Executes on button press in syncbox.
function syncbox_Callback(hObject, eventdata, handles)
% hObject    handle to syncbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of syncbox


% --- Executes on button press in syntempobox.
function syntempobox_Callback(hObject, eventdata, handles)
% hObject    handle to syntempobox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of syntempobox


% --- Executes on button press in silencebox.
function silencebox_Callback(hObject, eventdata, handles)
% hObject    handle to silencebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of silencebox



function winedit_Callback(hObject, eventdata, handles)
% hObject    handle to winedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of winedit as text
%        str2double(get(hObject,'String')) returns contents of winedit as a double


% --- Executes during object creation, after setting all properties.
function winedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to winedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
