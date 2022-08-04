%% s_manchesterUpload
%
% Deprecated
%
% This is how we managed with RDT.  We no longer rely on that.
%

%% Open 
rd = RdtClient('isetbio');
rd.credentialsDialog;   % G No Bang 0 instead of o

%%  These are for 2002
rd.crp('/resources/scenes/hyperspectral/manchester_database/2002');
folder = fullfile(isetRootPath,'local','manchester','2002');
rd.publishArtifacts(folder,'type','mat');
rd.publishArtifacts(folder,'type','jpg');

rd.openBrowser;

%%  These are for 2004
rd.crp('/resources/scenes/hyperspectral/manchester_database/2004');
folder = fullfile(isetRootPath,'local','manchester','2004');
rd.publishArtifacts(folder,'type','mat');
rd.publishArtifacts(folder,'type','jpg');

rd.openBrowser;

%%