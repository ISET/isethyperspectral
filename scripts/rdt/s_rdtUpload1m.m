%% Publish faces at 1m to Maven archive

%% 
ieInit

%%
rd = RdtClient('isetbio');
rd.crp('/resources/scenes/hyperspectral/stanford_database/faces1m');

rd.credentialsDialog;

%% Point at the folder containing the data
folder = '/Volumes/G-DRIVE mobile with Thunderbolt/Hyspex/Data/Faces_1meter/VNIR/output';

%% Put the scene.mat files 
rd.publishArtifacts(folder,'version','20160423','type','mat');

%% Have a look
rd.openBrowser;

%% The jpg were already created.  Put them up.  In the 3M case, we create them too

% This routine should be able to show progress
rd.publishArtifacts(folder,'version','20160423','type','jpg');

%% Have a look
rd.openBrowser;

%%
