function RunCertification(handles, saveFilePath, saveOnly)
% Get turbine geometry from handles
Blade = handles.Blade;
Airfoil = handles.Airfoil;
Tower = handles.Tower;
Nacelle = handles.Nacelle;
Drivetrain = handles.Drivetrain;
Control = handles.Control;
CertificationSettings = handles.CertificationSettings;

% Get turbine appearance
if saveOnly
    Appearance = [...
        get(handles.Landscape, 'Value');
        get(handles.BladeStyle, 'Value');
        get(handles.BladeColor, 'Value');
        get(handles.TowerStyle, 'Value');
        get(handles.TowerColor, 'Value')];
end

disp('Preparing input files...')

% Run BModes for tower
evalc([...
    '[y11_shape, y11_coeff, y11_freq,', ...
    ' y12_shape, y12_coeff, y12_freq,', ...
    ' y21_shape, y21_coeff, y21_freq,', ...
    ' y22_shape, y22_coeff, y22_freq] = BModes(Blade,Tower,Nacelle,Control,2,0);']);

% Store in handles
Tower.ForeAft1_coeff = y21_coeff;
Tower.ForeAft2_coeff = y22_coeff;
Tower.SideSide1_coeff = y11_coeff;
Tower.SideSide2_coeff = y12_coeff;

% Run BModes for blade
evalc([...
    '[y11_shape, y11_coeff, y11_freq,', ...
    ' y12_shape, y12_coeff, y12_freq,', ...
    ' y21_shape, y21_coeff, y21_freq,', ...
    ' y22_shape, y22_coeff, y22_freq] = BModes(Blade,Tower,Nacelle,Control,1,0);']);

% Store in handles
Blade.Flap1_coeff = y11_coeff;
Blade.Flap2_coeff = y12_coeff;
Blade.Edge1_coeff = y21_coeff;
Blade.Edge2_coeff = y22_coeff;

% Load linearized model
if not(exist('Lin', 'var'))
    [tmp_file, tmp_folder] = uigetfile('*.mat', 'Selected the .mat file containing linear wind turbine models');
    load([tmp_folder, tmp_file]); clear tmp_folder tmp_file
end

% Initialize controller
disp('Setting controller parameters...')
assignin('base', 'Drivetrain', Drivetrain)
assignin('base', 'Control', Control)
ControllerDesign(Control);

% Turbine input files
TMax = CertificationSettings.Run.Time;
FASTinput(Control.DT, TMax);
AeroDyn(Blade,Airfoil,Tower,CertificationSettings.Mode.Type);

% Send to base workspace and make structures available for Simulink and run the simulation
assignin('base', 'FAST_InputFileName', [pwd, '\subfunctions\inputfiles\FAST.fst']);
assignin('base', 'TMax', TMax);
assignin('base', 'Lin', Lin);

% Loop over wind speeds and seeds
for U = CertificationSettings.Run.WindSpeed
    for seed = 1:CertificationSettings.Run.Seeds
        
        if not(saveOnly)
            % Output file name
            OutputFile = [handles.OutputFile{1}, handles.OutputFile{2}];
            if length(handles.CertificationSettings.Run.WindSpeed) > 1
                OutputFile = [OutputFile, '_U=', num2str(U,'%2.2f')];
            end
            if handles.CertificationSettings.Run.Seeds > 1
                OutputFile = [OutputFile, '_seed=', int2str(seed)];
            end
            OutputFile = [OutputFile, '.mat'];
        end
        
        % Find initial RPM and pitch angle
        if CertificationSettings.Wind.Type == 2
            Ui = CertificationSettings.Wind.Step;
        else
            Ui = U;
        end
        
        if Ui < Control.WindSpeed.Cutin || Ui > Control.WindSpeed.Cutout
            RPM_Init = 0;
            P_InitAngle = Control.Pitch.Max;
        else
            RPM_Init = (30/pi) * interp1(Lin.V,Lin.RSpeed,Ui,'pchip');
            P_InitAngle = 180/pi * interp1(Lin.V,Lin.Pitch,Ui,'pchip');
        end
        
        if CertificationSettings.Mode.Type == 3     % Startup
            RPM_Init = 0;
            P_InitAngle = Control.Pitch.Max;
        elseif CertificationSettings.Mode.Type == 6 % Idling
            RPM_Init = 0;
            P_InitAngle = Control.Pitch.Max;
        elseif CertificationSettings.Mode.Type == 7	% Parked
            RPM_Init = 0;
            P_InitAngle = Control.Pitch.Max;
        end
        
        assignin('base', 'RPM_Init', RPM_Init);
        assignin('base', 'T_GenSpeedInit', RPM_Init*Drivetrain.Gearbox.Ratio);
        assignin('base', 'P_InitAngle', P_InitAngle);
        
        % Set operation mode in ElastoDyn file
        ElastoDyn(Blade,Tower,Nacelle,Drivetrain,Control,CertificationSettings.Mode.Type,RPM_Init,P_InitAngle);
        
        % Set operation mode in ServoDyn file
        ServoDyn(Drivetrain,Control,CertificationSettings.Mode.Type,CertificationSettings.Mode.Actiontime);
        
        % Wind input file
        disp('Generating wind file...')
        InflowWind(CertificationSettings.Wind,U,Tower.HubHeight,Blade.Radius(end))
        
        % Preload the OutList
        load([pwd '\subfunctions\OutList.mat'])
        assignin('base', 'OutList', OutList);
        assignin('base', 'CertificationSettings', CertificationSettings);
        
        if not(saveOnly)
            % Call Simulink
            disp(['Running FAST (U = ', num2str(U,'%5.2f'), ' m/s, seed ', int2str(seed), '/', int2str(CertificationSettings.Run.Seeds), ')'])
            evalc('sim(''FAST'',TMax);');
            
            % Extract output
            filename = [pwd '\subfunctions\inputfiles\FAST.SFunc.out'];
            delimiter = '\t';
            startRow = 6;
            formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
            fileID = fopen(filename,'r');
            textscan(fileID, '%[^\n\r]', startRow-1, 'ReturnOnError', false);
            Output = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'ReturnOnError', false);
            fclose(fileID);
            
            % Rename and save vectors
            save(OutputFile, 'Legend')
            for i = 1:length(OutList)
                eval([OutList{i}, ' = Output{i};']);
                eval(['save(OutputFile, ''', OutList{i}, ''', ''-append'');']);
            end
        else
            % Save the complete workspace to a standalone matfile
            evalin('base', ['save(''', saveFilePath ''')']);
            disp('Standalone mat-file saved!')
        end
    end
end
end

