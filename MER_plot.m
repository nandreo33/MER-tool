function varargout = MER_plot(varargin)
% MER_PLOT MATLAB code for MER_plot.fig
%      MER_PLOT, by itself, creates a new MER_PLOT or raises the existing
%      singleton*.
%
%      H = MER_PLOT returns the handle to a new MER_PLOT or the handle to
%      the existing singleton*.
%
%      MER_PLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MER_PLOT.M with the given input arguments.
%
%      MER_PLOT('Property','Value',...) creates a new MER_PLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MER_plot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MER_plot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MER_plot

% Last Modified by GUIDE v2.5 31-May-2018 13:09:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MER_plot_OpeningFcn, ...
                   'gui_OutputFcn',  @MER_plot_OutputFcn, ...
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


% --- Executes just before MER_plot is made visible.
function MER_plot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MER_plot (see VARARGIN)

% Choose default command line output for MER_plot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

CrwData = varargin{1};
DbsData = varargin{2};
apmPath = varargin{3};

daH = handles.disp_axes;

% plot APM data

ApmDataTable = build_apm_table(CrwData,DbsData,apmPath);

setappdata(hObject,'ApmDataTable',ApmDataTable);
setappdata(hObject,'apmPath',apmPath);
setappdata(hObject,'CrwData',CrwData);
setappdata(hObject,'DbsData',DbsData);

taH = handles.traj_axes;
hold(taH,'on');
lH(1) = plot3(taH,ApmDataTable.lt,ApmDataTable.ap,ApmDataTable.ax,'-s');
set(lH(1),'hittest','off');
set(taH,'ButtonDownFcn',@get_point_coord);

% TODO why does this need to be here?
set(gca,'Tag','disp_axes');

get(hObject,'children')

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes MER_plot wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MER_plot_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in rotate_button.
function rotate_button_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(hObject,'Value');
if val
    rotate3d(handles.traj_axes,'on');
elseif ~val
    rotate3d(handles.traj_axes,'off');
end


% --- Executes on button press in zoom_button.
function zoom_button_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zoom_button
val = get(hObject,'Value');
if val
    zoom(handles.traj_axes,'on');
elseif ~val
    zoom(handles.traj_axes,'off');
end

function get_point_coord(aH,event)
    DISTANCE_THRESHOLD = 200;
    f = ancestor(aH,'figure');
    ptH = getappdata(aH,'CurrentSelection');
    lH = findobj(aH,'Type','line');
    pt = get(aH,'CurrentPoint');
    
%     plot3(aH,pt(:,1),pt(:,2),pt(:,3),'-r')
    
    lPts = [lH.XData;lH.YData;lH.ZData]';
    v1 = pt(1,:);
    v2 = pt(2,:);
    v1 = repmat(v1,size(lPts,1),1);
    v2 = repmat(v2,size(lPts,1),1);    a = v1 - v2;
    b = lPts - v2;
    d = sqrt(sum(cross(a,b,2).^2,2)) ./ sqrt(sum(a.^2,2));
    [m,iClose] = min(d);
    
    if m < DISTANCE_THRESHOLD
        x = lPts(iClose,1);
        y = lPts(iClose,2);
        z = lPts(iClose,3);
        delete(ptH);
        axes(aH);
        ptH = plot3(aH,x,y,z,'rx');
        setappdata(aH,'CurrentSelection',ptH);
        set(gca,'Tag','traj_axes');
        
        daH = findobj(f,'Tag','disp_axes');
        axes(daH);        
        ApmDataTable = getappdata(f,'ApmDataTable');
        % TODO make this better?
        for i = 1:length(ApmDataTable.lt)
            if (x == ApmDataTable.lt(i) && y == ApmDataTable.ap(i) && z == ApmDataTable.ax(i))
%                     xlim(daH,[ApmDataTable(i).start ApmDataTable(i).end])
                    
                    t = APMReadData([apm '\GPi Left\Pass 1\C\Snapshot - 3600.0 sec ' num2str(i) '\WaveformData-Ch1.apm']);
                    dist = t.drive_data.depth;
                    channel = t.channels(1);
                    FS = channel.sampling_frequency;
                    data = channel.continuous * channel.voltage_calibration;
                    start_trial = channel.start_trial;
                    time = (start_trial:(length(data)+start_trial-1))/FS;
                    disp(dist)
                    disp(ApmDataTable.depth(i))
                    plot(daH,time,data)
                    
                    depthH = findobj(f,'Tag','depth_disp');
                    set(depthH,'String',['Depth = ' num2str(ApmDataTable.depth(i)) 'um']);
                
                break
            end
        end      
        
        set(gca,'Tag','disp_axes');
    end
    
