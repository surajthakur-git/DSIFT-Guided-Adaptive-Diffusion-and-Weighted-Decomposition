%% 
clc; clear all; close all;
tic;
%% Load images
PAN = (imread("C:\Users\Dell\OneDrive\Desktop\dataset_zip\pic5\pickA.jpeg"));  
MS  = (imread("C:\Users\Dell\OneDrive\Desktop\dataset_zip\pic5\pickB.jpeg")); 
%a= imread("F:\try_pan\dataset\bagB.jpg");
%b= imread("F:\try_pan\dataset\bagA.jpg");
%if size(PAN,3) == 3
 %   I1 = rgb2gray(PAN);
%end
%if size(MS,3) == 3
%    I2 = rgb2gray(MS);
%end

% Compute initial weights
F  = Fusion_Exposure_Luminance(MS);   % weight for MS
F2 = Fusion_Contrast_Exposure(PAN,16);% weight for PAN

figure, imshow(F), title('Weight Map 1 (MS)');
figure, imshow(F2), title('Weight Map 2 (PAN)');

imwrite(F, 'F:\paper2\ADS_porposed\ADF_Dhruv\result_pic4\Exposure_Luminance.jpg');
imwrite(F2, 'F:\paper2\ADS_porposed\ADF_Dhruv\result_pic4\Contrast_Exposure.jpg');
I1 = im2double(PAN);
I2 = im2double(MS);

%% Anisotropic diffusion
%num_iter = 15; delta_t = 0.09; kappa = 30; option = 1;

%A1 = anisodiff2D(I1, num_iter, delta_t, kappa, option);
%A2 = anisodiff2D(I2, num_iter, delta_t, kappa, option);



num_iter = 15; 
kappa = 30; 


A1 = imdiffusefilt(I1, 'NumberOfIterations', num_iter, 'GradientThreshold', kappa);
A2 = imdiffusefilt(I2, 'NumberOfIterations', num_iter, 'GradientThreshold', kappa);
%% Detail layers
D1 = I1 - A1;
D2 = I2 - A2;
B1= I1-D1;
B2=I2-D2;

imwrite(D1, 'F:\paper2\ADS_porposed\ADF_Dhruv\result_pic4\D1.jpg');
imwrite(D2, 'F:\paper2\ADS_porposed\ADF_Dhruv\result_pic4\D2.jpg');

%figure;imshow(PAN);
figure;imshow(A1);
imwrite(A1, 'F:\paper2\ADS_porposed\ADF_Dhruv\result_pic4\A1.jpg');
figure;imshow(MS);
figure;imshow(A2);
imwrite(A2, 'F:\paper2\ADS_porposed\ADF_Dhruv\result_pic4\A2.jpg');
figure;imshow(B1);title("base1");
imwrite(B1, 'F:\paper2\ADS_porposed\ADF_Dhruv\result_pic4\B1.jpg');
figure;imshow(B2);title("base2");
imwrite(B2, 'F:\paper2\ADS_porposed\ADF_Dhruv\result_pic4\B2.jpg');
%if size(D1,3)==3, D1 = rgb2gray(D1); end
%if size(D2,3)==3, D2 = rgb2gray(D2); end

%% ---------------------------------------------
%      1) Fuse Base Layers (Simple Averaging)
%% ---------------------------------------------
Base_Fused = 0.5 * B1 + 0.5 * B2;

figure, imshow(Base_Fused, []), title('Fused Base Layer');

%% ---------------------------------------------
%      2) Fuse Detail Layers Using Weights
%           Detail_Fused = W1*D1 + W2*D2
%% ---------------------------------------------

% Normalize F and F2
W1 = double(F);
W2 = double(F2);

W1 = W1 + 1e-25;
W2 = W2 + 1e-25;
Wsum = W1 + W2;

W1 = W1 ./ Wsum;
W2 = W2 ./ Wsum;

Detail_Fused = W1 .* D1 + W2 .* D2;

figure, imshow(Detail_Fused, []), title('Fused Detail Layer');


%% ---------------------------------------------
%      3) Final Fusion
%           F_final = Base_Fused + Detail_Fused
%% ---------------------------------------------

Fused_Final = Base_Fused + Detail_Fused;
toc;
figure, imshow(Fused_Final, []), title('Final Fused Image');


%% Show all results in one figure
figure;
subplot(2,2,1), imshow(Base_Fused, []), title('Base Fused');
imwrite(Base_Fused, 'F:\paper2\ADS_porposed\ADF_Dhruv\result_pic4\fused_Base.jpg');

subplot(2,2,2), imshow(Detail_Fused, []), title('Detail Fused');
imwrite(Detail_Fused, 'F:\paper2\ADS_porposed\ADF_Dhruv\result_pic4\fused_Detail.jpg');

subplot(2,2,3), imshow(Fused_Final, []), title('Final Fused');
imwrite(Fused_Final, 'F:\paper2\ADS_porposed\ADF_Dhruv\result_pic4\fused_Final.jpg');

matrices_new_suraj(rgb2gray(Fused_Final),im2gray(PAN),rgb2gray(MS));

%matrices_new(rgb2gray(Fused_Final),im2gray(PAN),rgb2gray(MS));

disp("----------------------------");

%save file for all matrices accurate
%november(rgb2gray(Fused_Final),im2gray(PAN),rgb2gray(MS));