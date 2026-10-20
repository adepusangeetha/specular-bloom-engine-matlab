%% CINDERELLA BLOOM ENGINE — TUNED FOR CRYSTAL GLINT
clear; close all; clc;

inputImg = imread('glass_asset.jpg');

% Higher threshold: ignores the white dress, isolates only sparkly glints
tunedThreshold = 0.90; 

% Gain and kernel tuned for crisp sparkle
sparkleGain = 1.8;
sigmaTight  = 3;   % Sharp gleam on crystal facets
sigmaWide   = 14;  % Soft localized halo

% Apply the Bloom Engine
outputBloom = applyBloomEngine(inputImg, tunedThreshold, sparkleGain, sigmaTight, sigmaWide);

% Save side-by-side comparison
comparison = [inputImg, outputBloom];
imwrite(comparison, 'cinderella_slipper_tuned.png');
fprintf('Success! cinderella_slipper_tuned.png saved.\n');