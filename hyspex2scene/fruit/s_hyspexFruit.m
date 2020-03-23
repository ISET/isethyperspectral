%% s_hyspexFaces3M
%
% Brief (See Readme.m in hyspex2scene).
%
%  This script creates a scene from Hyspex 3M face data 
%   
%   See http://www.hyspex.no/ for a description of the hyspex device.
%
% The Hyspex data are stored in two files.
%   .img - the measurements, which are uncalibrated (relative) spectral radiance
%   .hdr - the information necessary to convert the img data to spectral
%          radiance with units of ????
%
% The hyspex files (img and hdr)are currently on a 1T hard drive that JEF
% has. They are stored in both VNIR and SWIR directories.  They have very
% long names.
% 
% The file 'hsypexFilenames' translates from the very long hyspex names
% into the shorter names we are using for this project.
%
% Illuminant:
%
%
% See also (not all written yet)
%   s_hyspexFaces1M.m, s_hyspexFaces3M.m, s_hyspexLandscape.m

%% Initialize
ieInit

% The data are on this drive.
%wDir = '/Volumes/G-DRIVE mobile with Thunderbolt/Hyspex/Data/Faces_1meter/VNIR';
wDir = '/Volumes/Farrell/Hyspex/HyspexData/Fruit/VNIR';
chdir(wDir);

%% Here is the set of file names and the illuminant file

% Loads hyspex variable that contains the raw data names and the associated
% short names and the name of the illuminant file.
load('hyspexFilenames','hyspex');   

%% We are analyzing only the VNIR here

% We store the input and output names
theseFiles = hyspex.fruit.vnir;
nFiles = size(theseFiles.names,1);
fileNames = cell(1,nFiles);
saveNames = cell(1,nFiles);
paramNames = cell(1,nFiles);
for ii=1:nFiles
    fileNames{ii} = hyspex.fruit.vnir.names{ii,1};
    saveNames{ii} = hyspex.fruit.vnir.names{ii,2};
    paramNames{ii} = [saveNames{ii},'_Params'];
end

%% Create the save directory.  Note we are not emptying it if it exists

saveDir = fullfile(hyspexRootPath,'local','fruit');
if ~exist(saveDir,'dir'), mkdir(saveDir); end

%% Process the face files in a loop

for ii = 1:nFiles
    
    %% Read the file
    hFile = [fileNames{ii},'.img'];
    fprintf('Reading %s\n',hFile);
    if exist(hFile,'file'), [img,infoScene] = hcReadHyspex(hFile); 
    else, error('Could not find %s\n',hFile);
    end
    
    %% Read the wavelength
    wave = infoScene.wavelength;
    scaleScene = str2double(infoScene.description{18}(12:end));
    if isnan(scaleScene)
        % There was one file without a good scale factor.  So we trapped
        % the case here and kept scaling until we found this reasonable
        % number.
        warning('Scale scene is a NaN.  Making something up.');
        scaleScene = 1.3e+6;
    else, fprintf('scene scale %g\n',scaleScene);
    end
    
    %% This asks the user to crop the sky part of the image data
    
    % We use the radiance from a white surface in the image as the
    % illuminant.  Probably not a true estimate of the actual illuminant on
    % the different surfaces with all their orientations and shadows. But
    % it's not worse than nothing.
    %
    [sceneIlluminant,illuminantRect] = hcimageCrop(img,[],80); 
    sceneIlluminant = mean(RGB2XWFormat(sceneIlluminant))';
    % plotRadiance(wave,sceneIlluminant);
    
    % hcimage(sceneHC);
    % title(saveNames{ii})
    
    %% Make the scene
        
    % Make a scene and fill it with the hypercube data
    % patchSize = 16;
    % scene = sceneCreate('default',patchSize,wave);
    
    scene = sceneCreate('empty',[],wave);
    scene = sceneSet(scene,'energy',double(img)*scaleFactor);
    scene = sceneSet(scene,'illuminant energy',sceneIlluminant*scaleFactor);
    
    %% Rotate and name the scene
    scene = sceneRotate(scene,'ccw');  % Opposite direction from faces
    scene = sceneSet(scene,'name',saveNames{ii});
    scene = sceneSet(scene,'distance',3);
    scene = sceneSet(scene,'hfov',40);
    % sceneWindow(scene);
    
    %% Compress and save
    fprintf('Compressing and saving %s\n',saveNames{ii})
    oFiles = fullfile(saveDir,saveNames{ii});
    pFiles = fullfile(saveDir,paramNames{ii});
    
    % If we set varExplained, the nBases is contained in the mcCOEF
    % variable (3rd dimension) 
    % If we set nBases the function returns the varExplained
    % varExplained = 0.999;  sceneToFile(oFiles,scene,varExplained);
    % load(oFiles,'mcCOEF'); nBases = size(mcCOEF,3);
    nBases = 8;
    varExplained = sceneToFile(oFiles,scene,nBases);
    fprintf('Saved %s with var explained %.4f\n',oFiles,varExplained);
    
    %% Save the parameters
    params.varExplained     = varExplained;
    params.illuminantRect   = illuminantRect;
    params.nBases           = nBases;
    
    fprintf('Appending and saving all the parameter values.\n');
    save(oFiles,'params','-append')
    save(pFiles,'params');
    fprintf('Saved %s\n',pFiles);

    %{
      % To check, read it in this way
      tmp = sceneFromFile(oFiles,'multispectral'); 
      vcReplaceObject(tmp); 
      sceneWindow; clear tmp
    %}

end

