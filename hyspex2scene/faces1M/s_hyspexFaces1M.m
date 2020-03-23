%% s_hyspexFaces1M
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
%    We have a clearly labeled illuminant file for the 1M data.  There is
%    another white.img file that is unlabeled.  It could be the illuminant
%    file for the 3M data.
%
%    There are no illuminant files for the landscape data, of course.
%    Not sure about the fruit data.
%
%
% See also (not all written yet)
%   s_hyspexFaces3M.m, s_hyspexFruit.m, s_hyspexLandscape.m

%% Initialize
ieInit

% The data are on this drive.
%wDir = '/Volumes/G-DRIVE mobile with Thunderbolt/Hyspex/Data/Faces_1meter/VNIR';
wDir = '/Volumes/Farrell/Hyspex/HyspexData/Faces1M/VNIR';
chdir(wDir);

%% Here is the set of file names and the illuminant file

% Loads hyspex variable that contains the raw data names and the associated
% short names and the name of the illuminant file.
load('hyspexFilenames','hyspex');   

%% We are analyzing only the VNIR here

% We store the input and output names
theseFiles = hyspex.facecloseups.vnir;
nFiles = size(theseFiles.names,1);
fileNames = cell(1,nFiles);
saveNames = cell(1,nFiles);
paramNames = cell(1,nFiles);
for ii=1:nFiles
    fileNames{ii} = hyspex.facecloseups.vnir.names{ii,1};
    saveNames{ii} = hyspex.facecloseups.vnir.names{ii,2};
    paramNames{ii} = [saveNames{ii},'_Params'];
end

%% Create the save directory.  Note we are not emptying it if it exists

saveDir = fullfile(hyspexRootPath,'local','faces1m');
if ~exist(saveDir,'dir'), mkdir(saveDir); end

%% Read the spatial distribution of the illuminant data

illuminantFile = [hyspex.faces.vnir.illuminant,'.img'];
if ~exist(illuminantFile,'file')
    error('Could not find %s\n',illuminantFile);
else
    [illData,infoIll] = hcReadHyspex(illuminantFile);
end
hcimage(illData);

%% Process the face files in a loop

for ii = 1:nFiles
    
    %% Read the file
    hFile = [fileNames{ii},'.img'];
    fprintf('Reading %s\n',hFile);
    if exist(hFile,'file'), [img,infoScene] = hcReadHyspex(hFile); 
    else, error('Could not find %s\n',hFile);
    end
    
    %% Read the wavelength and the scaling parameter in info.description{18}
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
    
    %% This asks the user to crop the image data and start processing
    %
    % We use the same rect for the illData as the rect we chose for the
    % scene.
    [sceneHC,sceneRect] = hcimageCrop(img,[],80); 
    
    sceneHC = double(sceneHC)/scaleScene;
    % hcimage(sceneHC);
    % title(saveNames{ii})
    
    %% Estimate the spatial weighting function for the illuminant  
    % 
    % The illData are derived from the whiteboard. We use the hypercube
    % data from the same rect as the location of the face.  Rather than
    % using the raw data, however, we insist on their being a single
    % illuminant SPD (illSPD) and we scale it across space using a smoothed
    % version of the hypercube data.  We think the point-by-point
    % differences are largely due to scratches on the white board and not
    % real illuminant differences.
    
    % Read the hypercube data from the white board. The header is in
    % infoIll. The 18th line and 12:end contain the scale factor.
    disp('Analyzing illuminant data');
    [illuminantHC, illuminantRect] = hcimageCrop(illData,sceneRect);
    scaleIll = str2double(infoIll.description{18}(12:end));
    illuminantHC = (double(illuminantHC)/scaleIll);
    
    % The board has some scratches, so we blur it
    spatialSpread   = 15;
    illuminantHC    = hcBlur(illuminantHC,spatialSpread);
    
    % Summarize the illuminant level across space by averaging across the
    % different wavelengths.  
    illuminantSpace = mean(illuminantHC,3);
    
    % Scale the max to 1, so this is the spatial-weighting function for the
    % illuminant.
    illuminantSpace = ieScale(illuminantSpace,1);
    % ieNewGraphWin; imagesc(illuminantSpace);
    
    %% Make the spectral power distribution average across the pixels
    illSPD = mean(RGB2XWFormat(illuminantHC));
    % plotRadiance(wave,illSPD)
    
    % Now make the whole spatial spectral illuminant
    sz = size(sceneHC);    
    ssIlluminant = repmat(illSPD(:)',[prod(sz(1:2)),1]);
    ssIlluminant = XW2RGBFormat(ssIlluminant,sz(1),sz(2));
    
    % Multiply every wavelength dimension by the normalized spatial
    % weighting function that we calculated above
    ssIlluminant = bsxfun(@times,illuminantSpace,ssIlluminant);
    
    % Make a scene and fill it with the hypercube data
    % patchSize = 16;
    % scene = sceneCreate('default',patchSize,wave);
    
    scene = sceneCreate('empty',[],wave);
    scene = sceneSet(scene,'energy',sceneHC);
    
    illuminantScale = 1.05;
    scene = sceneSet(scene,'illuminant energy',ssIlluminant*illuminantScale);
    
    %% Rotate and name the scene
    scene = sceneRotate(scene,'ccw');
    scene = sceneSet(scene,'name',saveNames{ii});
    scene = sceneSet(scene,'distance',1);
    scene = sceneSet(scene,'hfov',15);
    % sceneWindow(scene);
    
    %% Compress and save
    fprintf('Compressing and saving %s\n',saveNames{ii})
    oFiles = fullfile(saveDir,saveNames{ii});
    pFiles = fullfile(saveDir,paramNames{ii});
    
    % If we set varExplained, the nBases is contained in the mcCOEF
    % variable (3rd dimension) 
    % If we set nBases the function returns the varExplained
    % varExplained = 0.999;  sceneToFile(oFiles,scene,varExplained);
    nBases = 6;
    varExplained = sceneToFile(oFiles,scene,nBases);
    fprintf('Saved %s with var explained %.4f\n',oFiles,varExplained);
    
    %% Save the parameters
    params.varExplained     = varExplained;
    params.illuminantScale  = illuminantScale;
    params.spatialSpread    = spatialSpread;
    params.scaleScene       = scaleScene;
    params.sceneRect        = sceneRect;
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

%%

% ill = illuminantCreate;
% ill = illuminantSet(ill,'wave',illSPD);
% Scale factor to account for reflectance a little less than 1
% ill = illuminantSet(ill,'energy',illSPD*illuminantScale);

%{
      % Originally, we separately processed the data to create the illuminant
      % spd.  This was done with the script
      %
      %   s_illuminantEstimate.m
      %
      % And the outputs were stored in the hcdata/1M directory (which is now
      % the Illuminant directory.
      %
      %  But now we have decided to estimate the SPD from the illuminant image
      %  itself, which is in the illuminantHC.

      baseDir = '/Volumes/Farrell/Hyspex/HyspexData/Illuminant/1M';
      illFile = sprintf('%s/illSPD_%s.mat',baseDir,saveNames{ii});
      foo = load(illFile);
      plotRadiance(foo.wave,foo.illSPD/1.05);
%}
