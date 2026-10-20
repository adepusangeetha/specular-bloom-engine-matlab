function [imgBloom, specularMask, diffusedField] = applyBloomEngine(inputImage, threshold, bloomGain, sigmaTight, sigmaWide)
% APPLYBLOOMENGINE Simulates optical lens diffusion and specular bloom.
%
% Syntax:
%   imgBloom = applyBloomEngine(inputImage)
%   imgBloom = applyBloomEngine(inputImage, threshold, bloomGain)
%   [imgBloom, specularMask, diffusedField] = applyBloomEngine(inputImage, threshold, bloomGain, sigmaTight, sigmaWide)
%
% Inputs:
%   inputImage   - Input RGB or grayscale image (uint8 or double)
%   threshold    - Normalized luminance cutoff [0.0, 1.0] (default: 0.78)
%   bloomGain    - Multiplier for radiance intensity (default: 1.5)
%   sigmaTight   - Standard deviation for core gleam PSF (default: 5)
%   sigmaWide    - Standard deviation for ambient glow PSF (default: 25)
%
% Outputs:
%   imgBloom      - Final composited image matching input data type
%   specularMask  - Logical binary mask of isolated highlights
%   diffusedField - Isolated multi-scale Gaussian optical field

%% 1. Default Argument Handling
if nargin < 2 || isempty(threshold)
    threshold = 0.78;
end
if nargin < 3 || isempty(bloomGain)
    bloomGain = 1.5;
end
if nargin < 4 || isempty(sigmaTight)
    sigmaTight = 5;
end
if nargin < 5 || isempty(sigmaWide)
    sigmaWide = 25;
end

%% 2. Defensive Checks & Type Normalization
originalClass = class(inputImage);

if ~isa(inputImage, 'double')
    imgBase = im2double(inputImage);
else
    imgBase = inputImage;
end

%% 3. Luminance Calculation (ITU-R BT.601)
if size(imgBase, 3) == 3
    imgLuminance = rgb2gray(imgBase);
else
    imgLuminance = imgBase;
end

%% 4. Specular Highlight Isolation
specularMask = imgLuminance >= threshold;
specularHighlights = imgBase .* specularMask;

%% 5. Dual-Scale Optical Diffusion (Point Spread Function)
glowTight = imgaussfilt(specularHighlights, sigmaTight);
glowWide  = imgaussfilt(specularHighlights, sigmaWide);
diffusedField = (0.65 * glowTight) + (0.35 * glowWide);

%% 6. Additive Blending & Dynamic Range Clamping
imgBloomDouble = min(imgBase + (bloomGain * diffusedField), 1.0);

%% 7. Restore Original Data Type
if strcmp(originalClass, 'uint8')
    imgBloom = im2uint8(imgBloomDouble);
else
    imgBloom = imgBloomDouble;
end
end