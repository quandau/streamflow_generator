function varargout = modaldlg(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @modaldlg_OpeningFcn, ...
                   'gui_OutputFcn',  @modaldlg_OutputFcn, ...
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

function modaldlg_OpeningFcn(hObject, ~, handles, varargin)
load('para.mat');
set(handles.gene,'String',realisation(:,1));
set(handles.yrs,'String',years(:,1));
if years <= 50
    note = 'The process would take about 5-10 minutes';
elseif years >50 && years <= 500
note = 'The process would take about 30-50 minutes';
else years > 6500
    note = 'Your selection is too high. The process would take about 1-2hours';
end
set(handles.note,'String',note);
handles.output = 'Yes';
guidata(hObject, handles);
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
load dialogicons.mat
IconData=questIconData;
questIconMap(256,:) = get(handles.figure1, 'Color');
IconCMap=questIconMap;

Img=image(IconData, 'Parent', handles.axes1);
set(handles.figure1, 'Colormap', IconCMap);

set(handles.axes1, ...
    'Visible', 'off', ...
    'YDir'   , 'reverse'       , ...
    'XLim'   , get(Img,'XData'), ...
    'YLim'   , get(Img,'YData')  ...
    );
set(handles.figure1,'WindowStyle','modal')
uiwait(handles.figure1);


function varargout = modaldlg_OutputFcn(~, ~, handles)
varargout{1} = handles.output;
delete(handles.figure1);


function pushbutton1_Callback(hObject, ~, handles)
handles.output = get(hObject,'String');
guidata(hObject, handles);
uiresume(handles.figure1);
function pushbutton2_Callback(hObject, ~, handles)
handles.output = get(hObject,'String');
guidata(hObject, handles);
uiresume(handles.figure1);
function figure1_CloseRequestFcn(hObject, ~, ~)
if isequal(get(hObject, 'waitstatus'), 'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

function figure1_KeyPressFcn(hObject, ~, handles)
if isequal(get(hObject,'CurrentKey'),'escape')
    handles.output = 'No';
    guidata(hObject, handles); 
    uiresume(handles.figure1);
end    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end    
function yrs_CreateFcn(~, ~, ~)
function gene_CreateFcn(~, ~, ~)
function note_CreateFcn(~, ~, ~)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
