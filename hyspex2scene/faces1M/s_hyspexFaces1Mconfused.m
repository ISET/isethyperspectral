% s_hyspexFaces3M
%
% This script creates a scene from Hyspex 1M face data 
% (see http://www.hyspex.no/)
%
% The Hyspex data are stored in two files.
%   .img - the measurements, which are uncalibrated (relative) spectral radiance
%   .hdr - the information necessary to convert the img data to spectral
%          radiance with units of
%
% The img and hdr data are currently on a 1T hard drive that JEF has.
%
% See also:  s_hyspexFaces1M
%
% Copyright ImagEval Consultants, LLC, 2013

%% Initialize
ieInit

% The data are on this drive.
wDir = '/Volumes/G-DRIVE mobile with Thunderbolt/Hyspex/Data/Faces_1meter/VNIR';
chdir(wDir);

%% Here is the set of file names and the illuminant file

load('hyspexFilenames');   % Loads hyspex variable 

% Start with the VNIR.  We may never do the SWIR.
theseFiles = hyspex.facecloseups.vnir;
nFiles = size(theseFiles.names,1);
fileNames = cell(1,nFiles);
saveNames = cell(1,nFiles);
for ii=1:nFiles
    fileNames{ii} = hyspex.facecloseups.vnir.names{ii,1};
    saveNames{ii} = hyspex.facecloseups.vnir.names{ii,2};
end

%% Read the illuminant relative SPD

hyspexFileName = theseFiles.illuminant;

% The scaling parameter is in info.description{18}
hFile = [hyspexFileName,'.img'];
if exist(hFile,'file')
    [img,infoScene] = hcReadHyspex(hFile);
end
wave = infoScene.wavelength;
scaleScene = str2double(infoScene.description{18}(12:end));
img = double(img)/scaleScene;
hcimage(img);

patchSize = 16;
scene = sceneCreate('default',patchSize,wave);
scene = sceneSet(scene,'energy',sceneHC);
scene = sceneSet(scene,'illuminant energy',illSPD);

%% Create the save directory.  Note we are not emptying it if it exists

saveDir = fullfile(pwd,'output');
if ~exist(saveDir,'dir'), mkdir(saveDir); end

%% Process the face files in a loop

for ii=1:nFiles
    hyspexFileName = fileNames{ii};
    
    % The scaling parameter is in info.description{18}
    hFile = [hyspexFileName,'.img'];
    if exist(hFile,'file')
        [img,infoScene] = hcReadHyspex(hFile);
    end
    wave = infoScene.wavelength;
    scaleScene = str2double(infoScene.description{18}(12:end));
    
    % Ask the user to crop down to the white region
    [illHC,illRect] = hcimageCrop(img,[],80);
    illHC = double(illHC)/scaleScene;
    illHC = RGB2XWFormat(illHC);
    illSPD = mean(illHC)';
    vcNewGraphWin; plot(wave,illSPD);
    %
    
    % Ask the user to crop down to the face
    [sceneHC,sceneRect] = hcimageCrop(img,[],80);
    sceneHC = double(sceneHC)/scaleScene;
    hcimage(sceneHC);
    
    % Make a dummy scene and fill it with the data
    patchSize = 16;
    scene = sceneCreate('default',patchSize,wave);
    scene = sceneSet(scene,'energy',sceneHC);
    scene = sceneSet(scene,'illuminant energy',illSPD);
    % ieAddObject(scene); sceneWindow;
    
    sceneR = sceneRotate(scene,'ccw');
    % ieAddObject(sceneR); sceneWindow;

    oFiles = fullfile(saveDir,saveNames{ii});
    sceneToFile(oFiles,sceneR,0.999);
end

%%
