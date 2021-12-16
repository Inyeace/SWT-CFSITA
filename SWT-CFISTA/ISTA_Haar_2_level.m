function [y_hat,iter_count2, iter_count1] = ISTA_Haar_2_level(y0,ori,T)
%ISTA_Haar1
%y0 : 観測画像
%T  : ISTAの繰り返し回数

%Haar init
lambda = 0.5;
gamma = 0.1;
y = y0;
[cA,cH,cV,cD] = dwt2(y,'haar');
cA0 = cA;
[cA2, cH2, cV2,cD2] = dwt2(cA,'haar');

iter_count2 = 0;
iter_count1 = 0;
tic
%% Wavelet-T 2-level
for iter2 = 1:T
    iter_count2 = iter2;
    grad_cA = cA-cA0;
    [cAg, cHg, cVg, cDg] = dwt2(grad_cA,'haar');

% dcA = cA2 - gamma*cAg;
    dcH = cH2 - gamma*cHg;
    dcV = cV2 - gamma*cVg;
    dcD = cD2 - gamma*cDg;
    
% cA2 = SoftThr(dcA,lambda*gamma);
    cH2 = SoftThr(dcH,lambda*gamma);
    cV2= SoftThr(dcV,lambda*gamma);
    cD2 = SoftThr(dcD,lambda*gamma);
    x = cA2;
    cA = idwt2(x,cH2,cV2,cD2,'haar');
% cA = cA(1:len(1)-1,1:len(2)-1);
% cA= reshape(cA,size(cA0,1),size(cA0,1));
% delta_max_x = max(x - pre_x,[],'all');
    len = size(cA);
    cA = cA(1:(size(cA,1)-1),1:size(cA,2)-1);

    if iter2 == 1
        pre_func_min = 0.5 * norm(grad_cA);%+ lambda * norm(x,1);
        fprintf("iteration-2-level = %d\n",iter_count2); 
        continue;
    end
    func_min = 0.5 * norm(grad_cA);% + lambda * norm(x,1); 
    delta_func_min = abs(pre_func_min - func_min);
    pre_func_min = func_min;
    if delta_func_min < lambda*gamma
        break;
    end
fprintf("iteration-2-level = %d\n",iter_count2); 
end 
xx = idwt2(x, cH2, cV2, cD2,'haar');
xx= xx(1:(size(xx,1)-1),1:size(xx,2)-1);

%% Wavelet-T 1-level
for iter1 = 1:T
    iter_count1 = iter1;
    grad_y = y-y0;
    [ccA,ccH,ccV,ccD] = dwt2(grad_y,'haar');
    ddcH = cH - gamma*ccH;
    ddcV = cV - gamma*ccV;
    ddcD = cD - gamma*ccD;
    
     cH = SoftThr(ddcH,lambda*gamma);
     cV = SoftThr(ddcV,lambda*gamma);
     cD = SoftThr(ddcD,lambda*gamma);

    y = idwt2(xx,cH,cV,cD,'haar');
    if iter1 == 1
        pre_func_min = 0.5 * norm(grad_y);%+ lambda * norm(x,1);
        fprintf("iteration-2-level = %d, iteration-1-level = %d, R.PSNR = %.2f, I.PSNR = %.2f\n",...,
                     iter_count2, iter_count1, psnr(real(y),real(ori)), psnr(imag(y),imag(ori)));
        continue;
    end
    func_min = 0.5 * norm(grad_y);% + lambda * norm(x,1); 
    delta_func_min = abs(pre_func_min - func_min);
    pre_func_min = func_min;
    if delta_func_min < eps*1000
        break;
    end
%     pre_x = x;
fprintf("iteration-2-level = %d, iteration-1-level = %d, R.PSNR = %.2f, I.PSNR = %.2f\n",...,
             iter_count2, iter_count1, psnr(real(y),real(ori)), psnr(imag(y),imag(ori)));
end
y_hat = idwt2(xx, cH, cV, cD,'haar');
toc

end