function DatOut = SpeckleMapping(folderPath, sType, channel, bSave, bLogScale)
%%%%%%%%%%%%%%%%%%%% Speckle Mapping function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show the standard deviation (spatialy or temporaly) of speckle
% acquisition. This measure is proportional to the strength of blood flow
% in vessels.
%
% INPUTS:
%
% 1- folderPath: Folder containing the speckle data (called speckle.dat)
%
% 2- sType: how the stdev should be computed. Two options:
%       - Spatial: stdev will be computed on a 5x5 area in the XY plane
%       - Temporal: stdev will be computed on a 5x1 vector in the time dimension 
%
% 3- channel (optional): Channel to analyse, for example 'green', 'red',
% etc. (speckle by default)
%
% 4- bSave: boolean flag to use when user wants to save dat file:
%           - true: a dat file named flow.dat will be generated
%           - false: no file generated
%
% 5- bLogScale: bolean flag to put data on a -log10 scale
%           - true: ouput data is equal to -log10(data)
%           - false: data = data;
%
% OUTPUT:
%
% 1- DatOut: StDev variation over time.

if(nargin < 3)
    channel = 'speckle';
    bSave = 1;
    bLogScale = 1;
end

if( ~strcmp(folderPath(end), filesep) )
    folderPath = strcat(folderPath, filesep);
end

channel = lower(channel);
if(~exist([folderPath channel '.dat'],'file') )
    disp([channel '.dat file is missing. Did you run ImagesClassificiation?']);
    return;
end

disp(['Opening ' channel '.dat']);

try
    Infos = matfile([folderPath channel '.mat']);
    fid = fopen([folderPath channel '.dat']);
    dat = fread(fid, inf, '*single');
    dat = reshape(dat, Infos.datSize(1,1), Infos.datSize(1,2),[]);
    dat = dat./mean(dat,3);
catch 
    disp(['Failed to open ' channel ' files'])
    return
end

disp('Mapping Computation');
switch lower(sType)
    case 'spatial'
        Kernel = zeros(5,5,1,'single');
        Kernel(:,:,1) = single(fspecial('disk',2)>0);
        DatOut = stdfilt(dat,Kernel);
    case 'temporal'
        Kernel = ones(1,1,5,'single');
        DatOut = stdfilt(dat,Kernel);     
end
DatOut = single(DatOut);

if( bLogScale )
    DatOut = -log10(DatOut);
end

%Remove outliers
pOutlier = prctile(DatOut(:), 99);
DatOut(DatOut>pOutlier) = pOutlier;

%Generate output
% copyfile([folderPath channel '.mat'], [folderPath flow '.mat'])
if( bSave )
    disp('Saving');
    mFileOut = matfile([folderPath 'flow.mat'], 'Writable', true);
    mFileOut.FirstDim = Infos.FirstDim;
    mFileOut.Freq = Infos.Freq;
    mFileOut.Stim = Infos.Stim;
    mFileOut.datLength = Infos.datLength;
    mFileOut.datSize = Infos.datSize;
    mFileOut.datFile = 'flow.dat';

    fid = fopen([folderPath 'flow.dat'],'w'); 
    fwrite(fid, single(DatOut), 'single');
    fclose(fid);
end
disp('Done');
end
