%% Save the Whiteboard image for the 1M (facescloseup) data
%
% JEF/BW Imageval LLC, 2016

%%
ieInit

% The data are on this drive.
wDir = '/Volumes/G-DRIVE mobile with Thunderbolt/Hyspex/Data/Faces_1meter/VNIR';
chdir(wDir);

%% Here is the set of file names and the illuminant file

load('hyspexFilenames');   % Loads hyspex variable 

% Start with the VNIR.  We may never do the SWIR.
theseFiles = hyspex.facecloseups.vnir;

%% Read the illuminant relative SPD

hyspexFileName = theseFiles.illuminant;

% The scaling parameter is in info.description{18}
hFile = [hyspexFileName,'.img'];
copyfile(hFile,fullfile(hyspexRootPath,'hcdata','Whiteboard1M.img'))

hFile = [hyspexFileName,'.hdr'];
copyfile(hFile,fullfile(hyspexRootPath,'hcdata','Whiteboard1M.hdr'))

%%