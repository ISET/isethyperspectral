%% Read from the RDT for the faces1m
%
% This script downloads all the faces 1m data, saves them locally, and
% extracts the sceneRect.  The goal is to make a backup of the RDT data
% that we trust and to save the sceneRect separately so we can rerun the
% calculation based on the data stored on the local 'Farrell' disk drive.
%
%  Similar script for the other types should work (e.g., faces3m).  THere
%  may be important differences, however, in terms of how the outdoor or
%  pig or art data were processed.
%
% Wandell
%

%% Initialize and get the list of 1M face data
ieInit

rd = RdtClient('isetbio');
rd.crp('/resources/scenes/hyperspectral/stanford_database/faces1m');
faces1m = rd.listArtifacts('print',true,'type','mat');

rectDir = fullfile(hyspexRootPath,'local','scenerects');
if ~exist(rectDir,'dir'), mkdir(rectDir); end

sceneDir = fullfile(hyspexRootPath,'local','scenedata');
if ~exist(sceneDir,'dir'), mkdir(sceneDir); end

curDir = pwd;

%% Read the sceneRect from each of the saved files

%{
  data = rd.readArtifact(faces1m(1));
  thisRect = round(data.sceneRect);
%}

% Download the scenes and pull out the sceneRect as a separate file.  This
% will let us back up the scene data that was online and also more easily
% recompute because for the faces all we need is the sceneRect.
for ii=20:length(faces1m)
    fname = faces1m(ii).artifactId;
    
    chdir(sceneDir);
    fprintf('Reading %s ...',fname);
    data = rd.readArtifact(faces1m(ii));
    fprintf('\n');
    ieSaveMultiSpectralImage(fname,data.mcCOEF,data.basis,...
        data.comment,data.imgMean,data.illuminant,...
        data.fov,data.dist,fname);
    % scene = sceneFromFile(fname,'multispectral');
    % sceneWindow(scene);
    
    chdir(rectDir)
    try
        sceneRect = round(data.sceneRect);
        save(fname,'sceneRect');
    catch
        fprintf('No scene rect for %d, %s\n',ii, fname);
    end
        
end

%%
chdir(curDir)

%% END