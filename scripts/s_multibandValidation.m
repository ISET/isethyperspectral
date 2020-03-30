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

%%  Adjust illuminant levels
%{
 % We examined scenes that might have had the illuminant too dark so that
 % the reflectance exceeded 1. In the end, we didn't think this could be
 % perfectly fixed.  The problem is specularities and uneven illumination.
 % So we left the scenes with occasional reflectances greater than 1.
  
  chdir(fullfile(baseDir,'2004','ISET Scenes'));
  files = dir('*.mat');
  for ii=1:numel(files)
      fprintf('%d:  %s\n',ii,files(ii).name)
  end
  
  ii=4 % Choose a scene to examine
  
  % Read the scene
  scene = sceneFromFile(files(ii).name,'multispectral');
  % sceneWindow(scene);
  sz = sceneGet(scene,'size');
  roi = [1 1 sz(1)-1 sz(2)-1];
  reflectance = sceneGet(scene,'roi reflectance',roi);
  mx = max(reflectance(:));
      
  illPhotons = sceneGet(scene,'illuminant photons');
  scene = sceneSet(scene,'illuminant photons',illPhotons*(mx*(1/.9)));
  reflectance = sceneGet(scene,'roi reflectance',roi);
  mx = max(reflectance(:));
  sceneWindow(scene);
%}

%% Automate the illuminant estimation from the MCC
%{
  % List
  chdir(fullfile(baseDir,'2004','ISET Scenes'));
  files = dir('*.mat');
  for ii=1:numel(files)
      fprintf('%d:  %s\n',ii,files(ii).name)
  end
  
  % 7,8 and 9 are the Macbeth scenes
  % Read one
  ii = 9
  scene = sceneFromFile(files(ii).name,'multispectral');
  scene = sceneSet(scene,'mcc corner points',[]);  % To clear
  sceneWindow(scene);

  % Select to estimate
  illPhotons = macbethIlluminant(scene);

  % Save the cornerpoints
  scene = ieGetObject('scene');

  % Compare
  orig = sceneGet(scene,'illuminant photons');
  ieNewGraphWin; 
  loglog(orig(:),illPhotons(:)); identityLine;
  grid on; xlabel('Original illuminant photons');
  ylabel('New estimate illuminant photons');
  grid on;

  % Plot
  scenePlot(scene,'illuminant photons'); 
  plotRadiance(wave,illPhotons);

  % Change the photons in the illuminant if you like, and then save it
  scene = sceneSet(scene,'illuminant photons',illPhotons);
  % SAVE HERE
  
%}
%% END
