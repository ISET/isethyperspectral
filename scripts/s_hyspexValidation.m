%% Create the thumbnails and a montage for each hyperspectral database
%
% Read each of the scenes and uses sceneGet(scene,'rgb'); for the
% thumbnail. Use insertInImage to add the file name.
%
% Then, combine the thumbnails into the montage.
%
% Wandell, March 22, 2020
%
% See also
%   s_hyspexFaces1M, s_hyspexMontage

%%  Find the files
dataDir = fullfile(hyspexRootPath,'local','faces1m');
chdir(dataDir)
matFiles = dir('*.mat');
nFiles = numel(matFiles);

%% There is a main file and a Params file.  Read only on the main files

% This is how we checked the illuminant and mean luminance.  They were all
% fine.
for ii=1:nFiles
    if  ~ieContains(matFiles(ii).name,'Params')
        fprintf('%s ...\n',matFiles(ii).name); 
        scene = sceneFromFile(matFiles(ii).name,'multispectral');
        % sceneWindow(scene);
        
        mlum = sceneGet(scene,'mean luminance');
        
        [uData,thisFig] = scenePlot(scene,'illuminant energy roi',[]);
        y = double(0.15*max(uData.energy(:)));
        t = text(750,y,sprintf('Mean luminance %.1f cd/m^2',mlum),'fontsize',14);
        
        parts = strsplit(matFiles(ii).name,'.');
        fname = sprintf('%s_illuminant.jpg',parts{1});
        saveas(thisFig,fname)
    end
end

%% Fruit
% This is how we adjusted the distance and FOV for the fruit

dataDir = fullfile(hyspexRootPath,'local','fruit');
chdir(dataDir)
matFiles = dir('*.mat');
nFiles = numel(matFiles);

for ii=1:nFiles
    if  ~ieContains(matFiles(ii).name,'Params')
        fname = matFiles(ii).name;
        fprintf('%s ...\n',fname); 
        d = load(fname);
        fov = 40; dist = 3;
        ieSaveMultiSpectralImage(fname,d.mcCOEF,d.basis,d.comment,d.imgMean,d.illuminant,fov,dist,d.name);
        params = d.params;
        fprintf('Appending and saving all the parameter values.\n');
        save(fname,'params','-append')
    end
end

%% Landscape
% This is how we adjusted the distance and FOV for the landscape

dataDir = fullfile(hyspexRootPath,'local','landscape');
chdir(dataDir)
matFiles = dir('*.mat');
nFiles = numel(matFiles);

for ii=1:nFiles
    if  ~ieContains(matFiles(ii).name,'Params')
        fname = matFiles(ii).name;
        fprintf('%s ...\n',fname); 
        d = load(fname);
        fov = 40; dist = 100;
        ieSaveMultiSpectralImage(fname,d.mcCOEF,d.basis,d.comment,d.imgMean,d.illuminant,fov,dist,d.name);
        params = d.params;
        fprintf('Appending and saving all the parameter values.\n');
        save(fname,'params','-append')
    end
end

%% Faces at 3M
% This is how we adjusted the distance and FOV for the faces 3m

dataDir = fullfile(hyspexRootPath,'local','faces3m');
chdir(dataDir)
matFiles = dir('*.mat');
nFiles = numel(matFiles);

for ii=1:nFiles
    if  ~ieContains(matFiles(ii).name,'Params')
        fname = matFiles(ii).name;
        fprintf('%s ...\n',fname); 
        d = load(fname);
        fov = 5; dist = 3;
        ieSaveMultiSpectralImage(fname,d.mcCOEF,d.basis,d.comment,d.imgMean,d.illuminant,fov,dist,d.name);
        params = d.params;
        fprintf('Appending and saving all the parameter values.\n');
        save(fname,'params','-append')
    end
end

%% Faces at 1M
% This is how we adjusted the distance and FOV for the faces 1m

dataDir = fullfile(hyspexRootPath,'local','faces1m');
chdir(dataDir)
matFiles = dir('*.mat');
nFiles = numel(matFiles);

for ii=1:nFiles
    if  ~ieContains(matFiles(ii).name,'Params')
        fname = matFiles(ii).name;
        fprintf('%s ...\n',fname); 
        d = load(fname);
        fov = 15; dist = 1;
        ieSaveMultiSpectralImage(fname,d.mcCOEF,d.basis,d.comment,d.imgMean,d.illuminant,fov,dist,d.name);
        params = d.params;
        fprintf('Appending and saving all the parameter values.\n');
        save(fname,'params','-append')
    end
end

%% END
