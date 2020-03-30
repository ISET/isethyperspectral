% s_ mccWhiteFromHyspex
%
% Henryk measured the reflectance spectra of one of our MCC targets all the
% way out to 1000 nm.  The data in macbethChart contains the 24 chips.
% We pulled out the white one to use for illuminant correction.
%
% This is the actual chart we used in the experiments.
%
% We seem to be using these for our infrastructre
%
% See also
%   macbethReadReflectance 

%% Initialize
ieInit

%% The spectral reflectance of the MCC 
[mcc,wave] = ieReadSpectra('macbethChart');
% Number 4 is the white one.
% plot(mcc.wavelength,mcc.data)

%% Not sure why this is here. It plots and saves the hyperspectral white surface

mccWhite.wavelength = wave;
mccWhite.reflectance = mcc(:,4);

ieNewGraphWin;
plot(mccWhite.wavelength,mccWhite.reflectance);
xlabel('Wave'),ylabel('Reflectance'); grid on

%%
save mccWhite mccWhite

%%