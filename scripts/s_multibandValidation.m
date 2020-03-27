%% Check the multispectral images prior to posting on SDR
%
% The files are stored in a directory on the Farrell 2T black drive
%
% We change to each of the directories, list the mat-files, load them in
% turn, and look at the illuminant, reflectance and other general features.
%
%

%%
baseDir = '/Volumes/Farrell/MultispectralDataOnTheWeb';

%% 2004 data
%
chdir(fullfile(baseDir,'2004','ISET Scenes'));
files = dir('*.mat');
for ii=1:numel(files)
    scene = sceneFromFile(files(ii).name,'multispectral');
    if ii > 1, ieReplaceObject(scene); end
    sceneWindow(scene);
    input('Press enter when you are done:  ');
end

%% 2008 data
chdir(fullfile(baseDir,'2008','ISET Scenes'));
files = dir('*.mat');
for ii=1:numel(files)
    scene = sceneFromFile(files(ii).name,'multispectral');
    if ii > 1, ieReplaceObject(scene); end
    sceneWindow(scene);
    input('Press enter when you are done:  ');
end

%% 2009

chdir(fullfile(baseDir,'2009','ISET Scenes'));
files = dir('*.mat');
for ii=1:numel(files)
    scene = sceneFromFile(files(ii).name,'multispectral');
    if ii > 1, ieReplaceObject(scene); end
    sceneWindow(scene);
    input('Press enter when you are done:  ');
end


%% Make a 
chdir(fullfile(baseDir,'2004','ISET Scenes'));
files = dir('*.mat');
for ii=1:numel(files)
    scene = sceneFromFile(files(ii).name,'multispectral');
    if ii > 1, ieReplaceObject(scene); end
    sceneWindow(scene);
    input('Press enter when you are done:  ');
end

%% END
