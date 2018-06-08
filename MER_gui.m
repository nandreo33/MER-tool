function varargout = MER_gui(varargin)
% MER_GUI MATLAB code for MER_gui.fig
%      MER_GUI, by itself, creates a new MER_GUI or raises the existing
%      singleton*.
%
%      H = MER_GUI returns the handle to a new MER_GUI or the handle to
%      the existing singleton*.
%
%      MER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MER_GUI.M with the given input arguments.
%
%      MER_GUI('Property','Value',...) creates a new MER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MER_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MER_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MER_gui

% Last Modified by GUIDE v2.5 27-May-2018 22:47:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MER_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @MER_gui_OutputFcn, ...
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


% --- Executes just before MER_gui is made visible.
function MER_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MER_gui (see VARARGIN)

% Choose default command line output for MER_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

status = mer_to_xls_setup();
if ~status
    msgbox('Setup failure', 'Error','error');
    error('setup failure')
end

% UIWAIT makes MER_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MER_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in crw_button.
function dbs_button_Callback(hObject, eventdata, handles)
% hObject    handle to cbs_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [file,path] = uigetfile({'*.dbs';'*.mat'},'DBS File Selection','C:\');
    if file ~= 0
        set(handles.dbs_disp,'String',[path file]);
    end

% --- Executes on button press in dbs_button.
function crw_button_Callback(hObject, eventdata, handles)
% hObject    handle to crw_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [file,path] = uigetfile({'*.crw'},'CRW File Selection','C:\');
    if file ~= 0
        set(handles.crw_disp,'String',[path file]);
    end
        
% --- Executes on button press in folder_button.
function folder_button_Callback(hObject, eventdata, handles)
% hObject    handle to folder_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    path = uigetdir('Data Folder Selection','APM Folder Selection');
    if path ~= 0
        set(handles.apm_disp,'String',path);
    end

% --- Executes on button press in change_dir_button.
function change_dir_button_Callback(hObject, eventdata, handles)
% hObject    handle to change_dir_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % open folder selection prompt, and save selection in destination_disp
    [file,path,indx] = uiputfile({'*.xls';'*.xlsx'},'Destination Selection','C:\');
    if file ~= 0
        set(handles.destination_disp,'String',[path file]);
    end

% --- Executes on button press in convert_button.
function convert_button_Callback(hObject, eventdata, handles)
% hObject    handle to convert_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % if no destination selected, throw error
    if strcmp(get(handles.destination_disp,'String'),'...')
        msgbox('You must set an output destination', 'Error','error');
        return
    end
    % if no files selected, throw error
    if strcmp(get(handles.dbs_disp,'String'),'...') || strcmp(get(handles.crw_disp,'String'),'...')
        msgbox('You must select files to convert', 'Error','error');
        return
    end
    % toggle buttons off during conversion
    toggle_buttons('off',handles);
    % get data files and output destination
    dbs = get(handles.dbs_disp, 'String');
    crw = get(handles.crw_disp, 'String');
    apm = get(handles.apm_disp, 'String');
    dest = get(handles.destination_disp,'String');
    % being conversion with those files/destination as arguments
    [status,comment] = begin_conversion(dbs,crw,apm,dest);
    if status
        msgbox('Conversion complete', 'Success')
    else
        msgbox(['Conversion was unsuccessful' newline newline 'Reason:' newline comment], 'Error','error');
    end
    
    
function toggle_buttons(state,handles)
    % change all button states
    set(handles.dbs_button,'enable',state);
    set(handles.crw_button,'enable',state);
    set(handles.change_dir_button,'enable',state);
    set(handles.folder_button,'enable',state);
    set(handles.convert_button,'enable',state);
    
function [status,comment] = begin_conversion(dbs,crw,apm,dest)
    % load Headers
    load('data\Headers.mat','Headers');
    % create File struct pointing to dest
    [path,name,ext] = fileparts(dest);
    File = struct('path',path,'name',name,'type',ext,'full',dest);
    % load DbsData
    [path,name,ext] = fileparts(dbs);
    if ext == '.dbs'
        copyfile(dbs,[path '\' name '.mat']);
    end
    DbsData = load([path '\' name '.mat']);
    % load CrwData
    if ext == '.txt'
        copyfile(crw,[path '\' name '.crw']);
    end
    CrwData = extract_crw_data(crw);
    
    [status,comment] = mer_to_xls(Headers,DbsData,CrwData,File);
    
    close(MER_gui)
    MER_plot(CrwData,DbsData,apm);
