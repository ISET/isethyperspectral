%%  Downloading all the HDR images from the RDT
%
% s_rdtDownloadHDR
%
% See also
%

%%
ieInit

%% Create the rdt object and open browser
rd = RdtClient('isetbio');

%% Our files are all version '1' at this point.

rd.crp('/resources/scenes/hdr'); % change remote path

% Problems here:
% Currently only returns 30 elements
% 'type' is not right because it says jpg when there are nef and pgm files
% as well
a = rd.listArtifacts;  
fprintf('Found %d artifacts\n',numel(a));

%% Download the files to the Farrell volume

for ii=1:numel(a)
    % When there is no return value, the file is simply written out.
    rd.readArtifact(a(ii),'type','mat',...
        'destinationFolder', '/Volumes/Farrell/HDR/');
end

%% END
