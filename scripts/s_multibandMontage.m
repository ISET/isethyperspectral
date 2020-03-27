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
%   insertInImage, sceneThumbnail

%%  Find the files
baseDir = '/Volumes/Farrell/MultispectralDataOnTheWeb';

thumbSize = 384;
%% 2004 data
%
chdir(fullfile(baseDir,'2004','ISET Scenes'));
files = dir('*.mat');
matFiles = dir('*.mat');
nFiles = numel(matFiles);

for ii=1:nFiles
    scene = sceneFromFile(matFiles(ii).name,'multispectral');
    sceneThumbnail(scene,'row size',thumbSize,...
        'force square',true, ...
        'font size',16);
end

%% Now assemble the thumbnails into a montage
pngFiles = dir('*.png');
nFiles   = numel(pngFiles);

% Load up the thumbnails into an image stack
imageStack = uint8(zeros(thumbSize,thumbSize,nFiles));
for ii=1:nFiles
    rgb = imread(pngFiles(ii).name);
    lum = mean(rgb,3);
    lum = lum * (128/mean(lum(:)));
    imageStack(:,:,ii) = uint8(lum);
end

montage = imageMakeMontage(imageStack,[],[],0.5);

ieNewGraphWin;
% Save as JPG so it doesn't conflict with the PNG above.
imwrite(montage,'montage.jpg');
img = imread('montage.jpg'); 
imshow(img); colormap(gray); axis image

%% 2008, 2009 could go here

%% END
