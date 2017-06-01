function out = IOIAnalysisManager()

fig = figure('Name', 'IOI Manager',...
    'NumberTitle', 'off',...
    'ToolBar', 'none',...
    'MenuBar', 'none',...
    'Position',[250 100 400 600]);

m_SelectPB = uicontrol('Style', 'pushbutton', 'Parent', fig,...
    'Units', 'normalized', 'Position', [0.025 0.925 0.175 0.05],...
    'Callback', @FilesSelection, 'String', 'Select Folder');

m_AnaList = uicontrol('Style', 'listbox', 'Parent', fig,...
    'Units', 'Normalized', 'Position', [0.025 0.025 0.75 0.875],...
    'Background', 'w', 'max', 1);

m_RemovePB = uicontrol('Style', 'pushbutton', 'Parent', fig,...
    'Units', 'normalized', 'Position', [0.225 0.925 0.175 0.05],...
    'Callback', @RemoveSelected, 'String', 'Remove');

uicontrol('Style', 'text', 'Parent', fig,...
    'Units', 'normalized', 'Position', [0.43 0.9125 0.1 0.05],...
    'String', 'CPUs');
m_CPUsToUse = uicontrol('Style', 'edit', 'Parent', fig,...
    'Units', 'normalized', 'Position', [0.53 0.925 0.1 0.05],...
    'String', '1', 'Callback', @CPUChange);
set(m_CPUsToUse, 'Enable', 'off');

m_StartPB = uicontrol('Style', 'pushbutton', 'Parent', fig,...
    'Units', 'normalized', 'Position', [0.75 0.925 0.175 0.05],...
    'Callback', @NewStart, 'String', 'Start');

m_binningCB = uicontrol('Style', 'checkbox', 'Parent', fig,...
    'Units', 'normalized', 'Position', [0.7875 0.8625 0.20 0.05],...
    'String', 'Bining');

m_EraseCB = uicontrol('Style', 'checkbox', 'Parent', fig,...
    'Units', 'normalized', 'Position', [0.7875 0.825 0.20 0.05],...
    'String', 'Clean Folder');

uicontrol('Style', 'text', 'Parent', fig,...
    'Units', 'normalized', 'Position', [0.7875 0.775 0.20 0.05],...
    'String', 'Pre-Stim');

% m_PreStimDuration = uicontrol('Style', 'listbox', 'Parent', fig,...
%     'Units', 'normalized', 'Position', [0.7875 0.75 0.20 0.05],...
%     'String', '5 s|10 s');

    function FilesSelection(~, ~, ~)
        RootFolder = uigetdir();
        if( RootFolder == 0 )
            return;
        end
        DirsUnderTest = dir(RootFolder);
        DirsUnderTest(end+1).name = '';
        DirsUnderTest(end).isdir = 1;
        ExpToProcess = {};
        Limit = size(DirsUnderTest, 1);
        indD = 3;
        while( indD <= Limit )
            if( DirsUnderTest(indD).isdir )
                if( ~isempty(DirsUnderTest(indD).name) )
                    FilesCheck = dir([RootFolder filesep DirsUnderTest(indD).name]);
                    SeqFile = 0; AuxFile = 0; InfoFile = 0;
                    for indF = 3:size(FilesCheck,1)
                        if(FilesCheck(indF).isdir)
                            DirsUnderTest(end+1).name = [DirsUnderTest(indD).name filesep FilesCheck(indF).name];
                            DirsUnderTest(end).isdir = 1;
                        elseif( strcmp(FilesCheck(indF).name, 'IOI_scan.seq') || ~isempty(strfind(FilesCheck(indF).name, 'img_*.bin')) )
                            SeqFile = 1;
                        elseif( strcmp(FilesCheck(indF).name, 'IOI_aux.mat') || ~isempty(strfind(FilesCheck(indF).name, 'ai_*.bin')))
                            AuxFile = 1;
                        elseif( strcmp(FilesCheck(indF).name, 'IOI_scaninfo.mat') || strcmp(FilesCheck(indF).name, 'info.txt'))
                            InfoFile = 1;
                        end
                    end
                    if( SeqFile*AuxFile*InfoFile )
                        ExpToProcess{end+1} = [RootFolder filesep DirsUnderTest(indD).name];
                    end
                else
                    FilesCheck = dir(RootFolder);
                    SeqFile = 0; AuxFile = 0; InfoFile = 0;
                    for indF = 3:size(FilesCheck,1)
                        if( strcmp(FilesCheck(indF).name, 'IOI_scan.seq') || ~isempty(strfind(FilesCheck(indF).name, 'img_')) )
                            SeqFile = 1;
                        elseif( strcmp(FilesCheck(indF).name, 'IOI_aux.mat') || ~isempty(strfind(FilesCheck(indF).name, 'ai_')))
                            AuxFile = 1;
                        elseif( strcmp(FilesCheck(indF).name, 'IOI_scaninfo.mat')  || strcmp(FilesCheck(indF).name, 'info.txt'))
                            InfoFile = 1;
                        end
                    end
                    if( SeqFile*AuxFile*InfoFile )
                        ExpToProcess{end+1} = [RootFolder filesep DirsUnderTest(indD).name];
                    end
                end
            end
            Limit = size(DirsUnderTest,1); indD = indD + 1;
        end
        set(m_AnaList,'String', ExpToProcess);
    end

    function RemoveSelected(~, ~, ~)
        toBeRemoved = get(m_AnaList, 'Value');
        A = get(m_AnaList, 'String');
        A(toBeRemoved) = [];
        set(m_AnaList, 'String', A);
    end

    function CPUChange(~,~,~)
       if( str2double(get(m_CPUsToUse, 'String')) > 7 )
           set(m_CPUsToUse, 'String', 4);
       elseif( str2double(get(m_CPUsToUse, 'String')) < 1 )
           set(m_CPUsToUse, 'String', 1);
       end
    end

    function NewStart(~,~,~)
        BinData = get(m_binningCB, 'value');
        EraseOldFiles = get(m_EraseCB, 'value');
  %      PreStimD = get(m_PreStimDuration, 'Value') == 1;
        
        List = get(m_AnaList,'String');
        ToOpen = ones(size(List,1),1);
        
        %Version Check:
        VersionFlags = zeros(size(List,1),1);
        for indE = 1:size(List,1)
            V = VersionTest(List{indE});
            switch V
                case '1.0'
                    VersionFlags(indE) = 10;
                case '2.0'
                    VersionFlags(indE) = 20;
                case '2.1'
                    VersionFlags(indE) = 21;
                case '2.2'
                    VersionFlags(indE) = 22;
            end
        end
        
        %%%%%%%%%
        %Expe Folder cleaning...
        %%%%%%%%%
        if( EraseOldFiles )
            for indE = 1:size(List,1)
                Files = dir([List{indE} 'Data*.mat']);
                Files = [Files;  dir([List{indE} 'ROIs.mat'])];
                Files = [Files;  dir([List{indE} 'Hb_*.mat'])];
                arrayfun(@(X) delete([List{indE} X.name]), Files);
            end
        else
            for indE = 1:size(List,1)
                Files = dir([List{indE} 'Data*.mat']);
                Files = [Files;  dir([List{indE} 'Hb_Concentrations.mat'])];
                arrayfun(@(X) delete([List{indE} X.name]), Files);
            end
        end 
        
        %%%%%%%%%
        %Speckle?
        %%%%%%%%%
        ToSpeckle = ones(size(List,1),1);
        for indE = 1:size(List,1)
            if( VersionFlags(indE) < 20 )
                load([List{indE} filesep 'IOI_scaninfo.mat'],'Signaux');
                ToSpeckle(indE) = any(Signaux(:,5));
                clear Signaux;
            else
               AcqInfoStream = readtable([List{indE} filesep 'info.txt'],...
                    'Delimiter',':','ReadVariableNames',false, 'ReadRowNames',true);

                if( str2double(AcqInfoStream{'Illumination',1}) >= 8 )
                    ToSpeckle(indE) = 1;
                end
            end
            
        end
        
        %%%%%%%%%
        %Main Loop
        %%%%%%%%%
        NbCPUs = 1; %str2double(get(m_CPUsToUse, 'String'));
        
        %Single Threaded loop:
        if( NbCPUs == 1 )
         %   h = waitbar(0, 'Starting ...');
            for indR = 1:sum(ToOpen)
                disp('Step 1: Opening Data files')
                disp('**************************');
                if(VersionFlags(indE) < 20)
                    OpenIOI_OldSyst(List{indE}, BinData);
                elseif(VersionFlags(indE) == 20)
                    OpenIOI_NewSyst(List{indE}, BinData, 1);
                elseif(VersionFlags(indE) == 21)
                    OpenIOI_NewSyst(List{indE}, BinData, 2);
                end
                disp('Step 2: Hb Computations')
                disp('**************************');
                Ana_IOI_FullFrame( List{indR}, 0 );
                if( ToSpeckle(indR) )
                    disp('Step 3: Speckle')
                    disp('**************************');
                    Ana_Speckle( List{indR} );
                end
                %IOIFiguresGen(List{indR});
                disp(['Done for:'  List{indR}])
                disp('**************************');
%                 if( ishghandle(h) )
%                     waitbar(indR/sum(ToOpen), h, ['Task ' int2str(indR) ' of ' int2str(sum(ToOpen))]);
%                 else
%                     h = waitbar(indR/sum(ToOpen), ['Task ' int2str(indR) ' of ' int2str(sum(ToOpen))]);
%                 end
            end
%             if( ishghandle(h) )
%                 close(h);
%             end
        else
            % NOT EFFICIENT CODE AT THIS MOMENT. DO NOT USE!!!
%             %Multi-Threaded loop:
%             if( ispc )
%                 [~, result] = system('tasklist');
%                 Id = strfind(result,'MATLAB.exe');
%             elseif( isunix )
%                 [~, result] = system('ps -a');
%                 Id = strfind(result,'MATLAB');
%             end
%             [p, ~, ~] = fileparts(mfilename('fullpath'));
%             
%             IdSub = Id;
%             indR = 1;
%             TaskRunning = 0;
%             TaskDone = 0;
%             
%             h = waitbar(0, 'Starting ...');
%             while( any(ToOpen) )
%                 
%                 ExecStr = ['matlab -nodisplay -nojvm -nosplash -nodesktop -logfile '...
%                     List{indR} filesep 'Log.txt -r "addpath(''' p '''); Fast_OpenIOI('''...
%                     List{indR} ''',''' int2str(BinData) '''); Ana_IOI_FullFrame(''' List{indR} ...
%                     ''', 0);'];
%                 
%                 if( ToSpeckle(indR) )
%                     ExecStr = strcat(ExecStr, [' Ana_Speckle(''' List{indR} ''');']);
%                 end
%                 
%                 %ExecStr = strcat(ExecStr, [' IOIFiguresGen(''' List{indR} '''); exit;"  &']);
%                 
%                 ExecStr = strcat(ExecStr, [' exit;"  &']);
%                 
%                 if( ispc )
%                     [~, result] = system('tasklist');
%                     NewIds = strfind(result,'MATLAB.exe');
%                 elseif( isunix )
%                     [~, result] = system('ps -a');
%                     NewIds = strfind(result,'MATLAB');
%                 end
%                 IdSub = NewIds;
%                 
%                 system(ExecStr);
%                 TaskRunning = TaskRunning + 1;
%                 
%                 while( size(NewIds,2) == size(IdSub,2) )
%                     pause(10);
%                     if( ispc )
%                         [~, result] = system('tasklist');
%                         NewIds = strfind(result,'MATLAB.exe');
%                     elseif( isunix )
%                         [~, result] = system('ps -a');
%                         NewIds = strfind(result,'MATLAB');
%                     end
%                 end
%                 IdSub = NewIds;
%                 ToOpen(indR) = 0;
%                 indR = indR + 1;
%                 
%                 CPUsInUse = size(IdSub,2);
%                 while( CPUsInUse == NbCPUs + 1 )
%                     pause(10);
%                     if( ispc )
%                         [~, result] = system('tasklist');
%                         NewIds = strfind(result,'MATLAB.exe');
%                     elseif( isunix )
%                         [~, result] = system('ps -a');
%                         NewIds = strfind(result,'MATLAB');
%                     end
%                     CPUsInUse = size(NewIds,2);
%                 end
%                 IdSub = NewIds;
%                 TaskDone = TaskDone + (TaskRunning - (CPUsInUse - 1));
%                 TaskRunning = (CPUsInUse - 1);
%                 
%                 if( ishghandle(h) )
%                     waitbar(TaskDone/sum(ToOpen), h, ['Exec: ' int2str(TaskRunning) ', Done: ' int2str(TaskDone) ', Waiting: ' int2str(sum(ToOpen) - TaskDone)]);
%                 else
%                     h = waitbar(TaskDone/sum(ToOpen), ['Exec: ' int2str(TaskRunning) ', Done: ' int2str(TaskDone) ', Waiting: ' int2str(sum(ToOpen) - TaskDone)]);
%                 end
%                 
%             end
%             if( ishghandle(h) )
%                 close(h);
%             end
        end
    end

end