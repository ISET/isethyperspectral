%%  Downloading all the HDR images from the RDT
%
% s_rdtDownloadHDR
%
% See also
%

%%
ieInit

%%
chdir('/Volumes/Farrell/HDR');
files = dir('*.mat');
fprintf('Found %d files\n',numel(files));

%% Inspect the files, one by one.

for ii=1:numel(files)
    % When there is no return value, the file is simply written out.
    scene = sceneFromFile(files(ii).name,'multispectral');
    if ii==1
        sceneWindow(scene);
        % sceneSet(scene,'display mode','hdr');
    else
        ieReplaceObject(scene);
        sceneWindow;
        % sceneSet(scene,'display mode','hdr');
    end
    
end

%% END
