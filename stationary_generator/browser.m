function varargout = browser(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @browser_OpeningFcn, ...
                   'gui_OutputFcn',  @browser_OutputFcn, ...
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
function browser_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
set(handles.origin,'visible','off');
set(handles.save,'visible','off');
function varargout = browser_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;
movegui(gcf,'center');
function pong_Callback(~, ~, handles)
try
[fname, pname]  = uigetfile({'*.csv*'},'File Selcetor');
filename = fullfile(pname, fname);
assert(exist(filename,'file')==2, '%s does not exist.', filename);
data = csvread(filename,1,0);
namefile = get(handles.nameinput,'string');
dlmwrite(['../data/' char(namefile) '.csv'], data);
locate = ['.../data/' char(namefile) '.csv'];
set(handles.locate,'String',locate);
set(handles.path,'String',filename);
set(handles.origin,'visible','on');
set(handles.save,'visible','on');
h=msgbox({'File uploaded succesfully','Let upload another file'});
th = findall(h, 'Type', 'Text');                 
th.FontSize = 10;
deltaWidth = sum(th.Extent([1,3]))-h.Position(3) + th.Extent(1);
deltaHeight = sum(th.Extent([2,4]))-h.Position(4) + 10;
h.Position([3,4]) = h.Position([3,4]) + [deltaWidth, deltaHeight];
h.Resize = 'off';
catch
msgbox('Only CSV format is accepted');
end
function done_Callback(~, ~, ~)
delete(gcf);
input;
function path_CreateFcn(~, ~, ~)
function nameinput_Callback(~, ~, ~)
