% s_CreateISETfromHyspex_2016
% 
% This script creates a files containing spectral scene radiance and
% illuminant spectral power distribution The original data were collected
% using the Hyspex hyperspectral imaging system (see http://www.hyspex.no/)
%
% see s_hyspexFilenamesCreate.m, s_hyspexCreateRects.m
%     s_viewISETsceneFiles.m

% Copyright ImagEval Consultants, LLC, 2013

%% BACKGROUND
%
% The Hypsex data are stored in a directory called "HyspexDatabase"
% Each scene has two files.
% One file has the hyperspectral data and has a .img extension
% Another file has information about the hyperspectral data and has a
% *.hdr extension
%
% We generated Matlab files from the original Hyspex files that can be read into 
% Matlab using "sceneFromFile" in ISET.  We will refer to these files as
% ISET files.  They are the Matlab files generated from the original Hyspex
% data. These files are stored in a directory called
% "isetHyperspectralDatabase"
%
%% PURPOSE: 
% The purpose of this script is to recreate the Matlab
% hyperspectral files (so-called isetFiles) from the original Hyspex data
% files. We stored the parameters that we used to create the isetFiles in
% several files so that we can do recreate the process if necessary. 
%
%% FILES
% First, there is a file with the names of the Hyspex
%   This file is called hyspexFilenames.mat
%   In some cases (faces) the name of an illuminant file is also stored in
%   hyspexFilenames.mat.  This is the name of a separate Hyspex file that has the
%   whiteboard image used for estimating the illuminant spd and the
%   variation of the illuminant spd across space. 
%   In other cases (facesCloseup, fruit, Outdoor) there is no illuminant
%   file, and we estimate the illuminant spd using a white surface in the
%   scene.

% Second, we created a file with the rectangular coordinates of the area we
% cropped from the original Hyspex data files 
%   This file is has the name of the original Hyspex data file with a -sRect.mat extension
%   It is stored in the same directory as the original Hyspex data files
% 
% Third, we created a file that contains the parameters we used to create
% the ISET files.   The file has '_aux' appended to the isetFileName.
% This auxiliary file contains
% 'hyspexFileName :         the name of the Hypsex img file
% 'isetFileName':           the name of the ISET file 
% 'sceneRect' :             the section of the Hypex img file that we cropped
% 'illuminantFileName':     the name of the Hyspex illuminant file. Note that
%                           if an illuminantFilename does not exist, then we know tha the illuminant
%                           rect was a portion of the image and not a portion of a separate file.
%                           This also means that we did NOT correct for non-uniform scene
%                           illumination
% 'illuminantRect':         the portion of the image (or illuminant file) that was
%                           used to estimate the illuminant
% 'illuminantScaleFactor':  in some cases we had to scale the illuminant
%                           because the maximum reflectance for objects was greater than 1.  This
%                           indicates that our illuminant estimates were
%                           off by a scale factor. This can happen when we
%                           use a surface in the scene (say a white or gray
%                           surface) to estimate the scene illuminant spd.
%                           Since we do not know how reflective the surface
%                           was, we can easily by off by a scale factor.
%                           While we had to make this adjustment by hand,
%                           this information is stored so that we can
%                           generate the ISET file from the original Hyspex
%                           data files.
% 'comment' (optional) 

%% PROCESS
% Having stored this information, we can now read the Hyspex data and
% automatically create the ISET scene data files.
% This script reads in Hyspex data and creates an ISET Scene data
% structure.  The output is saved in a format that can be read by
% sceneFromFile in ISET.
%
% The Hyspex and ISET data are stored in a base directory, say F:/.  Then
% inside that base directory, there are two directory trees.  One directory
% contains all the Hyspex files and the other parallel directory contains
% the ISET data files that are read by sceneFromFile.
%
% PROCESSING STEPS
%
% To read the Hyspex data, we need to have 2 files with the same name but
% with *.hdr and *.img extensions.
% We also have a *-sRect.mat file that contains the sceneRect.
% We ran  s_hyspexCreateRects to create the *-sRect.mat files
% In a few cases we have a *-iRect.mat file that contains the
% illuminantRect.
%
% Illuminant SPD
%   1. Read in the Hyspex file for the scene data that has the Lambertian
%   surface we use to measure the illuminant 
%   2. Read the data from the sceneRect or illuminantRect portion and
%   estimate the spd of the illumination.
%
%  Scene
%   3. Read in the Hyspex scene radiance data (energy units)
%   4. Crop using the saved sceneRect
%   5. Convert the scene to photons
%   6. Estimate the SNR in each waveband and decide which wavelengths to
%   retain (both for the scene and illuminant)  Not yet implemented.
%   7. Scale the mean illuminant level so that the reflectances are
%   between 0 and 1.
%   8. Validate that the reflectances make sense
%       ** For outdoor scenes illuminant and reflectances cannot be
%       properly estimated because we do not know what the scene illuminant
%       is at each point in the scene.  We plan to write a routine that
%       introduces space-varying illumination to bring the reflectances
%       into a reasonably normal range.
%
% Data storage and compression
%   9. Store scene and illuminant in an ISET file using sceneToFile.  We
%   store one version uncompressed and one compressed (basis functions and
%   basis coefficients)
%
% EXPERIMENT NOTES
%
% In some of our Hyspex sessions, we were able to place a white board
% across the area we were scanning and use the radiance from the white
% board to estimate the illumination.
%
% In the outdoor scenes, we could not put a white board across the vista
% and we cannot assume that the lighting is uniform. We will estimate the
% spectral power of an illuminant falling on a white board in the scene and
% store that But it is important to remember that using this illuminant to
% estimate reflectance is .... well, not so good.  We plan to write code to
% generate a space-varying illuminant that is consistent with the scene.
%
% Example:
%
% See also:  hcReadHyspex,  hcimage, hcimageRotateClip
%
% Copyright ImagEval Consultants, LLC, 2012.

%% Initialize
s_initISET

% These are machine dependent.  We could call this script setting up these
% parameters.
% hyspexBase = 'F:\HyspexDatabase';
% isetHyperspectralDir   = 'F:\isetHyperspectralDatabase';
hyspexBase = '/Volumes/Farrell/Hyspex';
isetHyperspectralDir   = '/Volumes/Farrell/isetHyperspectralDatabase'; 
% load hyspexFilenames
load '/Volumes/Farrell/Hyspex /STANFORD HYPERSPECTRAL DATA/Matlab Software/Hyperspectral/database/hyspexFilenames'

fileList = hyspex.facecloseups.vnir;
hyspexDir = fullfile(hyspexBase,'FacesCloseup','VNIR');
isetDir = fullfile(isetHyperspectralDir,'FacesCloseup','VNIR');
illuminantFileName = hyspex.facecloseups.vnir.illuminant;

% fileList = hyspex.fruit.vnir;
% hyspexDir = fullfile(hyspexBase,'Fruit','VNIR');
% isetDir = fullfile(isetHyperspectralDir,'Fruit','VNIR');
% illuminantFileName = hyspex.fruit.vnir.illuminant;

% BE SURE TO COMMENT ON THE LINES THAT CLIP WAVELENGTH > 950
% fileList = hyspex.fruit.swir;
% hyspexDir = fullfile(hyspexBase,'Fruit','SWIR');
% isetDir = fullfile(isetHyperspectralDir,'Fruit','SWIR');
% illuminantFileName = hyspex.fruit.swir.illuminant;

% fileList = hyspex.outdoor.vnir;
% hyspexDir = fullfile(hyspexBase,'Outdoor','VNIR');
% isetDir = fullfile(isetHyperspectralDir,'Outdoor','VNIR');
% illuminantFileName = hyspex.outdoor.vnir.illuminant;

%% Loop on files.
for ii=1:size(fileList.names,1)
    hyspexFileName     = fileList.names{ii,1};
    isetFileName       = fileList.names{ii,2};
    hyspexFileFullPath = fullfile(hyspexDir,hyspexFileName);
    
    %% Read the rect, crop and save the image
    if ~exist([hyspexFileFullPath,'.img'],'file')
        error('Could not find %s\n',[hyspexFileFullPath,'.img']);
    else
        fprintf('Reading ...');
        [img,info] = hcReadHyspex([hyspexFileFullPath,'.img']);
        fprintf('done\n');
    end
    
    % This loads the sceneRect
    load([hyspexFileFullPath,'-sRect']);
    sceneHC = hcimageCrop(img,sceneRect,80);
    hcimage(sceneHC);
    
    %% Estimate the illuminant
    
    if isempty(illuminantFileName)
        % If the illuminant file is empty, we use a portion of the scene file
        % and estimate only the illuminant SPD.
        [illuminantHC, illuminantRect] = hcimageCrop(img,[],80);
        round(illuminantRect)
    else
        % If there is an illuminant file, we use the same rect as we chose for
        % the scene and both estimate the SPD and divide the scene intensity
        % point by point, depending on the mean value in this region.
        illuminantFile = [fullfile(hyspexDir,illuminantFileName),'.img'];
        if ~exist(illuminantFile,'file')
            error('Could not find %s\n',illuminantFile);
        else
            [img,info] = hcReadHyspex(illuminantFile);
        end
        [illuminantHC, illuminantRect] = hcimageCrop(img,sceneRect);
        
        % The board has some scratches, so we blur it
        spatialSpread = 15;
        illuminantHC = hcBlur(illuminantHC,spatialSpread);
        hcimage(illuminantHC);
        
        [illScale, meanSPD] = hcIlluminantScale(illuminantHC);
        % vcNewGraphWin; imagesc(illScale); colormap(gray)
        
        % Scale the image by the illuminant scale factor
        w = size(sceneHC,3);
        h = waitbar(0,'Illuminant scaling');
        for jj=1:w
            waitbar(jj/w,h);
            sceneHC(:,:,jj) = double(sceneHC(:,:,jj)) ./ illScale;
        end
        close(h)
    end
    
    %% The VNIR data for outdoor are noisy beyond 950. For faces, beyond 950  Clip those wavelength values.
    % DON'T DO THIS FOR SWIR DATA
    maxWave = 950;
    [v,idx] = min(abs(maxWave - info.wavelength));
   wave = info.wavelength(1:idx);
    illuminantHC = illuminantHC(:,:,1:idx);
% if SWIR runs this:
%  wave=info.wavelength;

    
    %% Calculate the illuminant SPD
    hcXW = RGB2XWFormat(illuminantHC);
    
    % Hyspex units are ()? Guessing microwatts per square meter per steradian
    meanIllEnergy = mean(hcXW,1);
    illuminant = illuminantCreate;
    illuminant = illuminantSet(illuminant,'wave',wave);
    
    % Scaling energy based on guess, above
    illuminant = illuminantSet(illuminant,'energy',meanIllEnergy);
    
    % Show us what we have
    vcNewGraphWin([],'tall');
    subplot(2,1,1), plot(wave,illuminantGet(illuminant,'energy'));
    xlabel('Wavelength'); ylabel('Energy (watts/sr/nm/m2)');
    
    subplot(2,1,2), plot(wave,illuminantGet(illuminant,'photons'));
    xlabel('Wavelength'); ylabel('Photons (photons/sr/nm/m2)');
    
    
    %% Rotate the scene and convert the units to double
    clipPrctile = 100.; nRot = 1;
    [sceneHC,cPixels] = hcimageRotateClip(sceneHC,clipPrctile,nRot);
    [r,c,w] = size(sceneHC);  % Store cropped size for later use
    
    % vcNewGraphWin; imagesc(cPixels)
%     hcimage(sceneHC);
    
    %% Limit waveband to 950nm
    % DON'T DO THIS FOR SWIR
    maxWave = 950;
    [v,idx] = min(abs(maxWave - info.wavelength));
    wave = info.wavelength(1:idx);
    sceneHC = sceneHC(:,:,1:idx);
    
    %% Test SNR in each waveband
    
    % Put in XW format to estimate photon level
    [sceneHC,row,col] = RGB2XWFormat(sceneHC);
    sceneHCPhotons = Energy2Quanta(wave,sceneHC')';
    
    % Do testing here ...
    meanWave = mean(sceneHCPhotons);
    vcNewGraphWin; plot(wave,meanWave)
    
    % Put the data back into the RGB format
    sceneHC = XW2RGBFormat(Energy2Quanta(wave,sceneHC')',row,col);
    
    %% Create the scene
    scene = sceneCreate;
    scene = sceneSet(scene,'wave',wave);
    scene = sceneSet(scene,'photons',sceneHC);
    scene = sceneSet(scene,'illuminant',illuminant);
    
    %% Some checking
    
    % Look at it
    %vcAddAndSelectObject(scene); sceneWindow;
    vcReplaceAndSelectObject(scene); sceneWindow;  %replace existing scene to save memory
    
    % Check reflectance range
    reflectance = sceneGet(scene,'reflectance');
    fprintf('Reflectance range: [%.2f, %.2f]\n',min(reflectance(:)), max(reflectance(:)));
    if min(reflectance(:)) < 0, warning('Low reflectance'); end
    if max(reflectance(:)) > 1, warning ('High reflectance'); end
    
    test = sceneGet(scene,'mean luminance');
    fprintf('Mean luminance %f cd/m2\n',test);
    if test > 1000, warning('High mean luminance'); end
    %     scene = sceneAdjustLuminance(scene,1000); for the outdoor scenes, we set mean luminance to be 1000
%     vcReplaceAndSelectObject(scene); 
    if test < 1, warning('Low mean luminance'); end
    
    test = mean(sceneGet(scene,'illuminant energy'));
    fprintf('Mean illuminant energy: %f watts/sr/nm/m2\n',test);
    if test > 100, warning('Illuminant energy too high'); end
    
    %%     
%     scene = sceneSet(scene,'name','Stanford Memorial Church');
%     scene = sceneAdjustLuminance(scene,1000);
%     vcReplaceAndSelectObject(scene); 
% note that Memorial Church was too big to save, could only save compressed
% file
    
    %% Save an auxiliary file with all the parameters selected here.
    
    % The parameters include illuminant and scene rects, the illuminant
    % structure in an auxiliary illuminant file and the name of the hyspex
    % files used for the scene and illuminant.
    
    % In principle we can reconstruct the data from the information stored
    % in this auxiliary file.  We open the hyspexName, read in the data
    % from this file, and go.
    auxFileName  = fullfile(isetDir,[isetFileName,'_aux']);
    
    % Hyspex file and associated iset file
    % The rect from the scene.  If there is an illuminant file, use the
    % sceneRect to find the white region.  If the illuminant file is empty,
    % then use the illuminantRect in the hyspexFile to find the
    % white/illuminant region.
    save(auxFileName,'hyspexFileName','isetFileName','sceneRect','illuminantFileName','illuminantRect');
    
    %% Save the scene in two formats
    
    % Uncompressed format
    oFullPath = fullfile(isetDir,isetFileName);
    cFlag = [];
    sceneToFile(oFullPath,scene,cFlag);
    % test=sceneFromFile(oFullPath,'multispectral');
    % vcAddAndSelectObject(test); sceneWindow
    
    % Compressed format with basis files
    cFlag = 0.999;
    oFullPath = fullfile(isetDir,'Compressed',[isetFileName,'_Cx']);
    sceneToFile(oFullPath,scene,cFlag);
%     test=sceneFromFile(oFullPath,'multispectral');
%     vcAddAndSelectObject(test); sceneWindow
end

%% End
