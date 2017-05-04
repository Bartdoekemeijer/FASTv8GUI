%% Initialization code
function varargout = Certification(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Certification_OpeningFcn, ...
                   'gui_OutputFcn',  @Certification_OutputFcn, ...
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

%% Opening function
function Certification_OpeningFcn(hObject, eventdata, handles, varargin)

% Set background image
h = axes('Units', 'Normalized', 'position', [0 0 1 1]);
uistack(h, 'bottom');
img = imread('graphics\certification.png');
imagesc(img);
set(h, 'HandleVisibility', 'off', 'visible','off')

% Get input
handles.Blade = varargin{1};
handles.Airfoil = varargin{2};
handles.Tower = varargin{3};
handles.Nacelle = varargin{4};
handles.Drivetrain = varargin{5};
handles.Control = varargin{6};
handles.CertificationSettings = varargin{7};
handles.LinModel = varargin{8};

% Update input fields
set(handles.Runtime_textbox, 'String', num2str(handles.CertificationSettings.Run.Time));
U = num2str(handles.CertificationSettings.Run.WindSpeed(1));
if length(handles.CertificationSettings.Run.WindSpeed) > 1
    for i = 2:length(handles.CertificationSettings.Run.WindSpeed)
        U = [U, ', ', num2str(handles.CertificationSettings.Run.WindSpeed(i))];
    end
end
set(handles.WindSpeed_textbox, 'String', U);
set(handles.NSeeds_textbox, 'String', num2str(handles.CertificationSettings.Run.Seeds));
handles.OutputFile = {};
set(handles.OutputFiles_text, 'String', '../<empty>')

% Update wind icons
if handles.CertificationSettings.Wind.Type == 1       % Steady wind
    set(handles.WindSettings, 'CData', imread('icons\wind_steady.png'))
    set(handles.WindSettings, 'TooltipString', 'Steady wind')
elseif handles.CertificationSettings.Wind.Type == 2   % Stepped wind
    set(handles.WindSettings, 'CData', imread('icons\wind_step.png'))
    set(handles.WindSettings, 'TooltipString', 'Stepped wind')
elseif handles.CertificationSettings.Wind.Type == 3   % Normal wind profile (NWP)
    set(handles.WindSettings, 'CData', imread('icons\wind_nwp.png'))
    set(handles.WindSettings, 'TooltipString', 'Normal wind profile (NWP)')
elseif handles.CertificationSettings.Wind.Type == 4   % Normal turbulence model (NTM)
    set(handles.WindSettings, 'CData', imread('icons\wind_ntm.png'))
    set(handles.WindSettings, 'TooltipString', 'Normal turbulence model (NTM)')
elseif handles.CertificationSettings.Wind.Type == 5   % Annual extreme wind speed (EWM)
    set(handles.WindSettings, 'CData', imread('icons\wind_ewm1.png'))
    set(handles.WindSettings, 'TooltipString', 'Annual extreme wind speed (EWM)')
elseif handles.CertificationSettings.Wind.Type == 6   % 50-year extreme wind speed (EWM)
    set(handles.WindSettings, 'CData', imread('icons\wind_ewm50.png'))
    set(handles.WindSettings, 'TooltipString', '50-year extreme wind speed (EWM)')
elseif handles.CertificationSettings.Wind.Type == 7   % Extreme wind shear (EWS)
    set(handles.WindSettings, 'CData', imread('icons\wind_ews.png'))
    set(handles.WindSettings, 'TooltipString', 'Extreme wind shear (EWS)')
elseif handles.CertificationSettings.Wind.Type == 8   % Extreme turbulence model (ETM)
    set(handles.WindSettings, 'CData', imread('icons\wind_etm.png'))
    set(handles.WindSettings, 'TooltipString', 'Extreme turbulence model (ETM)')
elseif handles.CertificationSettings.Wind.Type == 9   % Extreme operating gust (EOG)
    set(handles.WindSettings, 'CData', imread('icons\wind_eog.png'))
    set(handles.WindSettings, 'TooltipString', 'Extreme operating gust (EOG)')
elseif handles.CertificationSettings.Wind.Type == 10   % Extreme direction change (EDC)
    set(handles.WindSettings, 'CData', imread('icons\wind_edc.png'))
    set(handles.WindSettings, 'TooltipString', 'Extreme direction change (EDC)')
elseif handles.CertificationSettings.Wind.Type == 11   % Extreme coherent gust (ECD)
    set(handles.WindSettings, 'CData', imread('icons\wind_ecg.png'))
    set(handles.WindSettings, 'TooltipString', 'Extreme coherent gust (ECD)')
end

% Update operations icons
if handles.CertificationSettings.Mode.Type == 1       % Power production
    set(handles.OperationSettings, 'CData', imread('icons\operation_prod.png'))
    set(handles.OperationSettings, 'TooltipString', 'Power production')
elseif handles.CertificationSettings.Mode.Type == 2   % Power production with fault
    set(handles.OperationSettings, 'CData', imread('icons\operation_prodfault.png'))
    set(handles.OperationSettings, 'TooltipString', 'Power production with fault')
elseif handles.CertificationSettings.Mode.Type == 3   % Startup
    set(handles.OperationSettings, 'CData', imread('icons\operation_start.png'))
    set(handles.OperationSettings, 'TooltipString', 'Startup')
elseif handles.CertificationSettings.Mode.Type == 4   % Normal shutdown
    set(handles.OperationSettings, 'CData', imread('icons\operation_shutdown.png'))
    set(handles.OperationSettings, 'TooltipString', 'Normal shutdown')
elseif handles.CertificationSettings.Mode.Type == 5   % Emergency shutdown
    set(handles.OperationSettings, 'CData', imread('icons\operation_emergency.png'))
    set(handles.OperationSettings, 'TooltipString', 'Emergency shutdown')
elseif handles.CertificationSettings.Mode.Type == 6   % Idling
    set(handles.OperationSettings, 'CData', imread('icons\operation_idle.png'))
    set(handles.OperationSettings, 'TooltipString', 'Idling')
elseif handles.CertificationSettings.Mode.Type == 7   % Parked
    set(handles.OperationSettings, 'CData', imread('icons\operation_idle.png'))
    set(handles.OperationSettings, 'TooltipString', 'Parked')
end

% Disable start button
set(handles.Start, 'Enable', 'off')

% Update handles structure
guidata(hObject, handles);

% Halt window
uiwait(handles.Certification);

%% Output function
function varargout = Certification_OutputFcn(hObject, eventdata, handles) 

% Output
varargout{1} = handles.CertificationSettings;

% Close figure
delete(hObject)

%% Closing function
function Certification_CloseRequestFcn(hObject, eventdata, handles)
uiresume(hObject);

%% OK button
function OK_Callback(hObject, eventdata, handles)
uiresume(handles.Certification);

%% WindSettings settings
function WindSettings_Callback(hObject, eventdata, handles)

% Disable window
buttons = findall(handles.Certification, 'Type', 'UIControl');
for i = 1:length(buttons)
    set(buttons(i), 'Enable', 'off');
end

% Operation settings
handles.CertificationSettings = Wind(...
    handles.CertificationSettings, ...
    handles.Blade, ...
    handles.Tower);

% Enable window
for i = 1:length(buttons)
    set(buttons(i), 'Enable', 'on');
end

% Disable start button
if ~exist(handles.LinModel, 'file')
    set(handles.Start, 'Enable', 'off')
else
    contents = whos('-file', handles.LinModel);
    if ~ismember('Lin', {contents.name}) || ~ismember('sysm', {contents.name})
        set(handles.Start, 'Enable', 'off')
    end
end
if isempty(handles.OutputFile)
    set(handles.Start, 'Enable', 'off')
end

% Update icon
if handles.CertificationSettings.Wind.Type == 1       % Steady wind
    set(hObject, 'CData', imread('icons\wind_steady.png'))
    set(hObject, 'TooltipString', 'Steady wind')
elseif handles.CertificationSettings.Wind.Type == 2   % Stepped wind
    set(hObject, 'CData', imread('icons\wind_step.png'))
    set(hObject, 'TooltipString', 'Stepped wind')
elseif handles.CertificationSettings.Wind.Type == 3   % Normal wind profile (NWP)
    set(hObject, 'CData', imread('icons\wind_nwp.png'))
    set(hObject, 'TooltipString', 'Normal wind profile (NWP)')
elseif handles.CertificationSettings.Wind.Type == 4   % Normal turbulence model (NTM)
    set(hObject, 'CData', imread('icons\wind_ntm.png'))
    set(hObject, 'TooltipString', 'Normal turbulence model (NTM)')
elseif handles.CertificationSettings.Wind.Type == 5   % Annual extreme wind speed (EWM)
    set(hObject, 'CData', imread('icons\wind_ewm1.png'))
    set(hObject, 'TooltipString', 'Annual extreme wind speed (EWM)')
elseif handles.CertificationSettings.Wind.Type == 6   % 50-year extreme wind speed (EWM)
    set(hObject, 'CData', imread('icons\wind_ewm50.png'))
    set(hObject, 'TooltipString', '50-year extreme wind speed (EWM)')
elseif handles.CertificationSettings.Wind.Type == 7   % Extreme wind shear (EWS)
    set(hObject, 'CData', imread('icons\wind_ews.png'))
    set(hObject, 'TooltipString', 'Extreme wind shear (EWS)')
elseif handles.CertificationSettings.Wind.Type == 8   % Extreme turbulence model (ETM)
    set(hObject, 'CData', imread('icons\wind_etm.png'))
    set(hObject, 'TooltipString', 'Extreme turbulence model (ETM)')
elseif handles.CertificationSettings.Wind.Type == 9   % Extreme operating gust (EOG)
    set(hObject, 'CData', imread('icons\wind_eog.png'))
    set(hObject, 'TooltipString', 'Extreme operating gust (EOG)')
elseif handles.CertificationSettings.Wind.Type == 10   % Extreme direction change (EDC)
    set(hObject, 'CData', imread('icons\wind_edc.png'))
    set(hObject, 'TooltipString', 'Extreme direction change (EDC)')
elseif handles.CertificationSettings.Wind.Type == 11   % Extreme coherent gust (ECD)
    set(hObject, 'CData', imread('icons\wind_ecg.png'))
    set(hObject, 'TooltipString', 'Extreme coherent gust (ECD)')
end

% Update handles structure
guidata(hObject, handles);

%% Operation settings
function OperationSettings_Callback(hObject, eventdata, handles)

% Disable window
buttons = findall(handles.Certification, 'Type', 'UIControl');
for i = 1:length(buttons)
    set(buttons(i), 'Enable', 'off');
end

% Operation settings
handles.CertificationSettings = Operation(...
    handles.CertificationSettings);

% Enable window
for i = 1:length(buttons)
    set(buttons(i), 'Enable', 'on');
end

% Disable start button
if ~exist(handles.LinModel, 'file')
    set(handles.Start, 'Enable', 'off')
else
    contents = whos('-file', handles.LinModel);
    if ~ismember('Lin', {contents.name}) || ~ismember('sysm', {contents.name})
        set(handles.Start, 'Enable', 'off')
    end
end
if isempty(handles.OutputFile)
    set(handles.Start, 'Enable', 'off')
end

% Update icon
if handles.CertificationSettings.Mode.Type == 1       % Power production
    set(hObject, 'CData', imread('icons\operation_prod.png'))
    set(hObject, 'TooltipString', 'Power production')
elseif handles.CertificationSettings.Mode.Type == 2   % Power production with fault
    set(hObject, 'CData', imread('icons\operation_prodfault.png'))
    set(hObject, 'TooltipString', 'Power production with fault')
elseif handles.CertificationSettings.Mode.Type == 3   % Startup
    set(hObject, 'CData', imread('icons\operation_start.png'))
    set(hObject, 'TooltipString', 'Startup')
elseif handles.CertificationSettings.Mode.Type == 4   % Normal shutdown
    set(hObject, 'CData', imread('icons\operation_shutdown.png'))
    set(hObject, 'TooltipString', 'Normal shutdown')
elseif handles.CertificationSettings.Mode.Type == 5   % Emergency shutdown
    set(hObject, 'CData', imread('icons\operation_emergency.png'))
    set(hObject, 'TooltipString', 'Emergency shutdown')
elseif handles.CertificationSettings.Mode.Type == 6   % Idling
    set(hObject, 'CData', imread('icons\operation_idle.png'))
    set(hObject, 'TooltipString', 'Idling')
elseif handles.CertificationSettings.Mode.Type == 7   % Parked
    set(hObject, 'CData', imread('icons\operation_idle.png'))
    set(hObject, 'TooltipString', 'Parked')
end

% Update handles structure
guidata(hObject, handles);

%% Open Simulink interface
function Simulink_Callback(hObject, eventdata, handles)
open_system('FAST')

%% View output signals
function Output_Callback(hObject, eventdata, handles)
load_system('FAST')
open_system('FAST/Scope')

%% Wind speed range - text box
function WindSpeed_textbox_Callback(hObject, eventdata, handles)
eval(['U = [', get(hObject, 'String'), '];']);
if min(U) < 0
    set(hObject, 'String', '0')
elseif sum(isnan(U)) > 0
    set(hObject, 'String', num2str(handles.CertificationSettings.Run.WindSpeed))
elseif isempty(isnan(U))
    set(hObject, 'String', num2str(handles.CertificationSettings.Run.WindSpeed))
end
handles.CertificationSettings.Run.WindSpeed = U;
guidata(hObject, handles);
UpdateOutputName(handles);
function WindSpeed_textbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Seed number - text box
function NSeeds_textbox_Callback(hObject, eventdata, handles)
if str2double(get(hObject,'String')) < 0
    set(hObject, 'String', '0')
elseif isnan(str2double(get(hObject,'String')))
    set(hObject, 'String', num2str(handles.CertificationSettings.Run.Seeds))
end
handles.CertificationSettings.Run.Seeds = ceil(str2double(get(hObject,'String')));
guidata(hObject, handles);
UpdateOutputName(handles);
function NSeeds_textbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Simulation runtime - text box
function Runtime_textbox_Callback(hObject, eventdata, handles)
if str2double(get(hObject,'String')) < 0
    set(hObject, 'String', '0')
elseif isnan(str2double(get(hObject,'String')))
    set(hObject, 'String', num2str(handles.CertificationSettings.Run.Time))
end
handles.CertificationSettings.Run.Time = str2double(get(hObject,'String'));
guidata(hObject, handles);
function Runtime_textbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Set output file name
function SetOutputName_Callback(hObject, eventdata, handles)
[FileName,PathName] = uiputfile('*.mat', 'Set output file name(s)');
if FileName
    
    % Store in handles
    handles.OutputFile = {PathName, FileName(1:end-4)};
    guidata(hObject, handles);
    
    % Update output file names
    UpdateOutputName(handles);
    
    % Enable start button if linearized model is available
    if handles.LinModel
        if exist(handles.LinModel, 'file') == 2
            contents = whos('-file', handles.LinModel);
            if ismember('Lin', {contents.name}) && ismember('sysm', {contents.name})
                set(handles.Start, 'Enable', 'on')
            end
        end
    end
    
end

%% Update output file names
function UpdateOutputName(handles)

if ~isempty(handles.OutputFile)

i = 1;
if length(handles.CertificationSettings.Run.WindSpeed) * handles.CertificationSettings.Run.Seeds <= 4
    for U = handles.CertificationSettings.Run.WindSpeed
        for seed  = 1:handles.CertificationSettings.Run.Seeds

            OutputFile = ['../', handles.OutputFile{2}];
            if length(handles.CertificationSettings.Run.WindSpeed) > 1
                OutputFile = [OutputFile, '_U=', num2str(U,'%2.2f')];
            end
            if handles.CertificationSettings.Run.Seeds > 1
                OutputFile = [OutputFile, '_seed=', int2str(seed)];
            end
            OutputFiles{i} = [OutputFile, '.mat'];
            i = i + 1;

        end
    end
else
    for U = handles.CertificationSettings.Run.WindSpeed
        for seed  = 1:handles.CertificationSettings.Run.Seeds

            OutputFile = ['../', handles.OutputFile{2}];
            if length(handles.CertificationSettings.Run.WindSpeed) > 1
                OutputFile = [OutputFile, '_U=', num2str(U,'%2.2f')];
            end
            if handles.CertificationSettings.Run.Seeds > 1
                OutputFile = [OutputFile, '_seed=', int2str(seed)];
            end
            OutputFiles{i} = [OutputFile, '.mat'];
            i = i + 1;

            if i == 3
                break
            end

        end

        if i == 3
            break
        end
    end

    OutputFiles{3} = '  ...';
    OutputFile = ['../', handles.OutputFile{2}];
    if length(handles.CertificationSettings.Run.WindSpeed) > 1
        OutputFile = [OutputFile, '_U=', num2str(handles.CertificationSettings.Run.WindSpeed(end),'%2.2f')];
    end
    if handles.CertificationSettings.Run.Seeds > 1
        OutputFile = [OutputFile, '_seed=', int2str(handles.CertificationSettings.Run.Seeds)];
    end
    OutputFiles{4} = [OutputFile, '.mat'];

end

set(handles.OutputFiles_text, 'String', OutputFiles)

end

%% Start simulation
function Start_Callback(hObject, eventdata, handles)

% Set output filename
if isempty(handles.OutputFile)
    handles.OutputFile = [pwd, '\output'];
end

% Temporarily turn off warnings
warning('off','all')

RunCertification(handles, [], false);

% Turn on warnings
warning('on','all')
disp('')
disp('Completed!')
