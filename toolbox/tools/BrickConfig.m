function varargout = BrickConfig(varargin)
% BRICKCONFIG MATLAB code for BrickConfig.fig
%      BRICKCONFIG, by itself, creates a new BRICKCONFIG or raises the existing
%      singleton*.
%
%      H = BRICKCONFIG returns the handle to a new BRICKCONFIG or the handle to
%      the existing singleton*.
%
%      BRICKCONFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BRICKCONFIG.M with the given input arguments.
%
%      BRICKCONFIG('Property','Value',...) creates a new BRICKCONFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BrickConfig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BrickConfig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BrickConfig

% Last Modified by GUIDE v2.5 04-Nov-2016 11:21:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BrickConfig_OpeningFcn, ...
                   'gui_OutputFcn',  @BrickConfig_OutputFcn, ...
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


% --- Executes just before BrickConfig is made visible.
function BrickConfig_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BrickConfig (see VARARGIN)

% Open connection
[handles.brick, succ] = connect();
if ~succ
    handles.connected = false;
else
    handles.connected = true;
    updateFigures(handles);
    
    t = timer;
    t.TimerFcn = @updateFigures;
    t.Period = 2;
    t.StartDelay = 2;
    t.ExecutionMode = 'fixedSpacing';
    
    handles.timer = t;
end

% Choose default command line output for BrickConfig
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BrickConfig wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BrickConfig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
if ~handles.connected
      figure1_CloseRequestFcn(hObject, eventdata, handles);
end


% --- Executes on button press in pushbutton_close.
function pushbutton_close_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure1_CloseRequestFcn(gcbf, eventdata, handles)


% --- Executes on button press in pushbutton_rename.
function pushbutton_rename_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
b = handles.brick;
if ~(isa(b, 'CommunicationInterface') && b.isvalid)
    return;
end

answer = inputdlg('Enter Brick name:', 'Rename Brick');
if ~isempty(answer)
    b.comSetBrickName(answer{:});
    updateFigures(handles);
end

msgbox(['Renaming will be only be fully effective after ', ...
        'executing the btconnect-script with the old name once!']);
figure1_CloseRequestFcn(gcbf, eventdata, handles)
    
function [b, succ] = connect()
succ = false;
b = 0;

l =  {'USB', 'Bluetooth: rfcomm0', 'Bluetooth: rfcomm1', 'Bluetooth: rfcomm2'};
[selection, ok] = listdlg('PromptString', 'Select your connection:', ...
                          'SelectionMode', 'single', ...
                          'Name', 'Connection', ...
                          'ListString', l);

if ok
    try 
        switch selection
            case 1
                b = CommunicationInterface('usb');
            case 2
                b = CommunicationInterface('bt', 'serPort', '/dev/rfcomm0');
            case 3 
                b = CommunicationInterface('bt', 'serPort', '/dev/rfcomm1');
            case 4
                b = CommunicationInterface('bt', 'serPort', '/dev/rfcomm2');
        end
        succ = true;
    catch ME
        errordlg('Failed to connect to the Brick!', 'Connection Error');
    end
end
      
return;


function updateFigures(handles)
if handles.connected
    set(handles.text_name, 'String', handles.brick.comGetBrickName());
    set(handles.text_mac, 'String', handles.brick.comGetBTID());
    set(handles.text_charge, 'String', strcat(int2str(handles.brick.uiReadLbatt()),'%'));
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if handles.connected
      handles.brick.delete();
end

delete(hObject);
