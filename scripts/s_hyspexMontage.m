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
%   s_hyspexFaces1M

%%  Find the files
dataDir = fullfile(hyspexRootPath,'local','landscape');
chdir(dataDir)
matFiles = dir('*.mat');
nFiles = numel(matFiles);

% The original images always have more rows than columns.  We pad here to
% make them this size.
row = 192;
col = 192;

%% There is a main file and a Params file.  Read only on the main files

% The thumbnails are all saved as 128 x 128
for ii=1:nFiles
    if  ~ieContains(matFiles(ii).name,'Params')
        fprintf('%s ...\n',matFiles(ii).name); 
        scene = sceneFromFile(matFiles(ii).name,'multispectral');
        
        rgb = sceneGet(scene,'rgb');
        [r,c,w] = size(rgb);
        
        % Preserve the aspect ratio
        newCol = round((row/r)*c);
        rgb = imresize(rgb,[row newCol]);
        
        % Pad to make square
        padSize = col - newCol;
        if padSize > 0
            rgb = padarray(rgb,[0 padSize],0.3,'post');
        elseif padSize < 0
            rgb = imcrop(rgb,[1 1 191 191]);
        end
        % ieNewGraphWin; imagescRGB(rgb); axis image
        
        parts = strsplit(matFiles(ii).name,'.');

        rgb = insertInImage(ieScale(rgb,1), @()text(2,8,parts{1}),...
            {'fontweight','bold','color','w','fontsize',9,...
            'linewidth',1,'margin',1,...
            'backgroundcolor',[0.5 0.5 0.5]});
        % ieNewGraphWin; imshow(uint8(mean(rgb,3)));
 
        pngName = [parts{1},'.png'];
        imwrite(rgb,pngName);
        fprintf('done\n');
    end
end

%% Now assemble the thumbnails into a montage
pngFiles = dir('*.png');
nFiles   = numel(pngFiles);

% Load up the thumbnails into an image stack
imageStack = uint8(zeros(row,col,nFiles));
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


%% END
