%% Publish faces at 3m to Maven archive

%% 
ieInit

%%
rd = RdtClient('isetbio');
rd.crp('/resources/scenes/hyperspectral/stanford_database/faces3m');

rd.credentialsDialog;

%%
folder = '/Volumes/G-DRIVE mobile with Thunderbolt/Hyspex/Data/Faces_3meters/VNIR/output';

%%
rd.publishArtifacts(folder,'version','20160419');

%% Create 
rd.openBrowser;

%% Loop through the scenes and create a JPG

sList = dir('output/*.mat');
for ii=1:length(sList)
    fname = sList(ii).name;
    s = sceneFromFile(fullfile('output',fname),'multispectral');
    rgb = sceneGet(s,'rgb');
    % image(rgb); axis image
    [p,n,e] = fileparts(fname);
    imwrite(rgb,fullfile('output',[n,'.jpg']),'jpg');
end

%%  Put the jpg files up there

% This routine should be able to show progress
rd.publishArtifacts(folder,'version','20160419','type','jpg');

%%
rd.openBrowser;
