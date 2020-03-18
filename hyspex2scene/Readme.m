%% The properties of the Hyspex data and the analysis of the data
%
%     See <http://www.hyspex.no/> for a description of the Hyspex device
%
%
%% Hyspex data
%
% The Hyspex data we read are stored in two files with these extensions:
%
%   *rad.img - the measurements, which are uncalibrated (relative) spectral radiance
%   *rad.hdr - the information necessary to convert the img data to spectral
%          radiance with units of
%
% There are also data with the extension 
%
%    *.hyspex.  
%
% We have 'Raw Data' directories where we store these hyspex images.  The
% files in the 'Raw Data' were converted into spectral radiance data files
% with units using software that Torbjorn had.
%
%% Data processing
%
% The processing of these data are in the scripts in the directory
% hyspex2Scene.  Such as s_hyspexFaces1M.m, etc. It is best to understand
% the processing by reading those scripts.  We include some general notes
% at the end of this file.
%
%% File naming
%
% There are a lot of measurement files.  They have long names.  We assigned
% them more convenient names. The correspondence is stored in a data file
% (hyspexFilenames.mat). To use this file, you can run
%
% load('hyspexFilenames')
% hyspex = 
%            faces: [1x1 struct]
%     facecloseups: [1x1 struct]
%            fruit: [1x1 struct]
%          outdoor: [1x1 struct]
% 
%% Illuminant notes
%
% In some cases (faces) the name of an illuminant file is also stored in
% hyspexFilenames.mat.  This is the name of a separate Hyspex file that has
% the whiteboard image used for estimating the illuminant spd and the
% variation of the illuminant spd across space.
% 
%   hyspex.faces.vnir =
%           names: {46x2 cell}
%      illuminant: 'Face test 1_VNIR_1600_SN0004_35000_us_2x_2011-12-12T155130_raw_rad'
%
% In other cases (faces1M, fruit, Landscape) there is no illuminant
% file, and we estimate the illuminant spd using a white surface in the
% scene.
%
% To process many of the images we needed to select a region of interest.
% We store that ROI in ????
%
% In some of our Hyspex sessions, we were able to place a white board
% across the area we scanned.  We use the radiance from the white
% board to estimate the illumination in the scene.
%
% ALERT:
%
%   In the outdoor scenes, we could not put a white board across the vista
%   and we cannot assume that the lighting is uniform. We will estimate the
%   spectral power of an illuminant falling on a white board in the scene
%   and store that But it is important to remember that using this
%   illuminant to estimate reflectance is .... well, not so good.  It is
%   only based on a white board in a small portion of the scene.
%
% Copyright ImagEval Consultants, LLC, 2012.


%% Auxiliary (out of date)
%
% We created a file that contains the parameters we used to create
% the ISET files.   The file has '_aux' appended to the isetFileName.
%
% This auxiliary file contains
%  'hyspexFileName :         the name of the Hypsex img file
%  'isetFileName':           the name of the ISET file
%  'sceneRect' :             the rect of the Hypex.img file that we cropped
%  'illuminantFileName':     the name of the Hyspex illuminant file. Note that
%                           if an illuminantFilename does not exist, then
%                           we know tha the illuminant rect was a portion
%                           of the image and not a portion of a separate
%                           file. This also means that we did NOT correct
%                           for non-uniform scene illumination
%  'illuminantRect':         the portion of the image (or illuminant file) that was
%                           used to estimate the illuminant
%  'illuminantScaleFactor':  in some cases we had to scale the illuminant
%                           because the maximum reflectance for objects was
%                           greater than 1.  This indicates that our
%                           illuminant estimates were off by a scale
%                           factor. This can happen when we use a surface
%                           in the scene (say a white or gray surface) to
%                           estimate the scene illuminant spd. Since we do
%                           not know how reflective the surface was, we can
%                           easily by off by a scale factor. While we had
%                           to make this adjustment by hand, this
%                           information is stored so that we can generate
%                           the ISET file from the original Hyspex data
%                           files.
%  'comment' (optional)
%

%% PROCESSING STEPS (General, but out of date)
% 
% TO UNDERSTAND THESE PROPERLY READ THE s_hyspex* scripts mentioned above.
%
% It is best to read the scripts in the relevant directories to see the
% most recent processing.  These notes are old and not always followed for
% faces3M and faces1M.
%
% To read the Hyspex data, we need to have 2 files with the same name but
% with *.hdr and *.img extensions.
%
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
%%