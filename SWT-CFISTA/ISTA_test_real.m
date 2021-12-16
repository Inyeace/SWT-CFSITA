clear;close all;clc;

cameraImg = im2double(imread('cameraman.png'));
cameraImg = wextend(2, 'sym', cameraImg, 2);

ori = cameraImg; 
K = numel(ori)*0.5;
pixel_loss = ones(size(ori));
for i = 1:K  
    x_rand = ceil((size(cameraImg,1)-1)*rand(1))+1;
    y_rand = ceil((size(cameraImg,1)-1)*rand(1))+1;
    pixel_loss(x_rand,y_rand) = 0;
end
noisy = ori .* pixel_loss;
noisy =  awgn(noisy, 200, 'measured');

[ista_img, iter_count] = swt2_un(ori, noisy,pixel_loss,  2, 'haar', 100, 2e-5);

subsize = 3;

subplot(1, subsize, 1)
imshow(ori);
title('ori Image');

subplot(1, subsize, 2)
imshow(noisy);
title(['noisy Image PSNR = ' num2str(psnr(ori, noisy))]);

subplot(1, subsize, 3)
imshow(ista_img);
title(['ISTA Image PSNR = ' num2str(psnr(ori, ista_img))]);



