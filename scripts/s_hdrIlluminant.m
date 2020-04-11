%% s_sceneIlluminantImage
%
% Separate the Feng Office scene into an illuminant image format with a
% bright and dark part.
%
% Copyright Imageval, LLC, 2014

%%
s_initISET

%% isetdata
isetData = '/Users/wandell/Github/isetdata';

%% Loaded up the good hdrs data
% fname = fullfile(isetData,'hdr','EurasianFemale_Office.mat');
fname = fullfile(isetData,'hdr','EurasianFemale_shadow.mat');
scene = sceneFromFile(fname,'multispectral');
scene = sceneAdjustLuminance(scene,500);
% vcAddObject(scene); sceneWindow;


%%  Have a look at the luminance image
vcNewGraphWin;
l = sceneGet(scene,'luminance');
imagesc(l)

%% Find a value that separates the bright and dark parts of the image

% Look at the histogram to make a guess.
hist(l(:),100)

% %Here is your guess for this image
val = 400;

% Find the bright region, and blur it a bit
lB = double((l>val));
g = fspecial('gaussian',[9 9],5);
lB = convolvecirc(lB,g);
lB = (lB > 0.6);
% Have a look
vcNewGraphWin;
imagesc(lB)

%% Dark part of the image is the complement
lD = 1 - lB;

% Have a look
vcNewGraphWin;
imagesc(lD)

%% We pick out the white wall for interior illuminant
% I want a locs to rect function

rect = [370 20 10 10];   % White scene
photons = sceneGet(scene,'roi mean photons',vcRect2Locs(rect));
wave = sceneGet(scene,'wave');
vcNewGraphWin; plot(wave,photons);


% These are the spectral power distributions from the light and dark parts
% of the image.  They don't have to be the same.  You have to figure these
% out for each image.
il = illuminantCreate;
il = illuminantSet(il,'wave',dark.wavelength);
il = illuminantSet(il,'energy',dark.office);
vcNewGraphWin;
plot(illuminantGet(il,'wave'),illuminantGet(il,'photons'));

% Window illuminant
wil = illuminantCreate('blackbody',wave,7000,5000);


% Have a look at the illuminant spectra
vcNewGraphWin;
plot(bright.udata.wave,bright.udata.photons);

vcNewGraphWin;
plot(dark.udata.wave,dark.udata.photons);

%% Now, go build the illuminant structure

sz = sceneGet(scene,'size');
nWave = length(dark.udata.wave);
b = repmat(bright.udata.photons(:),[1,sz]);
b = permute(b,[2,3,1]);
d = repmat(dark.udata.photons(:),[1,sz]);
d = permute(d,[2,3,1]);

% Ratio to scale for dark and light regions
rD = 1.0; % (7.1694e+13/6.1407e+13)*0.9;
rB = 0.9; % 5.4176e+16/6.1826e+16;
illSPD = zeros(size(sceneGet(scene,'photons')));
for ii=1:nWave
    illSPD(:,:,ii) = b(:,:,ii).*lB*rB + d(:,:,ii).*lD*rD;
end

illuminant = illuminantCreate;
illuminant = illuminantSet(illuminant,'photons',illSPD);
illuminant = illuminantSet(illuminant,'name','Office scene');

%% Attach it to the scene and see how well you did

scene2 = sceneSet(scene,'illuminant',illuminant);
vcAddObject(scene2);
sceneWindow;

%% Save your work with the right function for saving multispectral scenes
% ieSaveMultiSpectralImage

%% END

