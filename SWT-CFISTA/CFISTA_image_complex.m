%%  CISTA
clear;
close all;
clc;
%% load cameraman and 周期拡張extension
cameraImg = im2double(imread('barbara.png'));
cameraImg = wextend(2, 'sym', cameraImg, 2);
% extension = zeros(size(cameraImg,1)+2,size(cameraImg,2)+2);
% extension(1,2:end-1) = cameraImg(end,:);
% extension(end,2:end-1) = cameraImg(1,:);
% extension(2:end-1,1) = cameraImg(:,end);
% extension(2:end-1,end) = cameraImg(:,1);
% 
% extension(1,1) = cameraImg(end,end);
% extension(1,end) = cameraImg(end,1);
% extension(end,1) = cameraImg(1,end);
% extension(end,end) = cameraImg(1,1);
% extension(2:end-1,2:end-1) = cameraImg(:,:);
% 
% cameraImg_ = cameraImg;
% cameraImg = extension;

%% load lena and extension
% [lenaImg,map] = imread('Lena.png');
% % lenaImg = imresize(lenaImg,0.5);
% lenaImg = im2double(ind2gray(lenaImg,map));
%lenaImg = rgb2gray(lenaImg);
lenaImg = im2double(imread('boat.png'));
lenaImg = wextend(2, 'sym', lenaImg, 2);
% extension = zeros(size(lenaImg,1)+2,size(lenaImg,2)+2);
% extension(1,2:end-1) = lenaImg(end,:);
% extension(end,2:end-1) = lenaImg(1,:);
% extension(2:end-1,1) = lenaImg(:,end);
% extension(2:end-1,end) = lenaImg(:,1);
% 
% extension(1,1) = lenaImg(end,end);
% extension(1,end) = lenaImg(end,1);
% extension(end,1) = lenaImg(1,end);
% extension(end,end) = lenaImg(1,1);
% 
% extension(2:end-1,2:end-1) = lenaImg(:,:);
% 
% lenaImg_ = lenaImg;
% lenaImg = extension;

%% United
%cameraman -> Re
%lena -> Im
orgImg = zeros(size(cameraImg,1),size(cameraImg,2));
orgImg(:,:) = cameraImg(:,:) + 1i*lenaImg(:,:);
ori_angle = angle(orgImg);
% orgImg_ = abs(orgImg);
%% pixel loss
% K = numel(orgImg) * 0.1;
% pixel_loss = ones(size(cameraImg));%+ randi(50,size(orgImg));
% for a = 1:K
%     x_rand = ceil((size(cameraImg,1)-1)*rand(1))+1;
%     y_rand = ceil((size(cameraImg,1)-1)*rand(1))+1;
%     
%     pixel_loss(x_rand,y_rand) = 0;
% end
% noisy = orgImg.*pixel_loss;
% % Blur
% A = randn(size(orgImg));
% A = sqrt(1/(size(orgImg, 1)))*A;
% A = orth(A')';
% noisy = A.*orgImg;
%% moviation blur + add noise 
a = fspecial('gaussian', 7, 2);
obser = conv2(orgImg, a, 'same');
noisy = awgn(obser,10,'measured');
% noisy  = obser+randn(size(obser))*1e-1;
% noisy = awgn(orgImg,0.07,'measured');
noisy_angle = angle(noisy);
%% get observation process
obj1 = @(x) conv2(x, a, 'same');
obj2 = @(x) conv2(x, (a).', 'same');

%% FISTA init
lambda = 0.000001;
alpha = 3;
max_it = 200;
epsilon1 = eps*0.000001;
% epsilon2 = eps*100000;
swt2_level = 2;
%% FISTA begin 
tic
[fista_img, iter_count] = swt2_un(noisy, swt2_level,  obj1, obj2, lambda, alpha, max_it, epsilon1);
[fista_angle, iter_count] = swt2_un(noisy_angle, swt2_level, obj1, obj2, 1, 2, max_it, epsilon1);
% new_angle = kaiten(noisy);
toc
fista_img = fista_img.*exp(1i*fista_angle);

% ista_img = ista_img.*exp(1i*ista_angle);
% orgImg = orgImg_.*exp(1i*ori_angle);
%% result
%PSNR
% noisy_psnr = psnr(noisy, orgImg);
% ista_psnr= psnr(ista_img, orgImg);
% %istanoisy_psnr = psnr(istanoisy_img,orgImg);
% 
% 
% noisy_psnr = num2str(noisy_psnr);
% ista_psnr = num2str(ista_psnr);
%istanoisy_psnr = num2str(istanoisy_psnr);



subsize = 3;
figure();
subplot(2,subsize,1);
imshow(real(orgImg));
title('Original Real ');
subplot(2,subsize,2);
imshow(real(noisy));
title(['Noisy Imag PSNR=' num2str(psnr(real(noisy), real(orgImg)))]);
subplot(2,subsize,3);
imshow(real(fista_img));
title(['ISTA Real PSNR=' num2str(psnr(real(fista_img), real(orgImg)))]);

subplot(2,subsize,4);
imshow(imag(orgImg));
title(['original Imag ']);

subplot(2,subsize,5);
imshow(imag(noisy));
title(['Noisy Imag PSNR=' num2str(psnr(imag(noisy), imag(orgImg)))]);
subplot(2,subsize,6);
imshow(imag(fista_img));
title(['ISTA Imag PSNR=' num2str(psnr(imag(fista_img), imag(orgImg)))]);




% ista_result = ISTA(haar_one_dim,A,50);
% 
% 
% 
% imshow(reshape(ista_result,256,256));