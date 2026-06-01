function varargout = analysis(varargin)
% ANALYSIS M-filename for analysis.fig

% Last Modified by GUIDE v2.5 13-Jul-2006 19:28:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @analysis_OutputFcn, ...
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


% --- Executes just before analysis is made visible.
function analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to analysis (see VARARGIN)

% Choose default command line output for analysis
handles.output = hObject;
handles.nmat = 0;
handles.analysis = 0;
handles.oldstat.dens = 0;
handles.oldstat.dur = 0;
handles.oldstat.meanp = 0;
handles.oldstat.stdp = 0;
handles.oldstat.meanv = 0;
handles.oldstat.ac = 0;
handles.oldstat.ton = 0;
handles.oldstat.maj = 0;
handles.oldstat.min = 0;
handles.oldstat.art = 0;
handles.oldstat.tempo = 0;
handles.oldstat.dis = 0;
handles.oldstat.sync = 0;
handles.oldstat.syntempo = 0;
handles.statsize = 0;
handles.denscor = 0;
handles.durcor = 0;
handles.meanpcor = 0;
handles.stdpcor = 0;
handles.meanvcor = 0;
handles.accor = 0;
handles.toncor = 0;
handles.majcor = 0;
handles.mincor = 0;
handles.artcor = 0;
handles.tempocor = 0;
handles.discor = 0;
handles.analysisdisplay = 1;
handles.indivstatdisplay = 0;
handles.therapistdisplay = 0;
handles.statdisplay = 1;
handles.cordisplay = 1;
handles.corcoef = 40.0;
handles.step = 0.05;
handles.file = 'nofile';
handles.tmin = 0.0;
handles.tmax = 1.0;
handles.color = 1;
handles.delta = 0.011;
handles.denschoice = 1;
handles.durchoice = 1;
handles.choice.total = 0;
handles.wlen = 6;
axes(handles.pianoroll1)
hold off
cla
axes(handles.pianoroll2)
hold off
cla
set(handles.pianoroll1,'Visible','off');
set(handles.pianoroll2,'Visible','off');
listaxes=[handles.axe1, handles.axe2, handles.axe3, handles.axe4, handles.axe5, handles.axe6, handles.axe7, handles.axe8, handles.axe9, handles.axe10, handles.axe11 handles.axe12 handles.axe13 handles.axe14];
for i=(1:14)
    set(listaxes(i),'Visible','off');
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in improload.
function load_impro_Callback(hObject, eventdata, handles)
% hObject    handle to improload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile({'*.*','MIDI Files (*.mid)'},'Pick a MIDI file');
handles.file = file;
if not(file==0)
    cd(path)
    handles.nmat=readmidi(file);
    mc=mchannels(handles.nmat);
    handles.nm1=getmidich(handles.nmat,mc(1));
    if length(mc)==1
        disp(['Data found on 1 channel only!']);
        handles.nm2=[];
    else
        handles.nm2=getmidich(handles.nmat,mc(2));
    end
    if length(mc)>2
        disp(['Data found on ' num2str(length(mc)) ' channels!']);
        disp('First 2 channels displayed.');
    end
    display_pianoroll(hObject, handles);
    handles.analysis=0;
    handles.cor=0;
    listaxes=[handles.axe1, handles.axe2, handles.axe3, handles.axe4, handles.axe5, handles.axe6, handles.axe7, handles.axe8, handles.axe9, handles.axe10, handles.axe11 handles.axe12 handles.axe13 handles.axe14];
    for i=(1:14)
        set(listaxes(i),'Visible','off');
    end
    displayfig(handles);
    guidata(hObject, handles);
end


function display_pianoroll(hObject, handles)
set(handles.filename,'String','Displaying...         ');
guidata(hObject, handles);
axes(handles.pianoroll1)
hold off
cla'
set(handles.pianoroll1,'Visible','on');
tlength = max(onset(handles.nmat,'sec')+dur(handles.nmat,'sec'));
tmin = handles.tmin*tlength;
tmax = handles.tmax*tlength;
window1 = onsetwindow(handles.nm1,tmin,tmax,'sec');
pianoroll(window1,'sec','hold','num','noylabel');
axis([tmin tmax get(handles.pianoroll1,'YLim')]);

if length(mchannels(handles.nmat))>1
    axes(handles.pianoroll2)
    hold off
    cla
    window2 = onsetwindow(handles.nm2,tmin,tmax,'sec');
    pianoroll(window2,'sec','hold','g','num','noylabel');
    axis([tmin tmax get(handles.pianoroll2,'YLim')]);
    set(handles.pianoroll2,'Visible','on');
end
%handles.analysis = 0;
%handles.cor = 0;
set(handles.filename,'String',handles.file);
set(handles.Play_Impro,'Enable','on');
set(handles.Analyse,'Enable','on');
listaxes=[handles.axe1, handles.axe2, handles.axe3, handles.axe4, handles.axe5, handles.axe6, handles.axe7, handles.axe8, handles.axe9, handles.axe10, handles.axe11 handles.axe12 handles.axe13 handles.axe14];
%for i=(1:14)
%    set(listaxes(i),'Visible','off');
%end
displayfig(handles);
guidata(hObject, handles);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --------------------------------------------------------------------
function Play_Impro_Callback(hObject, eventdata, handles)
% hObject    handle to Play_Impro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
playmidi(handles.nmat);


% --------------------------------------------------------------------
function Analyse_Callback(hObject, eventdata, handles)
% hObject    handle to Analyse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(handles.nmat)
    return
end
handles.choice = choice;
tmin=0; %max(onset(handles.nmat,'sec')+dur(handles.nmat,'sec'))*handles.tmin;
tmax=max(onset(handles.nmat,'sec')+dur(handles.nmat,'sec')); %*handles.tmax;
wlen=handles.choice.wlen;
nm1=handles.nm1;
nm2=handles.nm2;
wstep=1;
nb=0;
if size(nm2,2)>0
    nbtotal=handles.choice.totalindiv*2 + handles.choice.totalcomm;
else
    nbtotal=handles.choice.totalindiv + handles.choice.totalcomm;
end
wait = waitbar(0,'Analysing...');
if (handles.choice.dens == 1)  
    waitbar(nb/nbtotal,wait,['Computing note density of player 1...']);
    nb=nb+1;
    handles.dens1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','nnotes')/wlen; 
end
if (handles.choice.dur == 1)  
    waitbar(nb/nbtotal,wait,['Computing mean duration of player 1...']);
    nb=nb+1;
    handles.dur1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','duraccent','dur','mean'); 
end
if (handles.choice.meanp == 1)
    waitbar(nb/nbtotal,wait,['Computing mean pitch of player 1...']);
    nb=nb+1;
    handles.meanp1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','pitch','mean');
end
if (handles.choice.stdp == 1)
    waitbar(nb/nbtotal,wait,['Computing pitch variance of player 1...']);
    nb=nb+1;
    handles.stdp1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','pitch','std');
end
if (handles.choice.meanv == 1) 
    waitbar(nb/nbtotal,wait,['Computing mean velocity of player 1...']);
    nb=nb+1;
    handles.meanv1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','velocity','mean');
end
if (handles.choice.art == 1)  
    waitbar(nb/nbtotal,wait,['Computing articulation of player 1...']);
    nb=nb+1;
    handles.art1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','myarticulation');
end
if or(handles.choice.ac == 1,handles.choice.tempo == 1) 
    waitbar(nb/nbtotal,wait,['Computing pulse clarity of player 1...']);
    nb=nb+1;
    ryt1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','mypulsesalience');
    if (handles.choice.ac == 1) handles.ac1=ryt1(:,1); end
    if (handles.choice.tempo == 1) handles.tempo1=ryt1(:,2); end
end
if (handles.choice.ton == 1)  
    waitbar(nb/nbtotal,wait,['Computing tonal clarity of player 1...']);
    nb=nb+1;
    handles.ton1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','maxkkcc'); 
end
if (handles.choice.maj == 1)  
    waitbar(nb/nbtotal,wait,['Computing majorness of player 1...']);
    nb=nb+1;
    handles.maj1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','majorkkcc'); 
end
if (handles.choice.min == 1)  
    nb/nbtotal
    waitbar(nb/nbtotal,wait,['Computing minorness of player 1...']);
    nb=nb+1;
    handles.min1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','minorkkcc'); 
end
if (handles.choice.dis == 1)
    waitbar(nb/nbtotal,wait,['Computing dissonance of player 1...']);
    nb=nb+1;
    handles.dis1=dissonance3(nm1,1,wlen,wstep,tmin,tmax)'; 
end
if (handles.choice.silence == 1)  
    nb/nbtotal
    waitbar(nb/nbtotal,wait,['Computing silence factor of player 1...']);
    nb=nb+1;
    handles.sil1=silence(nm1,nm1,5,2);
end
if size(nm2,2)>0
	if (handles.choice.dens == 1)  
        waitbar(nb/nbtotal,wait,['Computing note density of player 2...']);
        nb=nb+1;
        handles.dens2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','nnotes')/wlen;
    end
	if (handles.choice.dur == 1)  
        waitbar(nb/nbtotal,wait,['Computing mean duration of player 2...']);
        nb=nb+1;
        handles.dur2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','duraccent','dur','mean'); end
	if (handles.choice.meanp == 1)  
        waitbar(nb/nbtotal,wait,['Computing mean pitch of player 2...']);
        nb=nb+1;
        handles.meanp2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','pitch','mean');
    end
	if (handles.choice.stdp == 1)  
        waitbar(nb/nbtotal,wait,['Computing pitch variance of player 2...']);
        nb=nb+1;
        handles.stdp2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','pitch','std');
    end
	if (handles.choice.meanv == 1)  
        waitbar(nb/nbtotal,wait,['Computing mean velocity of player 2...']);
        nb=nb+1;
        handles.meanv2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','velocity','mean');
    end
	if (handles.choice.art == 1)  
        waitbar(nb/nbtotal,wait,['Computing articulation of player 2...']);
        nb=nb+1;
        handles.art2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','myarticulation'); 
    end
    if or(handles.choice.ac == 1,handles.choice.tempo == 1) 
        waitbar(nb/nbtotal,wait,['Computing pulse clarity of player 2...']);
        nb=nb+1;
            ryt2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','mypulsesalience');
            if (handles.choice.ac == 1) handles.ac2=ryt2(:,1); end
            if (handles.choice.tempo == 1) handles.tempo2=ryt2(:,2); end
    end
    if (handles.choice.ton == 1)  
        waitbar(nb/nbtotal,wait,['Computing tonal clarity of player 2...']);
        nb=nb+1;
        handles.ton2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','maxkkcc'); 
    end
	if (handles.choice.maj == 1)  
        waitbar(nb/nbtotal,wait,['Computing majorness of player 2...']);
        nb=nb+1;
        handles.maj2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','majorkkcc'); 
    end
    if (handles.choice.min == 1)  
        waitbar(nb/nbtotal,wait,['Computing minorness of player 2...']);
        nb=nb+1;
        handles.min2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','minorkkcc'); 
    end
    if (handles.choice.dis == 1)  
        waitbar(nb/nbtotal,wait,['Computing dissonance of player 2...']);
        nb=nb+1;
        handles.dis2=dissonance3(nm2,1,wlen,wstep,tmin,tmax)'; 
    end
    if (handles.choice.silence == 1) 
        waitbar(nb/nbtotal,wait,['Computing silence factor of player 2...']);
        nb=nb+1;
        handles.sil1=silence(nm1,nm2,5,2);
        handles.sil2=silence(nm2,nm1,5,2);
    end
	if or(handles.choice.sync == 1,handles.choice.syntempo == 1) 
        waitbar(nb/nbtotal,wait,['Computing synchronicity...']);
        nb=nb+1;
        syn=intermovewindow(nm1,nm2,wlen,wstep,tmin,tmax,'sec','interpulsesalience');
        if (handles.choice.sync == 1) handles.sync=syn(:,1); end
        if (handles.choice.syntempo == 1) handles.syntempo=syn(:,2); end
    end
end
handles.analysis = 1;
handles.cor = 0;
set(handles.Compute_Imitation,'Enable','on');
set(handles.Save_Analysis,'Enable','on');
set(handles.Display_Analysis,'Enable','on');
set(handles.Display_individual_stat,'Enable','on');
set(handles.Display_therapist_stat,'Enable','on');
guidata(hObject, handles);
waitbar(1,wait,['Displaying result...']);
displayfig(handles);
close(wait);


% --- Analysis display function.
function displayfig(handles)
% handles    structure with handles and user data (see GUIDATA)

axe=0;
nbaxes = handles.choice.total;
h = gcf;
listaxes=[handles.axe1, handles.axe2, handles.axe3, handles.axe4, handles.axe5, handles.axe6, handles.axe7, handles.axe8, handles.axe9, handles.axe10, handles.axe11 handles.axe12 handles.axe13 handles.axe14];
listcaptions=[handles.caption1, handles.caption2, handles.caption3, handles.caption4, handles.caption5, handles.caption6, handles.caption7, handles.caption8, handles.caption9, handles.caption10, handles.caption11 handles.caption12 handles.caption13 handles.caption14];
listtext1=[handles.text27, handles.text28, handles.text29, handles.text30, handles.text31, handles.text32, handles.text33, handles.text34, handles.text35, handles.text36, handles.text37 handles.text38 handles.text39 handles.text40];
listtext2=[handles.text41, handles.text42, handles.text43, handles.text44, handles.text45, handles.text46, handles.text47, handles.text48, handles.text49, handles.text50, handles.text51 handles.text52 handles.text53 handles.text54];
if nbaxes>0
    height = 50/nbaxes;
    for i=(1:nbaxes)
        axes(listaxes(i));
        cla;
        Position = get(listaxes(i),'Position');
        set(listaxes(i),'Position',[Position(1),height*(nbaxes-i)+1,Position(3),height-0.5]);
        set(listaxes(i),'Visible','on');
        Position = get(listcaptions(i),'Position');
        set(listcaptions(i),'Position',[Position(1),height*(nbaxes-i+1)-0.5,Position(3),1]);
        set(listcaptions(i),'Visible','on');
        Position = get(listtext1(i),'Position');
        set(listtext1(i),'Position',[Position(1),height*(nbaxes-i+1)-1.4,Position(3),1]);
        set(listtext1(i),'Visible','on');
        Position = get(listtext2(i),'Position');
        set(listtext2(i),'Position',[Position(1),height*(nbaxes-i+1)-2.3,Position(3),1]);
        set(listtext2(i),'Visible','on');
    end
end
for i=(nbaxes+1:14)
    axes(listaxes(i));
    cla;
    Position = get(listaxes(i),'Position');
    set(listaxes(i),'Position',[Position(1),0,Position(3),0.01]);
    set(listaxes(i),'Visible','off');
    Position = get(listcaptions(i),'Position');
    set(listcaptions(i),'String','');
    set(listcaptions(i),'Position',[Position(1),0,Position(3),0.01]);
    set(listcaptions(i),'Visible','off');
    Position = get(listtext1(i),'Position');
    set(listtext1(i),'String','');
    set(listtext1(i),'Position',[Position(1),0,Position(3),0.01]);
    set(listtext1(i),'Visible','off');
    Position = get(listtext2(i),'Position');
    set(listtext2(i),'String','');
    set(listtext2(i),'Position',[Position(1),0,Position(3),0.01]);
    set(listtext2(i),'Visible','off');
end
if (handles.color == 0)
    colormap(gray);
else
    colormap('default');
end

if (handles.choice.total > 0)
    if (handles.choice.dens == 1)
        axe = display_dim(handles.dens1,handles.dens2,handles.denscor,handles.oldstat.dens,'density',handles,axe);
    end
    if (handles.choice.dur == 1)
        axe = display_dim(handles.dur1,handles.dur2,handles.durcor,handles.oldstat.dur,'mean dur',handles,axe);
    end
    if (handles.choice.meanp == 1)    
        axe = display_dim(handles.meanp1,handles.meanp2,handles.meanpcor,handles.oldstat.meanp,'mean pitch',handles,axe);
    end
    if (handles.choice.stdp == 1)
        axe = display_dim(handles.stdp1,handles.stdp2,handles.stdpcor,handles.oldstat.stdp,'pitch std',handles,axe);
    end
    if (handles.choice.meanv == 1)
        axe = display_dim(handles.meanv1,handles.meanv2,handles.meanvcor,handles.oldstat.meanv,',mean vel',handles,axe);
    end
    if (handles.choice.ac == 1)
        axe = display_dim(handles.ac1,handles.ac2,handles.accor,handles.oldstat.ac,'pulse clar',handles,axe);
    end
    if (handles.choice.ton == 1)
        axe = display_dim(handles.ton1,handles.ton2,handles.toncor,handles.oldstat.ton,'tonality',handles,axe);
    end
    if (handles.choice.maj == 1)
        axe = display_dim(handles.maj1,handles.maj2,handles.majcor,handles.oldstat.maj,'majorness',handles,axe);
    end
    if (handles.choice.min == 1)
        axe = display_dim(handles.min1,handles.min2,handles.mincor,handles.oldstat.min,'minorness',handles,axe);
    end
    if (handles.choice.art == 1)
        axe = display_dim(handles.art1,handles.art2,handles.artcor,handles.oldstat.art,'articulation',handles,axe);
    end
    if (handles.choice.tempo == 1)
        axe = display_dim(handles.tempo1,handles.tempo2,handles.tempocor,handles.oldstat.tempo,'tempo',handles,axe);
    end
    if (handles.choice.dis == 1)
        axe = display_dim(handles.dis1,handles.dis2,handles.discor,handles.oldstat.dis,'dissonance',handles,axe);
    end
    if and(handles.choice.sync == 1, size(handles.nm2,2) > 0)
        axe = display_common(handles.sync,handles.oldstat.sync,'synchronicity',handles,axe);
    end
    if and(handles.choice.syntempo == 1, size(handles.nm2,2) > 0)
        axe = display_common(handles.syntempo,handles.oldstat.syntempo,'synchro tempo',handles,axe);
    end
    if and(handles.analysis,handles.choice.silence == 1)
        if handles.color==1
            c1='k-';
            c2='g-';
        end
        set(handles.silencetitle,'String','silence:');
        set(handles.silencetext1,'String',num2str(handles.sil1));
        if size(handles.nm2,2)==0
            set(handles.silencetext2,'String','')
        else
            set(handles.silencetext2,'String',num2str(handles.sil2));
        end
    else
        set(handles.silencetitle,'String','');
        set(handles.silencetext1,'String','');
        set(handles.silencetext2,'String','');
    end
end

function axe = display_dim(dim1,dim2,cor,stat,title,handles,axe)
axe=axe+1;
listaxes=[handles.axe1, handles.axe2, handles.axe3, handles.axe4, handles.axe5, handles.axe6, handles.axe7, handles.axe8, handles.axe9, handles.axe10, handles.axe11 handles.axe12 handles.axe13 handles.axe14];
listcaptions=[handles.caption1, handles.caption2, handles.caption3, handles.caption4, handles.caption5, handles.caption6, handles.caption7, handles.caption8, handles.caption9, handles.caption10, handles.caption11 handles.caption12 handles.caption13 handles.caption14];
listtext1=[handles.text27, handles.text28, handles.text29, handles.text30, handles.text31, handles.text32, handles.text33, handles.text34, handles.text35, handles.text36, handles.text37 handles.text38 handles.text39 handles.text40];
listtext2=[handles.text41, handles.text42, handles.text43, handles.text44, handles.text45, handles.text46, handles.text47, handles.text48, handles.text49, handles.text50, handles.text51 handles.text52 handles.text53 handles.text54];
axes(listaxes(axe))
set(listaxes(axe),'Visible','on');
set(listcaptions(axe),'String',title);
hold off
cla
col=handles.color;
if col==1
    if and(handles.cor, handles.cordisplay)
        c1='w-';
        c1a='w';
        c1s='w:';
    else
        c1='k-';
        c1a='k';
        c1s='k:';
    end
    c2='g-';
    c2a='g';
    c2s='g:';
    cba='r';
    cbs='r:';
    fsize=9;
else
    c1='k-';
    c2='k--';
    cba='k+';
    cbs='k:';
    c1a='k-';
    c1s='k-.';
    c2a='k-';
    c2s='k-.';
    fsize=9;
end
l = length(dim1)-1;
tmin=floor(handles.tmin*l)+1;
tmax=ceil(handles.tmax*l)+1;
if and(not(cor==0), handles.cordisplay)
    lc=size(cor,2)-1;
    tminc=floor(handles.tmin*lc)+1;
    tmaxc=ceil(handles.tmax*lc)+1;
    ymin = min([dim1;dim2]);
    ymax = max([dim1;dim2]);
    if and(isstruct(stat), handles.statdisplay)
        ymin = min([ymin;stat.mean-1*stat.std]);
        ymax = max([ymax;stat.mean+1*stat.std]);
    end
    if handles.color
        imagesc([1,tmax-tmin+1],[ymin,ymax],cor(:,tminc:tmaxc),[0,1])
        hold on
    else
        fig=ones(size(cor));
        for x = (1:size(cor,1))
            for y = (1:size(cor,2))
                if ~isnan(cor(x,y))
                    fig(x,y)=1-cor(x,y);
                end
            end
        end
        imagesc([1,tmax-tmin+1],[ymin,ymax],fig(:,tminc:tmaxc),[0.3,1])  
        hold on
    end
end
if and(handles.analysis, handles.analysisdisplay)
    plot(dim1(tmin:tmax),c1);
    hold on
    if size(handles.nm2,2)>0
        plot(dim2(tmin:tmax),c2)
    end
    %ylabel(title,'FontSize',fsize); set(gca,'FontSize',fsize);
end
if and(isstruct(stat), handles.statdisplay)
    plot((1:(tmax-tmin)/20:tmax-tmin+1),ones(1,21)*stat.mean,cba)
    hold on
    plot([1,tmax-tmin+1],[stat.mean-1*stat.std stat.mean-1*stat.std],cbs)
    plot([1,tmax-tmin+1],[stat.mean+1*stat.std stat.mean+1*stat.std],cbs)
    set(listtext2(axe),'String',['av:' num2str(stat.mean,2) ',std:' num2str(stat.std,2)]);
    set(listtext2(axe),'ForegroundColor',[1.0 0.0 0.0]);    
end
if and(handles.analysis, handles.indivstatdisplay)
    dim1=dim1(tmin:tmax);
    dim1=dim1(~isnan(dim1));
    plot((1:(tmax-tmin)/20:tmax-tmin+1),ones(1,21)*mean(dim1),c1a)
    hold on
    plot([1,tmax-tmin+1],[mean(dim1)-1*std(dim1) mean(dim1)-1*std(dim1)],c1s)
    plot([1,tmax-tmin+1],[mean(dim1)+1*std(dim1) mean(dim1)+1*std(dim1)],c1s)
    set(listtext1(axe),'String',['av:' num2str(mean(dim1),2) ',std:' num2str(std(dim1),2)]);
end
if and(handles.analysis, handles.therapistdisplay)
    dim2=dim2(tmin:tmax);
    dim2=dim2(~isnan(dim2));
    plot((1:(tmax-tmin)/20:tmax-tmin+1),ones(1,21)*mean(dim2),c2a)
    hold on
    plot([1,tmax-tmin+1],[mean(dim2)-1*std(dim2) mean(dim2)-1*std(dim2)],c2s)
    plot([1,tmax-tmin+1],[mean(dim2)+1*std(dim2) mean(dim2)+1*std(dim2)],c2s)
    set(listtext2(axe),'String',['av:' num2str(mean(dim2),2) ',std:' num2str(std(dim2),2)]);
    set(listtext2(axe),'ForegroundColor',[0.0 0.7 0.0]);    
end
axis tight


function axe = display_common(common,stat,title,handles,axe)
axe=axe+1;
listaxes=[handles.axe1, handles.axe2, handles.axe3, handles.axe4, handles.axe5, handles.axe6, handles.axe7, handles.axe8, handles.axe9, handles.axe10, handles.axe11 handles.axe12 handles.axe13 handles.axe14];
listcaptions=[handles.caption1, handles.caption2, handles.caption3, handles.caption4, handles.caption5, handles.caption6, handles.caption7, handles.caption8, handles.caption9, handles.caption10, handles.caption11 handles.caption12 handles.caption13 handles.caption14];
listtext1=[handles.text27, handles.text28, handles.text29, handles.text30, handles.text31, handles.text32, handles.text33, handles.text34, handles.text35, handles.text36, handles.text37 handles.text38 handles.text39 handles.text40];
listtext2=[handles.text41, handles.text42, handles.text43, handles.text44, handles.text45, handles.text46, handles.text47, handles.text48, handles.text49, handles.text50, handles.text51 handles.text52 handles.text53 handles.text54];
axes(listaxes(axe))
set(listaxes(axe),'Visible','on');
set(listcaptions(axe),'String',title);
hold off
cla
col=handles.color;
if col==1
    c1='k-';
    cba='r';
    cbs='r:';
    c1a='k';
    c1s='k:';
    fsize=9;
else
    c1='k-';
    c2='k--';
    cba='k+';
    cbs='k:';
    c1a='k-';
    c1s='k-.';
    fsize=9;
end
l = length(common)-1;
tmin=floor(handles.tmin*l)+1;
tmax=ceil(handles.tmax*l)+1;
if and(handles.analysis, handles.analysisdisplay)
    plot(common(tmin:tmax),c1);
    %ylabel(title,'FontSize',fsize); set(gca,'FontSize',fsize);
    hold on
end
if and(isstruct(stat), handles.statdisplay)
    plot((1:(tmax-tmin)/20:tmax-tmin+1),ones(1,21)*stat.mean,cba)
    hold on
    plot([1,tmax-tmin+1],[stat.mean-1*stat.std stat.mean-1*stat.std],cbs)
    plot([1,tmax-tmin+1],[stat.mean+1*stat.std stat.mean+1*stat.std],cbs)
    set(listtext2(axe),'String',['av:' num2str(stat.mean,2) ',std:' num2str(stat.std,2)]);
end
if and(handles.analysis, handles.indivstatdisplay)
    common=common(tmin:tmax);
    common=common(~isnan(common));
    plot((1:(tmax-tmin)/20:tmax-tmin+1),ones(1,21)*mean(common),c1a)
    mean(common)
    std(common)
    hold on
    plot([1,tmax-tmin+1],[mean(common)-1*std(common) mean(common)-1*std(common)],c1s)
    plot([1,tmax-tmin+1],[mean(common)+1*std(common) mean(common)+1*std(common)],c1s)
    set(listtext1(axe),'String',['av:' num2str(mean(common),2) ',std:' num2str(std(common),2)]);
end
axis tight

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

handles.wlen = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Display_Analysis_Callback(hObject, eventdata, handles)
% hObject    handle to Display_Analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject,'Checked'),'off')
    set(hObject,'Checked','on');
    handles.analysisdisplay=1;
    guidata(hObject, handles);
    displayfig(handles);
else
    set(hObject,'Checked','off');
    handles.analysisdisplay=0;
    guidata(hObject, handles);
    displayfig(handles);
end


% --------------------------------------------------------------------
function Compute_Imitation_Callback(hObject, eventdata, handles)
% hObject    handle to Compute_Imitation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if and(handles.analysis,size(handles.nm2,2)>0)
    cor = handles.corcoef;
    step = handles.step;
    nb=0;
    nbtotal=handles.choice.totalindiv;
    wait = waitbar(0,'Computing the imitation diagram...');
    if (handles.choice.dens == 1)
        waitbar(nb/nbtotal,wait,['Computing imitation along note density...']);
        nb=nb+1;
        handles.denscor = crosscors(handles.dens1',handles.dens2',cor,floor(cor*step)); 
    end
    if (handles.choice.dur == 1) 
        waitbar(nb/nbtotal,wait,['Computing imitation along note duration...']);
        nb=nb+1;
        handles.durcor = crosscors(handles.dur1',handles.dur2',cor,floor(cor*step)); 
    end
    if (handles.choice.meanp == 1) 
        waitbar(nb/nbtotal,wait,['Computing imitation along mean pitch...']);
        nb=nb+1;
        handles.meanpcor = crosscors(handles.meanp1',handles.meanp2',cor,floor(cor*step)); 
    end
    if (handles.choice.stdp == 1) 
        waitbar(nb/nbtotal,wait,['Computing imitation along pitch variance...']);
        nb=nb+1;
        handles.stdpcor = crosscors(handles.stdp1',handles.stdp2',cor,floor(cor*step)); 
    end
    if (handles.choice.meanv == 1) 
        waitbar(nb/nbtotal,wait,['Computing imitation along mean velocity...']);
        nb=nb+1;
        handles.meanvcor = crosscors(handles.meanv1',handles.meanv2',cor,floor(cor*step)); 
    end
    if (handles.choice.ac == 1) 
        waitbar(nb/nbtotal,wait,['Computing imitation along pulse clarity...']);
        nb=nb+1;
        handles.accor = crosscors(handles.ac1',handles.ac2',cor,floor(cor*step)); 
    end
    if (handles.choice.ton == 1) 
        waitbar(nb/nbtotal,wait,['Computing imitation along tonality...']);
        nb=nb+1;
        handles.toncor = crosscors(handles.ton1',handles.ton2',cor,floor(cor*step)); 
    end
    if (handles.choice.maj == 1) 
        waitbar(nb/nbtotal,wait,['Computing imitation along majorness...']);
        nb=nb+1;
        handles.majcor = crosscors(handles.maj1',handles.maj2',cor,floor(cor*step)); 
    end
    if (handles.choice.min == 1) 
        waitbar(nb/nbtotal,wait,['Computing imitation along minorness...']);
        nb=nb+1;
        handles.mincor = crosscors(handles.min1',handles.min2',cor,floor(cor*step)); 
    end
    if (handles.choice.art == 1) 
        waitbar(nb/nbtotal,wait,['Computing imitation along articulation...']);
        nb=nb+1;
        handles.artcor = crosscors(handles.art1',handles.art2',cor,floor(cor*step)); 
    end
    if (handles.choice.tempo == 1) 
        waitbar(nb/nbtotal,wait,['Computing imitation along tempo...']);
        nb=nb+1;
        handles.tempocor = crosscors(handles.tempo1',handles.tempo2',cor,floor(cor*step)); 
    end
    if (handles.choice.dis == 1) 
        waitbar(nb/nbtotal,wait,['Computing imitation along dissonance...']);
        nb=nb+1;
        handles.discor = crosscors(handles.dis1',handles.dis2',cor,floor(cor*step)); 
    end
    handles.cor = 1;
    set(handles.Display_Imitation,'Checked','on');
    handles.cordisplay=1;
    guidata(hObject, handles);
    waitbar(nb/nbtotal,wait,['Displaying imitation diagram...']);
    displayfig(handles);
    close(wait);
end


% --------------------------------------------------------------------
function Display_Imitation_Callback(hObject, eventdata, handles)
% hObject    handle to Display_Imitation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject,'Checked'),'off')
    set(hObject,'Checked','on');
    handles.cordisplay=1;
    guidata(hObject, handles);
    displayfig(handles);
else
    set(hObject,'Checked','off');
    handles.cordisplay=0;
    guidata(hObject, handles);
    displayfig(handles);
end


function windowedit_Callback(hObject, eventdata, handles)
% hObject    handle to windowedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of windowedit as text
%        str2double(get(hObject,'String')) returns contents of windowedit as a double

handles.corcoef = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function windowedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windowedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function stepedit_Callback(hObject, eventdata, handles)
% hObject    handle to stepedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stepedit as text
%        str2double(get(hObject,'String')) returns contents of stepedit as a double
handles.step = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function stepedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stepedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Save_Analysis_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uiputfile({'*.tif','TIF image (*.tif)'}, 'Save the analysis as',handles.file);
%;'*.jpg','JPEG image (*.jpg)';'.bmp','BITMAP file (*.bmp)';'.eps','EPS file (*.eps)'
if (not(file==0))
    cd(path)
    %saveas(gcf,file),'tiffn';
    %print('-dpng','-r70',file);
    I = getframe(gcf);
    imwrite(I.cdata, file);
end


function pos = compute_position(x, tmin, tmax, delta)
if and(x>delta, x<1-delta)
    pos = tmin + (x-delta)/(1-2*delta)*(tmax-tmin);
else
    if (x<delta)
        pos = x/delta*tmin;
    else
        pos = 1-(1-x)/delta*(1-tmax);
    end
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.tmin = compute_position(get(hObject,'Value'), handles.tmin, handles.tmax, handles.delta);
%handles.analysis = 0;
%handles.cor = 0;
if handles.tmin > 0
    set(hObject,'Value',handles.delta);
end
guidata(hObject, handles);
display_pianoroll(hObject, handles);
displayfig(handles);


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.tmax = compute_position(get(hObject,'Value'), handles.tmin, handles.tmax, handles.delta);
%handles.analysis = 0;
%handles.cor = 0;
if handles.tmax < 1
    set(hObject,'Value',1-handles.delta);
end
guidata(hObject, handles);
display_pianoroll(hObject, handles);
displayfig(handles);


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in Colorbox.
function Colorbox_Callback(hObject, eventdata, handles)
% hObject    handle to Colorbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Colorbox

if (get(hObject,'Value') == get(hObject,'Max'))
    handles.color=1;
    guidata(hObject, handles);
    displayfig(handles);
else
    handles.color=0;
    guidata(hObject, handles);
    displayfig(handles);
end


% --------------------------------------------------------------------
function Save_stat_Callback(hObject, eventdata, handles)
% hObject    handle to Save_stat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.analysis
    statname=get(handles.statname,'String');
    if strcmp(statname,'No stat loaded')
        statname='unnamed.stat';
    end
    [file,path] = uiputfile({'*.stat','impro statistic files (*.stat)'},'Save the updated statistics of the client',statname);

if not(file==0)
    dens1 = handles.dens1(~isnan(handles.dens1));
    dur1 = handles.dur1(~isnan(handles.dur1));
    meanp1 = handles.meanp1(~isnan(handles.meanp1));
    stdp1 = handles.stdp1(~isnan(handles.stdp1));
    meanv1 = handles.meanv1(~isnan(handles.meanv1));
    ac1 = handles.ac1(~isnan(handles.ac1));
    ton1 = handles.ton1(~isnan(handles.ton1));
    art1 = handles.art1(~isnan(handles.art1));
    data = [handles.wlen; mean(dens1); var(dens1); mean(dur1); var(dur1); mean(meanp1); var(meanp1); mean(stdp1); var(stdp1);
        mean(meanv1); var(meanv1); mean(ac1); var(ac1); mean(ton1); var(ton1); mean(art1); var(art1)];
    if handles.stat
        res = [handles.statfile data];
    else
        res = data;
    end
    cd(path)
    save('-ascii',file,'data');
    handles.statfile = res;
    stat = handles.statfile(2:end,:);
    handles.dens.mean=mean(stat(1,:));
    handles.dens.stdp=sqrt(mean(stat(2,:)));
    handles.dur.mean=mean(stat(3,:));
    handles.dur.stdp=sqrt(mean(stat(4,:)));
    handles.meanp.mean=mean(stat(5,:));
    handles.meanp.stdp=sqrt(mean(stat(6,:)));
    handles.stdp.mean=mean(stat(7,:));
    handles.stdp.stdp=sqrt(mean(stat(8,:)));
    handles.meanv.mean=mean(stat(9,:));
    handles.meanv.stdp=sqrt(mean(stat(10,:)));
    handles.ac.mean=mean(stat(11,:));
    handles.ac.stdp=sqrt(mean(stat(12,:)));
    handles.ton.mean=mean(stat(13,:));
    handles.ton.stdp=sqrt(mean(stat(14,:)));
    handles.art.mean=mean(stat(15,:));
    handles.art.stdp=sqrt(mean(stat(16,:)));
    handles.stat=1;
    set(handles.statname,'String',file);
    handles.statsize=size(stat,2);
    guidata(hObject, handles);
    displayfig(handles);
end
end

% --- Executes on button press in clearbutton.
function clearbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.stat=0;
set(handles.statname,'String','No stat loaded');
guidata(hObject, handles);
displayfig(handles);


% --- Executes on button press in densbox.
function densbox_Callback(hObject, eventdata, handles)
% hObject    handle to densbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (get(hObject,'Value') == get(hObject,'Max'))
    handles.denschoice=1;
else
    handles.denschoice=0;
end
guidata(hObject, handles);


% --- Executes on button press in durbox.
function durbox_Callback(hObject, eventdata, handles)
% hObject    handle to durbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (get(hObject,'Value') == get(hObject,'Max'))
    handles.durchoice=1;
else
    handles.durchoice=0;
end
guidata(hObject, handles);


% --------------------------------------------------------------------
function Analysis_Callback(hObject, eventdata, handles)
% hObject    handle to Analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Clear_stat_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_stat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Imitations_Callback(hObject, eventdata, handles)
% hObject    handle to Imitations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function stat_Callback(hObject, eventdata, handles)
% hObject    handle to stat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Display_individual_stat_Callback(hObject, eventdata, handles)
% hObject    handle to Display_Analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject,'Checked'),'off')
    set(hObject,'Checked','on');
    handles.indivstatdisplay=1;
    guidata(hObject, handles);
    displayfig(handles);
else
    set(hObject,'Checked','off');
    handles.indivstatdisplay=0;
    guidata(hObject, handles);
    displayfig(handles);
end


% --------------------------------------------------------------------
function Load_stat_Callback(hObject, eventdata, handles)
% hObject    handle to Load_stat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile({'*.stat','impro statistic files (*.stat)'}, 'Pick a statistic file');
if (not(file==0))
    cd(path)
    handles.oldstat = computestat(file, handles.wlen);
    displayfig(handles);
end
set(handles.Display_stat,'Checked','on');
set(handles.Display_stat,'Enable','on');
set(handles.Display_therapist_stat,'Checked','off');
handles.statdisplay=1;
guidata(hObject, handles);
displayfig(handles);


% --------------------------------------------------------------------
function Display_stat_Callback(hObject, eventdata, handles)
% hObject    handle to Display_stat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject,'Checked'),'off')
    set(hObject,'Checked','on');
    set(handles.Display_therapist_stat,'Checked','off');
    handles.statdisplay=1;
    handles.therapistdisplay=0;
    guidata(hObject, handles);
    displayfig(handles);
else
    set(hObject,'Checked','off');
    handles.statdisplay=0;
    guidata(hObject, handles);
    displayfig(handles);
end


% --------------------------------------------------------------------
function Display_therapist_stat_Callback(hObject, eventdata, handles)
% hObject    handle to Display_therapist_stat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject,'Checked'),'off')
    set(hObject,'Checked','on');
    set(handles.Display_stat,'Checked','off');
    handles.therapistdisplay=1;
    handles.statdisplay=0;
    guidata(hObject, handles);
    displayfig(handles);
else
    set(hObject,'Checked','off');
    handles.therapistdisplay=0;
    guidata(hObject, handles);
    displayfig(handles);
end