%% s_manchesterDownload
%
% Deprecated - this one relies on RDT, which we are no longer supporting.
% The other scripts download directly from the web.
%
% Example of how to download a scene from the Manchester database
%
% See also
%   s_manchesterConvert2002.m, s_manchesterConvert2004.m

%% Open the repository
rd = RdtClient('isetbio');
rd.crp('/resources/scenes/hyperspectral/manchester_database/2002');

a = rd.listArtifacts('type','mat');
sData = rd.readArtifact(a(1),'type','mat');

%%
scene = sceneFromBasis(sData);
scene = sceneSet(scene,'name','Manchester 2002 scene1');
ieAddObject(scene); sceneWindow;

%%
rd.crp('/resources/scenes/hyperspectral/manchester_database/2004');

a = rd.listArtifacts('type','mat');
sData = rd.readArtifact(a(1),'type','mat');

%%
scene = sceneFromBasis(sData);
scene = sceneSet(scene,'name','Manchester 2004 scene1');
ieAddObject(scene); sceneWindow;

%%