%% s_ illuminantEstimate1M
%
%  ** 
%     Potentially deprecated - was used before we had spatiochromatic
%     illuminant representations
%  **
%
% Read the face closeup images (1M).  For each face scene there is a white
% target.  The user finds the rect with the white surface.  We assume the
% white surface has the same reflectance at all wavelengths so its spectral
% radiance is the illuminant spectral radiance.
%
% We save these estimates in files named
%
%   illSPD_filename.mat
%
% These are now stored on the Farrell disk drive in
%  
%      HyspexData/Illuminant/1M
%
% During the processing we noticed that there are two groups of files, one
% in which the maximum spd is 0.32 and the other around 0.21. Not sure why
% there are two groups and why they differ.
%
% We are considering putting this functionality into the s_hyspexFaces1M.m
% script rather than separating it here
%
% JEF/BW  March 17, 2020

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

%% Here are three arbitrary examples
% lst = [5,10,15];

lst = 1:25 ; % [2,4,6,8,10,12,14,16,18,20,22,24];
illFile = cell(1,length(lst));
fprintf('Illuminant levels\n')
for ii=1:length(lst)
   hyspexFileName = fileNames{lst(ii)};
    
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
    title(lst(ii));
    
    illFile{ii} = sprintf('illSPD_%s.mat',saveNames{ii});
    illFile{ii} = fullfile(hyspexRootPath,'hcdata','1M',illFile{ii});
    save(illFile{ii},'wave','illSPD','illRect');
    fprintf('%d %s %f\n',ii,illFile{ii},max(illSPD(:)));
end

%% Compare the saved files

vcNewGraphWin;
for ii=1:length(lst)
    load(illFile{ii})
    plot(wave,illSPD);
    hold on
end
grid on

%%
vcNewGraphWin;
for ii=1:length(lst)
    load(illFile{ii})
    plot(wave,illSPD/max(illSPD(:)));
    hold on
end
grid on

%%