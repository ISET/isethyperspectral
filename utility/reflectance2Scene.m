% ieConvertReflectance2MultiSpectralImage
%
% Useful for scenedata repository, converting reflectances into scene
% radiance.
% We use a default illuminant of D65.

%% Params
wave = 400:10:720;
nBasis = 6;

%%
for scenenum=1:8
    rFile=['hamamatsu',num2str(scenenum)]
    
    if scenenum==5
        wave=400:10:710;
    else
        wave=400:10:720;
    end
    
    tmp = load(rFile);
    
    subSample = 1;
    img = tmp.reflectances(1:subSample:end,1:subSample:end,:);
    % figure(2); imagesc(sum(img,3)); axis image; colormap(gray(256));

    % Illuminant in energy units
    illuminant.data = vcReadSpectra('D65',wave);
    illuminant.wavelength = wave;
    illuminant.comment = 'D65';
    illuminantP = Energy2Quanta(wave,illuminant.data);

    % Convert reflectances to photons
    for ii=1:size(img,3)
        img(:,:,ii)= img(:,:,ii)*illuminantP(ii);
    end

    % basis.basis * coef are reflectances between 0 and 1
    % If we want to express them as photons, we would need to multiply the
    % basis functions, say, by the illuminant in photons
    [coef,basis,imgMean] = mcCreateMultispectralBases(img,wave,nBasis);

    % vcNewGraphWin; plot(basis.wave,basis.basis)


    % We need to scale the illuminant level so that the peak reflectance in the
    % scene is 1.0 or a little less.

    fullName =   [rFile,'-photons.mat'];
    comment = sprintf('Started as reflectance file %s',rFile);

    fName = ieSaveMultiSpectralImage(fullName,coef,basis,comment,imgMean,illuminant);
    
%     scene = sceneFromFile(fName,'multispectral');
%     vcAddAndSelectObject(scene); sceneWindow;
end