function Ret = VisuData()
dParams.Folder = '';
dParams.Chan = '';
OldChan = '';
Data = [];
cData = [];
eData = [];
Infos = [];
currentPixel = [1 1];
Conditions = [];
CondSequence = 0;
StimTrig = 1;
AcqInfoStream = [];

% Figures:
%Principale
hParams.figP = uifigure('Name', 'Parametres', 'NumberTitle','off',...
    'Position', [20 300 250 700], 'Color', 'w', 'MenuBar', 'none',...
    'ToolBar', 'none', 'Resize', 'off', 'CloseRequestFcn', @FermeTout);
%Raw data:
hParams.figR = uifigure('Name', 'Images', 'NumberTitle','off',...
    'Position', [285 510 500 500], 'Color', 'w', 'MenuBar', 'none',...
    'ToolBar', 'none', 'Resize', 'off', 'Visible','off',...
    'WindowButtonDownFcn', @ChangePtPos, 'CloseRequestFcn', @NeFermePas);
%Corr data:
hParams.figC = uifigure('Name', 'Correlation', 'NumberTitle','off',...
    'Position', [285 200 250 250], 'Color', 'w', 'MenuBar', 'none',...
    'ToolBar', 'none', 'Resize', 'off', 'Visible','off', ...
    'CloseRequestFcn', @NeFermePas);
%Decours Temporel:
hParams.figT = uifigure('Name', 'Signal Temporel', 'NumberTitle','off',...
    'Position', [600 200 750 250], 'Color', 'w', 'MenuBar', 'none',...
    'ToolBar', 'none', 'Resize', 'off', 'Visible','off',...
    'CloseRequestFcn', @NeFermePas);
%Par Condition:
hParams.figE = uifigure('Name', 'Condition', 'NumberTitle','off',...
    'Position', [800 510 500 500], 'Color', 'w', 'MenuBar', 'none',...
    'ToolBar', 'none', 'Resize', 'off', 'Visible','off',...
    'CloseRequestFcn', @NeFermePas);

% GUI
%Pour le chemin d'acces vers le data a visualiser:
hParams.ExpLabel = uilabel(hParams.figP, 'Text','Experience:',...
    'Position',[5, 655, 100, 35], 'BackgroundColor','w', 'FontName', 'Calibri',...
    'FontSize', 12, 'HorizontalAlignment', 'left');
hParams.ExpEdit = uieditfield(hParams.figP, 'text',...
    'Value', 'Choisir un dossier', 'Position',[5, 640, 175, 25], 'BackgroundColor', 'w',...
    'FontName', 'Calibri', 'FontSize', 10,  'HorizontalAlignment', 'left');
hParams.ExpPb = uibutton(hParams.figP, 'push',...
    'Text', '', 'Position',[200, 640, 35, 29], 'BackgroundColor', 'w',...
    'Icon', 'FolderIcon.png', 'ButtonPushedFcn', @ChangeFolder);

%Pre-Analyse:
hParams.PreAPB = uibutton(hParams.figP, 'push', ...
    'Text','Pre-Analyse', 'Position',[45, 590, 150, 35],...
    'BackgroundColor','w', 'FontName', 'Calibri', 'FontSize', 12,...
    'ButtonPushedFcn', @RunPreAna, 'visible', 'off');
hParams.PreALabel = uilabel(hParams.figP, 'Text','Pre-Analyse en cours. Patientez svp...',...
    'Position',[20, 550, 200, 35], 'BackgroundColor','w', ...
    'FontName', 'Calibri', 'FontSize', 12, 'visible', 'off');

%Cannal a utiliser:
hParams.ChanLabel = uilabel(hParams.figP, 'Text','Canal d''imagerie:',...
    'Position',[5, 590, 200, 35], 'BackgroundColor','w', 'FontName', 'Calibri',...
    'FontSize', 12, 'HorizontalAlignment', 'left', 'visible', 'off');
hParams.ChanPopMenu = uidropdown(hParams.figP, 'Items', {'Choisir'},...
    'Position',[5, 575, 175, 25], 'BackgroundColor', 'w',...
    'FontName', 'Calibri', 'FontSize', 10, 'visible', 'off',...
    'ValueChangedFcn', @OuvrirData);

%Type d'experience:
hParams.TypeLabel = uilabel(hParams.figP, 'Text','Type d''enregistrement',...
    'Position',[5, 525, 200, 35], 'BackgroundColor','w', 'FontName', 'Calibri',...
    'FontSize', 12, 'HorizontalAlignment', 'left', 'visible', 'off');
hParams.TypePopMenu = uidropdown(hParams.figP, 'Items',{'Choisir', 'RestingState', 'Episodique'},...
    'Position',[5, 505, 175, 25], 'BackgroundColor', 'w',...
    'FontName', 'Calibri', 'FontSize', 10,...
    'visible', 'off', 'ValueChangedFcn', @ChangeType);

%Interaction Communes:
hParams.dFsFPB = uibutton(hParams.figP, 'push',...
    'Text','DF/F', 'Position',[45, 450, 150, 35], 'BackgroundColor','w',...
    'FontName', 'Calibri', 'FontSize', 12,...
    'visible', 'off', 'ButtonPushedFcn', @DFsF);
hParams.GSRPB = uibutton(hParams.figP, 'push',...
    'Text','GSR', 'Position',[45, 400, 150, 35], 'BackgroundColor','w',...
    'FontName', 'Calibri', 'FontSize', 12,...
    'visible', 'off', 'ButtonPushedFcn', @GSR);
hParams.Print = uibutton(hParams.figP, 'push',...
    'Text','Sauvegarde Figs', 'Position',[45, 5, 150, 35], 'BackgroundColor','w',...
    'FontName', 'Calibri', 'FontSize', 12,...
    'visible', 'off', 'ButtonPushedFcn', @Print);

% Pour l'episodique:
% Fichier Vpixx reference:
hParams.VpixxLabel = uilabel(hParams.figP, 'Text','Fichier Stimulation:',...
    'Position',[5, 360, 100, 35], 'BackgroundColor','w', 'FontName', 'Calibri',...
    'FontSize', 12, 'HorizontalAlignment', 'left', 'visible', 'off');
hParams.VpixxEdit = uieditfield(hParams.figP, 'text',...
    'Value', 'Choisir un fichier', 'Position',[5, 345, 175, 25], 'BackgroundColor', 'w',...
    'FontName', 'Calibri', 'FontSize', 10,  'HorizontalAlignment', 'left','visible', 'off');
hParams.VpixxPb = uibutton(hParams.figP, 'push',...
    'Text', '', 'Position',[200, 345, 35, 29], 'BackgroundColor', 'w',...
    'Icon', 'FolderIcon.png', 'ButtonPushedFcn', @SelectFichier,'visible', 'off');
%Entree Analogique:
hParams.StimChanLabel = uilabel(hParams.figP, 'Text','Entree Analogique:',...
    'Position',[5, 305, 100, 35], 'BackgroundColor','w', 'FontName', 'Calibri',...
    'FontSize', 12, 'HorizontalAlignment', 'left', 'visible', 'off');
hParams.StimChanPopMenu = uidropdown(hParams.figP, 'Items',{'Choisir'},...
    'Position',[5, 290, 175, 25], 'BackgroundColor', 'w',...
    'FontName', 'Calibri', 'FontSize', 10,...
    'visible', 'off', 'ValueChangedFcn', @ChangeStimSignal);
%Timing des decoupages:
hParams.PreStimLabel = uilabel(hParams.figP, 'Text','PreStim (s):',...
    'Position',[5, 250, 75, 25], 'BackgroundColor','w', 'FontName', 'Calibri',...
    'FontSize', 12, 'HorizontalAlignment', 'left', 'visible', 'off');
hParams.PreStimEdit = uieditfield(hParams.figP, 'numeric',...
    'Value', 1, 'Position',[150, 250, 75, 25], 'BackgroundColor', 'w',...
    'FontName', 'Calibri', 'FontSize', 10,  'HorizontalAlignment', 'right',...
    'visible', 'off', 'ValueChangedFcn', @TimingValidation);
hParams.StimLabel = uilabel(hParams.figP, 'Text','Stim (s):',...
    'Position',[5, 225, 75, 25], 'BackgroundColor','w', 'FontName', 'Calibri',...
    'FontSize', 12, 'HorizontalAlignment', 'left', 'visible', 'off');
hParams.StimEdit = uieditfield(hParams.figP, 'numeric',...
    'Value', 3, 'Position',[150, 225, 75, 25], 'BackgroundColor', 'w',...
    'FontName', 'Calibri', 'FontSize', 10,  'HorizontalAlignment', 'right',...
    'visible', 'off', 'ValueChangedFcn', @TimingValidation);
hParams.PostStimLabel = uilabel(hParams.figP, 'Text','PostStim (s):',...
    'Position',[5, 200, 75, 25], 'BackgroundColor','w', 'FontName', 'Calibri',...
    'FontSize', 12, 'HorizontalAlignment', 'left', 'visible', 'off');
hParams.PostStimEdit = uieditfield(hParams.figP, 'numeric',...
    'Value', 5, 'Position',[150, 200, 75, 25], 'BackgroundColor', 'w',...
    'FontName', 'Calibri', 'FontSize', 10,  'HorizontalAlignment', 'right',...
    'visible', 'off', 'ValueChangedFcn', @TimingValidation, ...
    'Enable', 'off');
%Preparation du data:
hParams.SegEvnt = uibutton(hParams.figP, 'push',...
    'Text','Decoupage', 'Position',[45, 150, 150, 35], 'BackgroundColor','w',...
    'FontName', 'Calibri', 'FontSize', 12,...
    'visible', 'off', 'ButtonPushedFcn', @StimDecoupe);


% Visualisation des images brutes:
% Graph:
hParams.axR1 = uiaxes(hParams.figR, 'Position', [67.5 100 375 375]);
% Boutons:
hParams.CurrentImageSl = uislider( hParams.figR,... 
    'Value', 1, 'Limits', [1 2], 'MajorTicks', [1 2],...
    'Position',[50, 90, 400, 3], 'ValueChangedFcn', @ChangeImage);
hParams.CI_MinLabel = uilabel( hParams.figR, 'Text', 'Minimum:', ...
    'Position',[100, 15, 75, 25],'FontName', 'Calibri', 'FontSize', 12,...
    'HorizontalAlignment', 'left');
hParams.CI_MaxLabel = uilabel( hParams.figR, 'Text', 'Maximum:', ...
    'Position',[300, 15, 75, 25],'FontName', 'Calibri', 'FontSize', 12,...
    'HorizontalAlignment', 'left');
hParams.CI_Min_Edit = uieditfield( hParams.figR, 'numeric',...
    'Value', 1, 'Position',[175, 15, 50, 25], 'BackgroundColor', 'w',...
    'FontName', 'Calibri', 'FontSize', 10,  'HorizontalAlignment', 'left',...
    'ValueChangedFcn', @AdjustImage);
hParams.CI_Max_Edit = uieditfield( hParams.figR, 'numeric',...
    'Value', 4096, 'Position',[375, 15, 50, 25], 'BackgroundColor', 'w',...
    'FontName', 'Calibri', 'FontSize', 10,  'HorizontalAlignment', 'left',...
    'ValueChangedFcn', @AdjustImage);

% Visualisation Corrélation
%Graph:
hParams.axC1 = uiaxes(hParams.figC, 'Position', [5 5 240 240]);

% Visualisation Décours Temporel:
%Graph:
hParams.axT1 = uiaxes(hParams.figT, 'Position', [5 5 740 240]);

%Visuatisation des Conditions:
hParams.axE1 = uiaxes(hParams.figE, 'Position', [67.5 100 375 375]);


% Initialisation de l'interface:
ChangeMode('Ouverture');

% Fonctions et Callbacks:
    function ChangeFolder(~,~,~)
        selpath = uigetdir(path);
        if( selpath == 0 )
            return;
        end
        
        if( ~strcmp(selpath(end), filesep) )
            selpath = strcat(selpath, filesep);
        end
        dParams.sFolder = selpath;
        hParams.ExpEdit.Value = selpath;
        ChargerDossier();
    end

    function ChargerDossier()
         %Validation du dossier
        list = dir([dParams.sFolder '*.dat']);
        
        Channels{1} = 'Choisir un Canal';
        for ind = 1:size(list,1) 
            Channels{ind+1} = list(ind).name;
        end
        
        hParams.ChanPopMenu.Items = Channels;
        hParams.ChanPopMenu.Value = Channels{1};
        if( size(list,1) == 0 )
            ChangeMode('PreAna');
        else
            ChangeMode('SelectParams');
        end
       % CheckDefaultParams();
       FigsOnTop();
       AcqInfoStream = ReadInfoFile(dParams.sFolder);
       hParams.StimChanPopMenu.Items = {'Choisir', 'CameraTrig', 'StimInterne'};
       for ind = 1:(AcqInfoStream.AINChannels - 2)
           hParams.StimChanPopMenu.Items{end+1} = ['Analog In #' int2str(ind)];
       end
    end

    function OuvrirData(~,~,~)
        
        if( iscell(hParams.ChanPopMenu.Items) )
            dParams.Chan = hParams.ChanPopMenu.Value;
            if( contains(hParams.ChanPopMenu.Items{1}, 'Choisir') )
                hParams.ChanPopMenu.Items = hParams.ChanPopMenu.Items(2:end);
            end
        else
            dParams.Chan = hParams.ChanPopMenu.Value;
        end
        
        if( ~strcmp(dParams.Chan, OldChan) )
            fid = fopen([dParams.sFolder dParams.Chan]);
            Data = fread(fid,inf, 'single=>single');
            Tmp = dir([dParams.sFolder 'Data_*.mat']);
            Infos = matfile([dParams.sFolder Tmp(1).name]);
            Data = reshape(Data, Infos.datSize(1,1), Infos.datSize(1,2),[]);
            Data = imresize3(Data, [256 256 size(Data,3)]);
            fclose(fid);
            
            hParams.GSRPB.Enable = 'on';
            hParams.dFsFPB.Enable = 'on';
        end    
        OldChan = dParams.Chan;
        hParams.dFsFPD.Enable = 'on'; 
        
        ChangeMode('SelectParams')
       
        hParams.CurrentImageSl.Limits = [1 size(Data,3)];
        hParams.CurrentImageSl.Value = 1;
        hParams.CurrentImageSl.MajorTicks = 1:1000:size(Data,3);

        ChangeImage();
    end

    function ChangeImage(~,~,~)
        Id = round(hParams.CurrentImageSl.Value);
        Im = imresize(squeeze(Data(:,:,Id)),[256 256]);
        imagesc(hParams.axR1, Im);
        caxis(hParams.axR1, [hParams.CI_Min_Edit.Value, hParams.CI_Max_Edit.Value]);
        title(hParams.axR1,['Image #: ' int2str(Id)]);
        axis(hParams.axR1, 'off', 'image');
        hold(hParams.axR1, 'on');
        plot(hParams.axR1, currentPixel(1), currentPixel(2), 'or');
        hold(hParams.axR1, 'off');
        DecoursTemp();    
    end

    function AdjustImage(~,~,~)
        
        caxis(hParams.axR1, [hParams.CI_Min_Edit.Value, hParams.CI_Max_Edit.Value]);
        DecoursTemp();
    end

    function RunPreAna(~,~,~)
        
        prompt = {'Binning Spatial (1 si aucun binning):',...
            'Binning Temporel(1 si aucun binning):',...
            'Redifinir une Region d''interet? (0:non; 1:oui)',...
            'Ignorer le signal de stimulation interne du systeme? (0:non; 1:oui)'};
        dlgtitle = 'Pre-Analyse';
        dims = [1 50];
        definput = {'1','1', '0', '0'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        
        if( isempty(answer) )
            return;
        end
        hParams.PreALabel.Visible = 'on';
        pause(0.01);
        try
        ImagesClassification(dParams.sFolder, str2double(answer{1}),...
            str2double(answer{2}), str2double(answer{3}), str2double(answer{4}));
        catch e
            disp(e);
            hParams.PreALabel.Value = 'Une erreur est survenue durant la pre-analyse.';
        end
        hParams.PreALabel.Visible = 'off';
        ChargerDossier();
    end

    function ChangeType(~,~,~)
        
        dParams.sExpType = hParams.TypePopMenu.Value;
        if( contains(hParams.TypePopMenu.Items{1}, 'Choisir') )
           hParams.TypePopMenu.Items = hParams.TypePopMenu.Items(2:end);
        end
        if( any(contains(hParams.ChanPopMenu.Items, 'Choisir')) )
            ChangeMode('SelectParams')
        elseif( strcmp(dParams.sExpType, 'RestingState') )
            ChangeMode('RestingState');
            CorrMap();
        else
            ChangeMode('Episodique Prepa');
        end
    end
        
    function ChangeMode(NewMode)
       
        switch( NewMode )
            case 'Ouverture'
                hParams.figR.Visible = 'off';
                hParams.figC.Visible = 'off';
                hParams.figT.Visible = 'off';
                hParams.figE.Visible = 'off';
                
                hParams.PreAPB.Visible = 'off';
                hParams.TypeLabel.Visible = 'off';
                hParams.TypePopMenu.Visible = 'off';
                hParams.PreALabel.Visible = 'off';
                hParams.ChanLabel.Visible = 'off';
                hParams.ChanPopMenu.Visible = 'off';
                hParams.dFsFPB.Visible = 'off';
                hParams.GSRPB.Visible = 'off';
                hParams.VpixxLabel.Visible = 'off';
                hParams.VpixxEdit.Visible = 'off';
                hParams.VpixxPb.Visible = 'off';
                hParams.StimChanPopMenu.Visible = 'off'; 
                hParams.PreStimLabel.Visible = 'off'; 
                hParams.PreStimEdit.Visible = 'off'; 
                hParams.StimLabel.Visible = 'off'; 
                hParams.StimEdit.Visible = 'off'; 
                hParams.PostStimLabel.Visible = 'off'; 
                hParams.PostStimEdit.Visible = 'off'; 
                hParams.SegEvnt.Visible = 'off'; 
                hParams.Print.Visible = 'off'; 
                
            case 'PreAna'
                hParams.figR.Visible = 'off';
                hParams.figC.Visible = 'off';
                hParams.figT.Visible = 'off';
                hParams.figE.Visible = 'off';
                
                hParams.PreAPB.Visible = 'on';
                hParams.TypeLabel.Visible = 'off';
                hParams.TypePopMenu.Visible = 'off';
                hParams.PreALabel.Visible = 'off';
                hParams.ChanLabel.Visible = 'off';
                hParams.ChanPopMenu.Visible = 'off';
                hParams.dFsFPB.Visible = 'off';
                hParams.GSRPB.Visible = 'off';
                hParams.VpixxLabel.Visible = 'off';
                hParams.VpixxEdit.Visible = 'off';
                hParams.VpixxPb.Visible = 'off';
                hParams.StimChanPopMenu.Visible = 'off';
                hParams.StimChanLabel.Visible = 'off'; 
                hParams.PreStimLabel.Visible = 'off'; 
                hParams.PreStimEdit.Visible = 'off'; 
                hParams.StimLabel.Visible = 'off'; 
                hParams.StimEdit.Visible = 'off'; 
                hParams.PostStimLabel.Visible = 'off'; 
                hParams.PostStimEdit.Visible = 'off'; 
                hParams.SegEvnt.Visible = 'off'; 
                hParams.Print.Visible = 'off'; 
                
            case 'SelectParams'
                hParams.figR.Visible = 'off';
                hParams.figC.Visible = 'off';
                hParams.figT.Visible = 'off';
                hParams.figE.Visible = 'off';
                
                hParams.PreAPB.Visible = 'off';
                hParams.TypeLabel.Visible = 'on';
                hParams.TypePopMenu.Visible = 'on';
                hParams.PreALabel.Visible = 'off';
                hParams.ChanLabel.Visible = 'on';
                hParams.ChanPopMenu.Visible = 'on';
                hParams.dFsFPB.Visible = 'off';
                hParams.GSRPB.Visible = 'off';
                hParams.VpixxLabel.Visible = 'off';
                hParams.VpixxEdit.Visible = 'off';
                hParams.VpixxPb.Visible = 'off';
                hParams.StimChanPopMenu.Visible = 'off';
                hParams.StimChanLabel.Visible = 'off';
                hParams.PreStimLabel.Visible = 'off'; 
                hParams.PreStimEdit.Visible = 'off'; 
                hParams.StimLabel.Visible = 'off'; 
                hParams.StimEdit.Visible = 'off'; 
                hParams.PostStimLabel.Visible = 'off'; 
                hParams.PostStimEdit.Visible = 'off'; 
                hParams.SegEvnt.Visible = 'off'; 
                hParams.Print.Visible = 'off'; 
                
            case 'RestingState'
                hParams.figR.Visible = 'on';
                hParams.figC.Visible = 'on';
                hParams.figT.Visible = 'on';
                hParams.figE.Visible = 'off';
                
                hParams.PreAPB.Visible = 'off';
                hParams.PreALabel.Visible = 'off';
                hParams.TypeLabel.Visible = 'on';
                hParams.TypePopMenu.Visible = 'on';
                hParams.ChanLabel.Visible = 'on';
                hParams.ChanPopMenu.Visible = 'on';
                hParams.dFsFPB.Visible = 'on';
                hParams.GSRPB.Visible = 'on';
                hParams.VpixxLabel.Visible = 'off';
                hParams.VpixxEdit.Visible = 'off';
                hParams.VpixxPb.Visible = 'off';
                hParams.StimChanPopMenu.Visible = 'off';
                hParams.StimChanLabel.Visible = 'off';
                hParams.PreStimLabel.Visible = 'off'; 
                hParams.PreStimEdit.Visible = 'off'; 
                hParams.StimLabel.Visible = 'off'; 
                hParams.StimEdit.Visible = 'off'; 
                hParams.PostStimLabel.Visible = 'off'; 
                hParams.PostStimEdit.Visible = 'off'; 
                hParams.SegEvnt.Visible = 'off'; 
                hParams.Print.Visible = 'on'; 
            
            case 'Episodique Prepa'    
                hParams.figR.Visible = 'on';
                hParams.figC.Visible = 'off';
                hParams.figT.Visible = 'off';
                hParams.figE.Visible = 'off';
                
                hParams.PreAPB.Visible = 'off';
                hParams.PreALabel.Visible = 'off';
                hParams.TypeLabel.Visible = 'on';
                hParams.TypePopMenu.Visible = 'on';
                hParams.ChanLabel.Visible = 'on';
                hParams.ChanPopMenu.Visible = 'on';
                hParams.dFsFPB.Visible = 'on';
                hParams.GSRPB.Visible = 'on';
                hParams.VpixxLabel.Visible = 'on';
                hParams.VpixxEdit.Visible = 'on';
                hParams.VpixxPb.Visible = 'on';
                hParams.StimChanPopMenu.Visible = 'on';
                hParams.StimChanLabel.Visible = 'on';
                hParams.PreStimLabel.Visible = 'off'; 
                hParams.PreStimEdit.Visible = 'off'; 
                hParams.StimLabel.Visible = 'off'; 
                hParams.StimEdit.Visible = 'off'; 
                hParams.PostStimLabel.Visible = 'off'; 
                hParams.PostStimEdit.Visible = 'off'; 
                hParams.SegEvnt.Visible = 'off'; 
                hParams.Print.Visible = 'off'; 
            
            case 'Episodique Decoup'    
                hParams.figR.Visible = 'on';
                hParams.figC.Visible = 'off';
                hParams.figT.Visible = 'off';
                hParams.figE.Visible = 'off';
                
                hParams.PreAPB.Visible = 'off';
                hParams.PreALabel.Visible = 'off';
                hParams.TypeLabel.Visible = 'on';
                hParams.TypePopMenu.Visible = 'on';
                hParams.ChanLabel.Visible = 'on';
                hParams.ChanPopMenu.Visible = 'on';
                hParams.dFsFPB.Visible = 'on';
                hParams.GSRPB.Visible = 'on';
                hParams.VpixxLabel.Visible = 'on';
                hParams.VpixxEdit.Visible = 'on';
                hParams.VpixxPb.Visible = 'on';
                hParams.StimChanPopMenu.Visible = 'on';
                hParams.StimChanLabel.Visible = 'on';
                hParams.PreStimLabel.Visible = 'on'; 
                hParams.PreStimEdit.Visible = 'on'; 
                hParams.StimLabel.Visible = 'on'; 
                hParams.StimEdit.Visible = 'on'; 
                hParams.PostStimLabel.Visible = 'on'; 
                hParams.PostStimEdit.Visible = 'on'; 
                hParams.SegEvnt.Visible = 'on'; 
                hParams.Print.Visible = 'off'; 
                
            case 'Episodique'      
                hParams.figR.Visible = 'on';
                hParams.figC.Visible = 'off';
                hParams.figT.Visible = 'off';
                hParams.figE.Visible = 'on';
                
                hParams.PreAPB.Visible = 'off';
                hParams.PreALabel.Visible = 'off';
                hParams.TypeLabel.Visible = 'on';
                hParams.TypePopMenu.Visible = 'on';
                hParams.ChanLabel.Visible = 'on';
                hParams.ChanPopMenu.Visible = 'on';
                hParams.dFsFPB.Visible = 'on';
                hParams.GSRPB.Visible = 'on';
                hParams.VpixxLabel.Visible = 'on';
                hParams.VpixxEdit.Visible = 'on';
                hParams.VpixxPb.Visible = 'on';
                hParams.StimChanPopMenu.Visible = 'on';
                hParams.StimChanLabel.Visible = 'on';
                hParams.PreStimLabel.Visible = 'on'; 
                hParams.PreStimEdit.Visible = 'on'; 
                hParams.StimLabel.Visible = 'on'; 
                hParams.StimEdit.Visible = 'on'; 
                hParams.PostStimLabel.Visible = 'on'; 
                hParams.PostStimEdit.Visible = 'on'; 
                hParams.SegEvnt.Visible = 'on'; 
                hParams.Print.Visible = 'on'; 
                         
            otherwise
                hParams.figR.Visible = 'off';
                hParams.figC.Visible = 'off';
                hParams.figT.Visible = 'off';
                
                hParams.PreAPB.Visible = 'off';
                hParams.TypeLabel.Visible = 'off';
                hParams.TypePopMenu.Visible = 'off';
                hParams.PreALabel.Visible = 'off';
                hParams.ChanLabel.Visible = 'off';
                hParams.ChanPopMenu.Visible = 'off';
                hParams.dFsFPB.Visible = 'off';
                hParams.GSRPB.Visible = 'off';
                hParams.VpixxLabel.Visible = 'off';
                hParams.VpixxEdit.Visible = 'off';
                hParams.VpixxPb.Visible = 'off';
                hParams.StimChanPopMenu.Visible = 'off';
                hParams.StimChanLabel.Visible = 'off';
                hParams.PreStimLabel.Visible = 'off'; 
                hParams.PreStimEdit.Visible = 'off'; 
                hParams.StimLabel.Visible = 'off'; 
                hParams.StimEdit.Visible = 'off'; 
                hParams.PostStimLabel.Visible = 'off'; 
                hParams.PostStimEdit.Visible = 'off'; 
                hParams.SegEvnt.Visible = 'off'; 
                hParams.Print.Visible = 'off'; 
        end
        
    end

    function DFsF(~,~,~)
        
        if( mean(reshape(Data,[],size(Data,3)),1) < 0.5 )
            Data = Data + 1;
        end
        
        dims = size(Data);
        Data = reshape(Data, [], dims(3));
        
        if( contains(hParams.ChanPopMenu.Value, 'f') )
            lp_cutoff = 1/10;
            hp_cutoff = Infos.Freq/2;
        else 
            lp_cutoff = 1/120;
            hp_cutoff = 1;
        end
            
        f = fdesign.lowpass('N,F3dB', 4, lp_cutoff, Infos.Freq);
        lpass = design(f,'butter');
        lpData = single(filtfilt(lpass.sosMatrix, lpass.ScaleValues, double(Data)'))';
        Data = Data./lpData;
        clear lpData;
        f = fdesign.lowpass('N,F3dB', 4, hp_cutoff, Infos.Freq);
        lpass = design(f,'butter');
        Data = single(filtfilt(lpass.sosMatrix, lpass.ScaleValues, double(Data)'))';        
        
        Data = reshape(Data,dims);
        hParams.CI_Min_Edit.Value = 0.95;
        hParams.CI_Max_Edit.Value = 1.05;
        ChangeImage();
        hParams.dFsFPB.Enable = 'off';
        
        if( strcmp(dParams.sExpType, 'RestingState') )
            CorrMap();
            DecoursTemp();
        end
    end

    function GSR(~,~,~)  
        dims = size(Data);
        Data = reshape(Data, [], dims(3));
        Signal = mean(Data,1);
        Signal = Signal./mean(Signal);
        X = [ones(1,dims(3)); Signal];
        B = X'\Data';
        A = (X'*B)';
        Data = Data - A;
        Data = reshape(Data, dims);
        hParams.CI_Min_Edit.Value = -0.05;
        hParams.CI_Max_Edit.Value = 0.05;
        ChangeImage();
        hParams.GSRPB.Enable = 'off';
        
        if( strcmp(dParams.sExpType, 'RestingState') )
            CorrMap();
            DecoursTemp();
        end
    end

    function CorrMap(~,~,~)
       cData = imresize(Data,[64 64]);
       cData = cData - mean(cData,3);
       cData = corr(reshape(cData,[],size(cData,3))');
       
       RefreshCorrMap();
    end

    function RefreshCorrMap(~,~,~)
        if( isempty(cData) )
            return;
        end
        
        Facteur = 64/256;
        Id = floor((currentPixel(1)-1)*Facteur)*64 + floor(currentPixel(2)*Facteur);
        if( Id < 1 ) 
            Id = 1;
        end
        if( Id > 4096)
            Id = 4096;
        end
        imagesc(hParams.axC1, reshape(cData(Id,:),64,64),[0.5 1]);
        axis(hParams.axC1, 'off', 'image');
    end

    function ChangePtPos(Obj, Evnt)
       Pos = round(Obj.Children(6).CurrentPoint);
       Pos = Pos(1,1:2);
       if( any(Pos < 1) | any(Pos > 255) )
           return;
       end
       currentPixel = Pos;
       ChangeImage();
       RefreshCorrMap();
       DecoursTemp();
    end

    function DecoursTemp()
        hold(hParams.axT1, 'off');
        plot(hParams.axT1, squeeze(Data(currentPixel(2),currentPixel(1),:)));
        hold(hParams.axT1, 'on');
        line(hParams.axT1,[hParams.CurrentImageSl.Value, hParams.CurrentImageSl.Value],...
            [hParams.CI_Min_Edit.Value, hParams.CI_Max_Edit.Value],...
            'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);
        ylim(hParams.axT1, [hParams.CI_Min_Edit.Value, hParams.CI_Max_Edit.Value]);
    end

    function SelectFichier(~,~,~)
        [filename, pathname] = uigetfile('*.txt', 'Choisir le fichier Vpixx');
        if isequal(filename,0) || isequal(pathname,0)
            return;
        end
                
        %Lire le fichier txt:
        filetext = fileread([pathname filename]);
        
        expr = '[^\n]*Start Trial';
        
        file_lim = strfind(filetext, 'SORTED');
        fileread_info = regexp(filetext(1:file_lim), expr, 'match');
        CondSequence = zeros(length(fileread_info), 1);
        for ind = 1:length(fileread_info)
            a = sscanf(fileread_info{ind}(1:strfind(fileread_info{ind}, '[')), '%f');
            if isempty(a) ==1
                error('No condition listed in Vpixx file')
            end
            CondSequence(ind) = a(2);
        end
        
        file_lim = strfind(filetext, 'SUMMARY');
        expr = '\[[^\]]*\]';
        Conditions = regexp(filetext(file_lim:end), expr, 'match');        
        hParams.VpixxEdit.Value = filename;
        
        FigsOnTop();
    end

    function StimDecoupe(~,~,~)
        
        TotalLength = floor((hParams.PostStimEdit.Value + ...
            hParams.PreStimEdit.Value + hParams.StimEdit.Value)*Infos.Freq); 
        
        Cond = size(Conditions,2);
        Reps = size(CondSequence,1)/size(Conditions,2);
        rCntr = ones(1,Cond);
        eData = zeros(256, 256, TotalLength, Cond, Reps); 
        Debut = StimTrig - round(hParams.PreStimEdit.Value*Infos.Freq);
        Fin = Debut + TotalLength - 1;
        for indE = 1:length(CondSequence)
            eData(:,:,:,CondSequence(indE), rCntr(CondSequence(indE))) = ...
                Data(:,:, Debut(indE):Fin(indE));
            rCntr(CondSequence(indE)) = rCntr(CondSequence(indE)) + 1;           
        end
        
        ChangeMode('Episodique');
    end

    function TimingValidation(~,~,~)
        TotalLength =  mean(diff(StimTrig,1,1))/Infos.Freq;
        
        hParams.PostStimEdit.Value = floor(TotalLength -...
            hParams.PreStimEdit.Value - hParams.StimEdit.Value); 
      
    end
      
    function ChangeStimSignal(~,~,~)
        dParams.StimChan = hParams.StimChanPopMenu.Value;
        if( contains(hParams.StimChanPopMenu.Items{1}, 'Choisir') )
            hParams.StimChanPopMenu.Items = hParams.StimChanPopMenu.Items(2:end);
        end
        
        idx = find(cellfun(@(x) strcmp(x, hParams.StimChanPopMenu.Value), hParams.StimChanPopMenu.Items));
        %Lire entrees analogiques:
        AnalogIN = [];
        aiFilesList = dir([dParams.sFolder 'ai*.bin']);
        for ind = 1:size(aiFilesList,1) %for each "ai_.bin" file:
            data = memmapfile([dParams.sFolder aiFilesList(ind).name], ...
                'Offset', 5*4, 'Format', 'double', 'repeat', inf);
            tmp = data.Data; %Read data
            tmp = reshape(tmp, AcqInfoStream.AISampleRate, AcqInfoStream.AINChannels, []); %reshape data based on the number of AIs
            tmp = permute(tmp,[1 3 2]); %Permutation of dimension because AIs are interlaced when saved.
            tmp = reshape(tmp,[], AcqInfoStream.AINChannels);
            AnalogIN = [AnalogIN; tmp]; %Concatenation with previous ai_.bin files
        end
        clear tmp ind data;
        Signal = AnalogIN(:,idx);
        Cam = AnalogIN(:,1);
        [~, Cam] = ischange(Cam);
        Cam = find(diff(Cam,1,1)>0);
        clear AnalogIN aiFilesList;
        
        NbColors = sum(contains(fieldnames(AcqInfoStream), 'Illumination'));
        Colors = {};
        for ind = 1:NbColors
            eval(['Colors{' int2str(ind) '} = AcqInfoStream.Illumination' int2str(ind) '.Color;']);
        end
        tag = dParams.Chan(1);
        switch(tag)
            case 'r'
                idx = find(contains(Colors, 'Red'));
            case 'y'
                idx = find(contains(Colors, 'Amber'));
            case 'g'
                idx = find(contains(Colors, 'Green'));
            case 'f'
                idx = find(contains(Colors, 'Fluo'));
        end
        
        [~, Signal] = ischange(Signal);
        Signal = Signal(Cam);
        Signal = Signal(idx:NbColors:end);
        Signal = Signal(1:size(Data,3));
        StimTrig = find(diff(Signal,1,1)>0);
        
        hParams.PreStimEdit.Limits = [0, (StimTrig(1) - 1)/Infos.Freq];
        hParams.StimEdit.Limits = [1, mean(diff(StimTrig,1,1))/Infos.Freq];
        hParams.PostStimEdit.Limits = [0, mean(diff(StimTrig,1,1))/Infos.Freq];
        
        ChangeMode('Episodique Decoup');
    end
    
    function Print(~,~,~)
       % Sauvegarde les images affichees dans des fichiers en format .png 
       filename = inputdlg('Nom du fichier de sauvegarde:' , 'Sauvegarde de figures');
       fields = fieldnames(hParams);
       fields = regexp(fields, 'fig\w*[^P]', 'match');fields = [fields{:}];
       for i = 1:length(fields)
           if strcmp(hParams.(fields{i}).Visible,'on')
               name = [filename{:} '_' hParams.(fields{i}).Name '.png'];
               idx = arrayfun(@(x) isa(x, 'matlab.ui.control.UIAxes'), hParams.(fields{i}).Children);
               handle = hParams.(fields{i}).Children(idx);
               fig = figure('Visible', 'off', 'Position', hParams.(fields{i}).Position);
               copyobj(handle, fig);
               saveas(fig, fullfile(hParams.ExpEdit.Value, name), 'png')               
           end
       end
       uiwait(msgbox(['Figures sauvetgardes dans ' hParams.ExpEdit.Value], 'Sauvegarde reussite'));
       close all
    end

    function NeFermePas(~,~,~)
        
    end

    function FermeTout(~,~,~)
        delete(hParams.figT);
        delete(hParams.figR);
        delete(hParams.figC);
        delete(hParams.figE);
        delete(hParams.figP);        
    end

    function FigsOnTop()
        if( strcmp(hParams.figR.Visible, 'on') )
            figure(hParams.figR);
        end
        if( strcmp(hParams.figT.Visible, 'on') )
            figure(hParams.figT);
        end
        if( strcmp(hParams.figC.Visible, 'on') )
            figure(hParams.figC);
        end
        if( strcmp(hParams.figE.Visible, 'on') )    
            figure(hParams.figE);
        end
        figure(hParams.figP);
    end
end