function varargout = analysis(varargin)
% ANALYSIS M-filename for analysis.fig
%      ANALYSIS, by itself, creates a new ANALYSIS or raises the existing
%      singleton*.
%
%      H = ANALYSIS returns the handle to a new ANALYSIS or the handle to
%      the existing singleton*.
%
%      ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYSIS.M with the given handles.statname arguments.
%
%      ANALYSIS('Property','Value',...) creates a new ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before analysis_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help analysis

% Last Modified by GUIDE v2.5 01-Dec-2005 15:30:19

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
handles.stat = 0;
handles.statsize = 0;
handles.cor = 0;
handles.analysisdisplay = 1;
handles.statdisplay = 1;
handles.cordisplay = 1;
handles.wlen = 6.0;
handles.corcoef = 40.0;
handles.step = 0.05;
handles.file = 'nofile';
handles.tmin = 0.0;
handles.tmax = 1.0;
handles.color = 1;
handles.delta = 0.011;
handles.denschoice = 1;
handles.durchoice = 1;

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

[file,path] = uigetfile({'*.mid','MIDI Files (*.mid)'}, 'Pick a MIDI file');
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
end


function display_pianoroll(hObject, handles)
set(handles.filename,'String','Displaying...');
axes(handles.pianoroll1)
tlength = max(onset(handles.nmat,'sec'));
tmin = handles.tmin*tlength
tmax = handles.tmax*tlength
window1 = onsetwindow(handles.nm1,tmin,tmax,'sec');
pianoroll(window1,'sec','hold');
axis([tmin tmax get(handles.pianoroll1,'YLim')]);

if length(mchannels(handles.nmat))>1
    axes(handles.pianoroll1)
    window2 = onsetwindow(handles.nm2,tmin,tmax,'sec');
    pianoroll(handles.nm2,'sec','hold');
    axis([tmin tmax get(handles.pianoroll1,'YLim')]);
end
handles.analysis = 0;
handles.cor = 0;
set(handles.filename,'String',handles.file);
guidata(hObject, handles);
displayfig(handles);


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


% --- Executes on button press in playbutton.
function playbutton_Callback(hObject, eventdata, handles)
% hObject    handle to playbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

playmidi(handles.nmat);


% --- Executes on button press in analysisbutton.
function analysisbutton_Callback(hObject, eventdata, handles)
% hObject    handle to analysisbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if not(handles.nmat)
    return
end
tmin=max(onset(handles.nmat,'sec'))*handles.tmin;
tmax=max(onset(handles.nmat,'sec'))*handles.tmax;
wlen=handles.wlen;
wstep=1;
t=tmin:wstep:tmax;
nm1=handles.nm1;
nm2=handles.nm2;
handles.stdp1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','pitch','std');
handles.meanp1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','pitch','mean');
handles.meanv1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','velocity','mean');
handles.ton1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','maxkkcc');
handles.dens1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','nnotes')/wlen;
handles.dur1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','duraccent','dur','mean');
handles.ac1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','pulsesalience');
handles.art1=mymovewindow(nm1,wlen,wstep,tmin,tmax,'sec','articulation');
if size(nm2,2)>0
	handles.stdp2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','pitch','std');
	handles.meanp2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','pitch','mean');
	handles.meanv2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','velocity','mean');
	handles.ton2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','maxkkcc');
	handles.dens2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','nnotes')/wlen;
	handles.dur2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','duraccent','dur','mean');
	handles.ac2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','pulsesalience');
	handles.art2=mymovewindow(nm2,wlen,wstep,tmin,tmax,'sec','articulation');
end
handles.analysis = 1;
guidata(hObject, handles);
displayfig(handles);


% --- Analysis display function.
function displayfig(handles)
% handles    structure with handles and user data (see GUIDATA)

tmin=0;
if handles.analysis
    tmax=max(onset(handles.nmat,'sec'))*(handles.tmax-handles.tmin);   
else
    tmax=1;
end
wlen=handles.wlen;
wstep=1;
t=tmin:wstep:tmax;
col=handles.color;
if col==1
    if and(handles.cor, handles.cordisplay)
        c1='w-';
        c2='g-';
    else
        c1='k-';
        c2='g-';
    end
    s1='r--';
    s2='b:';
    fsize=9;
else
    c1='k-';
    c2='k--';
    s1='k+';
    s2='k:';
    fsize=9;
end

if (handles.color == 0)
    colormap(gray)
else
    colormap('default')
end

if and(handles.analysis, handles.analysisdisplay)
    stdp1=handles.stdp1;
    meanp1=handles.meanp1;
    meanv1=handles.meanv1;
    ton1=handles.ton1;
    dens1=handles.dens1;
    dur1=handles.dur1;
    ac1=handles.ac1;
    art1=handles.art1;
    nm2=handles.nm2;    
    if size(nm2,2)>0
        stdp2=handles.stdp2;
        meanp2=handles.meanp2;
        meanv2=handles.meanv2;
        ton2=handles.ton2;
        dens2=handles.dens2;
        dur2=handles.dur2;
        ac2=handles.ac2;
        art2=handles.art2;
    end
end

if (handles.denschoice == 1)
    axes(handles.axes32)
    cla
    hold on
    if and(handles.cor, handles.cordisplay)
        ymin = min([handles.dens1;handles.dens2]);
        ymax = max([handles.dens1;handles.dens2]);
        if and(handles.stat, handles.statdisplay)
            ymin = min([ymin;handles.dens.mean-1*handles.dens.stdp]);
            ymax = max([ymax;handles.dens.mean+1*handles.dens.stdp]);
        end
        if handles.color
            imagesc([tmin,tmax],[ymin,ymax],handles.denscor,[0,1])
        else
            fig=ones(size(handles.denscor));
            for x = (1:size(handles.denscor,1))
                for y = (1:size(handles.denscor,2))
                    if ~isnan(handles.denscor(x,y))
                        fig(x,y)=1-handles.denscor(x,y);
                    end
                end
            end
            imagesc([tmin,tmax],[ymin,ymax],fig,[0.3,1])   
        end
    end
    if and(handles.analysis, handles.analysisdisplay)
        plot(dens1,c1);
        if size(nm2,2)>0
            plot(dens2,c2)
        end
        ylabel('density','FontSize',fsize); set(gca,'FontSize',fsize);
    end
    if and(handles.stat, handles.statdisplay)
        plot((tmin:(tmax-tmin)/20:tmax),ones(1,21)*handles.dens.mean,s1)
        plot([tmin tmax],[handles.dens.mean-1*handles.dens.stdp handles.dens.mean-1*handles.dens.stdp],s2)
        plot([tmin tmax],[handles.dens.mean+1*handles.dens.stdp handles.dens.mean+1*handles.dens.stdp],s2)
    end
    axis tight
end

if (handles.durchoice == 1)
    axes(handles.axes32)
    cla
    hold on
    if and(handles.cor, handles.cordisplay)
        ymin = min([handles.dur1;handles.dur2]);
        ymax = max([handles.dur1;handles.dur2]);
        if and(handles.stat, handles.statdisplay)
            ymin = min([ymin;handles.dur.mean-1*handles.dur.stdp]);
            ymax = max([ymax;handles.dur.mean+1*handles.dur.stdp]);
        end
        if handles.color
            imagesc([tmin,tmax],[ymin,ymax],handles.durcor,[0,1])
        else
            fig=ones(size(handles.durcor));
            for x = (1:size(handles.durcor,1))
                for y = (1:size(handles.durcor,2))
                    if ~isnan(handles.durcor(x,y))
                        fig(x,y)=1-handles.durcor(x,y);
                    end
                end
            end
            imagesc([tmin,tmax],[ymin,ymax],fig,[0.3,1])   
        end
    end
    if and(handles.analysis, handles.analysisdisplay)
        plot(dur1,c1);
        if size(nm2,2)>0
            plot(dur2,c2)
        end
        ylabel('mean dur','FontSize',fsize); set(gca,'FontSize',fsize);
    end
    if and(handles.stat, handles.statdisplay)
        plot((tmin:(tmax-tmin)/20:tmax),ones(1,21)*handles.dur.mean,s1)
        plot([tmin tmax],[handles.dur.mean-1*handles.dur.stdp handles.dur.mean-1*handles.dur.stdp],s2)
        plot([tmin tmax],[handles.dur.mean+1*handles.dur.stdp handles.dur.mean+1*handles.dur.stdp],s2)
    end
    axis tight
end

axes(handles.axes32)
cla
hold on
if and(handles.cor, handles.cordisplay)
    ymin = min([handles.meanp1;handles.meanp2]);
    ymax = max([handles.meanp1;handles.meanp2]);
    if and(handles.stat, handles.statdisplay)
        ymin = min([ymin;handles.meanp.mean-1*handles.meanp.stdp]);
        ymax = max([ymax;handles.meanp.mean+1*handles.meanp.stdp]);
    end
    if handles.color
        imagesc([tmin,tmax],[ymin,ymax],handles.meanpcor,[0,1])
    else
        fig=ones(size(handles.meanpcor));
        for x = (1:size(handles.meanpcor,1))
            for y = (1:size(handles.meanpcor,2))
                if ~isnan(handles.meanpcor(x,y))
                    fig(x,y)=1-handles.meanpcor(x,y);
                end
            end
        end
        imagesc([tmin,tmax],[ymin,ymax],fig,[0.3,1])   
    end
end
if and(handles.analysis, handles.analysisdisplay)
    plot(meanp1,c1);
    if size(nm2,2)>0
        plot(meanp2,c2)
    end
    ylabel('mean pitch','FontSize',fsize); set(gca,'FontSize',fsize);
end
if and(handles.stat, handles.statdisplay)
    plot((tmin:(tmax-tmin)/20:tmax),ones(1,21)*handles.meanp.mean,s1)
    plot([tmin tmax],[handles.meanp.mean-1*handles.meanp.stdp handles.meanp.mean-1*handles.meanp.stdp],s2)
    plot([tmin tmax],[handles.meanp.mean+1*handles.meanp.stdp handles.meanp.mean+1*handles.meanp.stdp],s2)
end
axis tight

axes(handles.axes33)
cla
hold on
if and(handles.cor, handles.cordisplay)
    ymin = min([handles.stdp1;handles.stdp2]);
    ymax = max([handles.stdp1;handles.stdp2]);
    if and(handles.stat, handles.statdisplay)
        ymin = min([ymin;handles.stdp.mean-1*handles.stdp.stdp]);
        ymax = max([ymax;handles.stdp.mean+1*handles.stdp.stdp]);
    end
    if handles.color
        imagesc([tmin,tmax],[ymin,ymax],handles.stdpcor,[0,1])
    else
        fig=ones(size(handles.stdpcor));
        for x = (1:size(handles.stdpcor,1))
            for y = (1:size(handles.stdpcor,2))
                if ~isnan(handles.stdpcor(x,y))
                    fig(x,y)=1-handles.stdpcor(x,y);
                end
            end
        end
        imagesc([tmin,tmax],[ymin,ymax],fig,[0.3,1])   
    end
end
if and(handles.analysis, handles.analysisdisplay)
    plot(stdp1,c1);
    if size(nm2,2)>0
        plot(stdp2,c2)
    end
    ylabel('pitch stdp','FontSize',fsize); set(gca,'FontSize',fsize);
end
if and(handles.stat, handles.statdisplay)
    plot((tmin:(tmax-tmin)/20:tmax),ones(1,21)*handles.stdp.mean,s1)
    plot([tmin tmax],[handles.stdp.mean-1*handles.stdp.stdp handles.stdp.mean-1*handles.stdp.stdp],s2)
    plot([tmin tmax],[handles.stdp.mean+1*handles.stdp.stdp handles.stdp.mean+1*handles.stdp.stdp],s2)
end
axis tight

axes(handles.axes34)
cla
hold on
if and(handles.cor, handles.cordisplay)
    ymin = min([handles.meanv1;handles.meanv2]);
    ymax = max([handles.meanv1;handles.meanv2]);
    if and(handles.stat, handles.statdisplay)
        ymin = min([ymin;handles.meanv.mean-1*handles.meanv.stdp]);
        ymax = max([ymax;handles.meanv.mean+1*handles.meanv.stdp]);
    end
    if handles.color
        imagesc([tmin,tmax],[ymin,ymax],handles.meanvcor,[0,1])
    else
        fig=ones(size(handles.meanvcor));
        for x = (1:size(handles.meanvcor,1))
            for y = (1:size(handles.meanvcor,2))
                if ~isnan(handles.meanvcor(x,y))
                    fig(x,y)=1-handles.meanvcor(x,y);
                end
            end
        end
        imagesc([tmin,tmax],[ymin,ymax],fig,[0.3,1])   
    end
end
if and(handles.analysis, handles.analysisdisplay)
    plot(meanv1,c1);
    if size(nm2,2)>0
        plot(meanv2,c2)
    end
    ylabel('mean vel','FontSize',fsize); set(gca,'FontSize',fsize);
end
if and(handles.stat, handles.statdisplay)
    plot((tmin:(tmax-tmin)/20:tmax),ones(1,21)*handles.meanv.mean,s1)
    plot([tmin tmax],[handles.meanv.mean-1*handles.meanv.stdp handles.meanv.mean-1*handles.meanv.stdp],s2)
    plot([tmin tmax],[handles.meanv.mean+1*handles.meanv.stdp handles.meanv.mean+1*handles.meanv.stdp],s2)
end
axis tight

axes(handles.axes35)
cla
hold on
if and(handles.cor, handles.cordisplay)
    ymin = min([handles.ac1;handles.ac2]);
    ymax = max([handles.ac1;handles.ac2]);
    if and(handles.stat, handles.statdisplay)
        ymin = min([ymin;handles.ac.mean-1*handles.ac.stdp]);
        ymax = max([ymax;handles.ac.mean+1*handles.ac.stdp]);
    end
    if handles.color
        imagesc([tmin,tmax],[ymin,ymax],handles.accor,[0,1])
    else
        fig=ones(size(handles.accor));
        for x = (1:size(handles.accor,1))
            for y = (1:size(handles.accor,2))
                if ~isnan(handles.accor(x,y))
                    fig(x,y)=1-handles.accor(x,y);
                end
            end
        end
        imagesc([tmin,tmax],[ymin,ymax],fig,[0.3,1])   
    end
end
if and(handles.analysis, handles.analysisdisplay)
    plot(ac1,c1);
    if size(nm2,2)>0
        plot(ac2,c2)
    end
    ylabel('pulseclar','FontSize',fsize); set(gca,'FontSize',fsize);
end
if and(handles.stat, handles.statdisplay)
    plot((tmin:(tmax-tmin)/20:tmax),ones(1,21)*handles.ac.mean,s1)
    plot([tmin tmax],[handles.ac.mean-1*handles.ac.stdp handles.ac.mean-1*handles.ac.stdp],s2)
    plot([tmin tmax],[handles.ac.mean+1*handles.ac.stdp handles.ac.mean+1*handles.ac.stdp],s2)
end
axis tight

axes(handles.axes36)
cla
hold on
if and(handles.cor, handles.cordisplay)
    ymin = min([handles.ton1;handles.ton2]);
    ymax = max([handles.ton1;handles.ton2]);
    if and(handles.stat, handles.statdisplay)
        ymin = min([ymin;handles.ton.mean-1*handles.ton.stdp]);
        ymax = max([ymax;handles.ton.mean+1*handles.ton.stdp]);
    end
    if handles.color
        imagesc([tmin,tmax],[ymin,ymax],handles.toncor,[0,1])
    else
        fig=ones(size(handles.toncor));
        for x = (1:size(handles.toncor,1))
            for y = (1:size(handles.toncor,2))
                if ~isnan(handles.toncor(x,y))
                    fig(x,y)=1-handles.denscor(x,y);
                end
            end
        end
        imagesc([tmin,tmax],[ymin,ymax],fig,[0.3,1])   
    end
end
if and(handles.analysis, handles.analysisdisplay)
    plot(ton1,c1);
    if size(nm2,2)>0
        plot(ton2,c2)
    end
    ylabel('tonality','FontSize',fsize); set(gca,'FontSize',fsize);
end
if and(handles.stat, handles.statdisplay)
    plot((tmin:(tmax-tmin)/20:tmax),ones(1,21)*handles.ton.mean,s1)
    plot([tmin tmax],[handles.ton.mean-1*handles.ton.stdp handles.ton.mean-1*handles.ton.stdp],s2)
    plot([tmin tmax],[handles.ton.mean+1*handles.ton.stdp handles.ton.mean+1*handles.ton.stdp],s2)
end
axis tight

axes(handles.axes37)
cla
hold on
if and(handles.cor, handles.cordisplay)
    ymin = min([handles.art1;handles.art2]);
    ymax = max([handles.art1;handles.art2]);
    if and(handles.stat, handles.statdisplay)
        ymin = min([ymin;handles.art.mean-1*handles.art.stdp]);
        ymax = max([ymax;handles.art.mean+1*handles.art.stdp]);
    end
    if handles.color
        imagesc([tmin,tmax],[ymin,ymax],handles.artcor,[0,1])
    else
        fig=ones(size(handles.artcor));
        for x = (1:size(handles.artcor,1))
            for y = (1:size(handles.artcor,2))
                if ~isnan(handles.artcor(x,y))
                    fig(x,y)=1-handles.artcor(x,y);
                end
            end
        end
        imagesc([tmin,tmax],[ymin,ymax],fig,[0.3,1])   
    end
end
if and(handles.analysis, handles.analysisdisplay)
    plot(art1,c1);
    if size(nm2,2)>0
        plot(art2,c2)
    end
    ylabel('articulation','FontSize',fsize); set(gca,'FontSize',fsize);
end
if and(handles.stat, handles.statdisplay)
    plot((tmin:(tmax-tmin)/20:tmax),ones(1,21)*handles.art.mean,s1)
    plot([tmin tmax],[handles.art.mean-1*handles.art.stdp handles.art.mean-1*handles.art.stdp],s2)
    plot([tmin tmax],[handles.art.mean+1*handles.art.stdp handles.art.mean+1*handles.art.stdp],s2)
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


% --- Executes on button press in loadstat.
function loadstat_Callback(hObject, eventdata, handles)
% hObject    handle to loadstat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uigetfile({'*.stat','impro statistic files (*.stat)'}, 'Pick a statistic file');
if (not(file==0))
    cd(path)
    handles.statfile = load('-ascii',file);
    stat = handles.statfile(2:end,:);
    if (size(stat,1)==16)
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
        handles.statsize=size(stat,2);
        set(handles.statname,'String',file);
        guidata(hObject, handles);
        displayfig(handles);
    end
end


% --- Executes on button press in statdisplay.
function statdisplay_Callback(hObject, eventdata, handles)
% hObject    handle to statdisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of statdisplay

if (get(hObject,'Value') == get(hObject,'Max'))
    handles.statdisplay=1;
    guidata(hObject, handles);
    displayfig(handles);
else
    handles.statdisplay=0;
    guidata(hObject, handles);
    displayfig(handles);
end


% --- Executes on button press in analysisdisplay.
function analysisdisplay_Callback(hObject, eventdata, handles)
% hObject    handle to analysisdisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of analysisdisplay

if (get(hObject,'Value') == get(hObject,'Max'))
    handles.analysisdisplay=1;
    guidata(hObject, handles);
    displayfig(handles);
else
    handles.analysisdisplay=0;
    guidata(hObject, handles);
    displayfig(handles);
end


% --- Executes on button press in computebutton.
function computebutton_Callback(hObject, eventdata, handles)
% hObject    handle to computebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if and(handles.analysis,size(handles.nm2,2)>0)
    cor = handles.corcoef;
    step = handles.step;
    handles.denscor = crosscors(handles.dens1',handles.dens2',cor,floor(cor*step));
    handles.durcor = crosscors(handles.dur1',handles.dur2',cor,floor(cor*step));
    handles.meanpcor = crosscors(handles.meanp1',handles.meanp2',cor,floor(cor*step));
    handles.stdpcor = crosscors(handles.stdp1',handles.stdp2',cor,floor(cor*step));
    handles.meanvcor = crosscors(handles.meanv1',handles.meanv2',cor,floor(cor*step));
    handles.accor = crosscors(handles.ac1',handles.ac2',cor,floor(cor*step));
    handles.toncor = crosscors(handles.ton1',handles.ton2',cor,floor(cor*step));
    handles.artcor = crosscors(handles.art1',handles.art2',cor,floor(cor*step));
    handles.cor = 1;
    guidata(hObject, handles);
    displayfig(handles);
end

% --- Executes on button press in computedisplay.
function computedisplay_Callback(hObject, eventdata, handles)
% hObject    handle to computedisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of computedisplay

if (get(hObject,'Value') == get(hObject,'Max'))
    handles.cordisplay=1;
    guidata(hObject, handles);
    displayfig(handles);
else
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


% --- Executes on button press in savebutton.
function savebutton_Callback(hObject, eventdata, handles)
% hObject    handle to savebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uiputfile({'*.tif','TIF image (*.tif)'}, 'Save the analysis as',handles.file);
%;'*.jpg','JPEG image (*.jpg)';'.bmp','BITMAP file (*.bmp)';'.eps','EPS file (*.eps)'
if (not(file==0))
    cd(path)
    saveas(gcf,file);
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

%'called'
%get(hObject,'Value')
%get(hObject,'Selected')
value = get(hObject,'Value')
handles.tmin = compute_position(get(hObject,'Value'), handles.tmin, handles.tmax, handles.delta);
value
handles.analysis = 0;
value
handles.cor = 0;
value
display_pianoroll(hObject, handles);
value
guidata(hObject, handles);
value
if handles.tmin > 0
    set(hObject,'Value',handles.delta);
end
value


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
handles.analysis = 0;
handles.cor = 0;
guidata(hObject, handles);
display_pianoroll(hObject, handles);
if handles.tmax < 1
    set(hObject,'Value',1-handles.delta);
end
guidata(hObject, handles);


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


% --- Executes on button press in updatebutton.
function updatebutton_Callback(hObject, eventdata, handles)
% hObject    handle to updatebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

statname=get(handles.statname,'String');
if strcmp(statname,'No stat loaded')
    statname='unnamed.stat';
end
[file,path] = uiputfile({'*.stat','impro statistic files (*.stat)'},'Save the updated statistics of the first player',statname);

if and(handles.analysis,not(file==0))
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