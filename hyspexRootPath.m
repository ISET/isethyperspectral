function rootPath=hyspexRootPath()
% Return the path to the  hyperspectral (hyspex) root directory
%
% This function must reside in the directory at the base of the ISET
% directory structure.  It is used to determine the location of various
% sub-directories.
% 
% Example:
%   fullfile(hyspexRootPath,'data')
%

rootPath = which('hyspexRootPath');
rootPath = fileparts(rootPath);

end
