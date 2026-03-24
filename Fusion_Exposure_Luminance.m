function [F, weight_map, outIm] = Fusion_Exposure_Luminance(I)
% Fusion using Exposure + Luminance + Shock Filter Detail Enhancement
save_path = 'F:\paper2\ADS_porposed\ADF_Dhruv\result_pic1\';

[H, W, ~, N] = size(I);
imgs = double(I) / 255;
imgs_gray = zeros(H, W, N);

% --- 1. Compute luminance ---
for i = 1:N
    imgs_gray(:,:,i) = rgb2gray(imgs(:,:,:,i));
end

% --- 2. Exposure quality map ---
exposure_map = ones(H, W, N);
exposure_map(imgs_gray <= 0.10 | imgs_gray >= 0.90) = 0;

imwrite(mat2gray(exposure_map(:,:,1)), fullfile(save_path, 'exposure_map_MS.jpg'));

% --- 3. Luminance weight ---
luminance_weight = imgs_gray;
weight_map = exposure_map .* luminance_weight;

imwrite((luminance_weight(:,:,1)), fullfile(save_path, 'luminance_MS.jpg'));


% --- 4. Normalize weights ---
weight_map = weight_map + 1e-25;
weight_map = weight_map ./ repmat(sum(weight_map, 3), [1 1 N]);

% --- 5. Fuse ---
F = zeros(H, W, 3);
for i = 1:N
    w = repmat(weight_map(:,:,i), [1 1 3]);
    F = F + imgs(:,:,:,i) .* w;
end




