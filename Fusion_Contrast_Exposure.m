function [F, weight_map, contrast_map] = Fusion_Contrast_Exposure(I, scale)
save_path = 'F:\paper2\ADS_porposed\ADF_Dhruv\result_pic1\';
if nargin < 2, scale = 16; end

[H, W, ~, N] = size(I);
imgs = double(I) / 255;
imgs_gray = zeros(H, W, N);

% ---- 1. Grayscale ----
for i = 1:N
    imgs_gray(:,:,i) = im2gray(imgs(:,:,:,i));
end

% ---- 2. Dense SIFT (contrast map) ----
dsifts = zeros(H, W, 32, N, 'single');
for i = 1:N
    img = imgs_gray(:,:,i);
    ext_img = img_extend(img, scale/2 - 1);
    dsifts(:,:,:,i) = DenseSIFT(ext_img, scale, 1);
end

contrast_map = zeros(H, W, N);
for i = 1:N
    contrast_map(:,:,i) = sum(dsifts(:,:,:,i), 3);  % USELESS for weight
end
imwrite(mat2gray(contrast_map(:,:,1)), fullfile(save_path, 'contrast_map_Pan.jpg'));
% ---- 3. Luminance weight ----
luminance_map = imgs_gray;   % directly use grayscale

% ---- 4. Exposure weight ----
exposure_map = ones(H, W, N);
exposure_map(imgs_gray <= 0.10 | imgs_gray >= 0.90) = 0;
imwrite(mat2gray(exposure_map(:,:,1)), fullfile(save_path, 'exposure_map_Pan.jpg'));
% ---- 5. FINAL WEIGHT = luminance × exposure ----
weight_map = contrast_map .* exposure_map;

% avoid division problems
weight_map = weight_map + 1e-25;

% normalize weight across N images
weight_map = weight_map ./ repmat(sum(weight_map, 3), [1 1 N]);

% ---- 6. FUSION ----
F = zeros(H, W, 3);
for i = 1:N
    w = repmat(weight_map(:,:,i), [1 1 3]);
    F = F + imgs(:,:,:,i) .* w;
end

end
