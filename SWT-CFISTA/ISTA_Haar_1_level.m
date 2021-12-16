function [y_hat,iter_count] = ISTA_Haar_1_level(y0,ori,T)
%ISTA_Haar1
%y0 : 観測画像
%T  : ISTAの繰り返し回数

%Haar init
y = y0;
lambda = 1;
gamma = 0.1;
[cA,cH,cV,cD] = dwt2_undecimated(y,'haar');
iter_count = 0;
tic
%% Wavelet-T 1-level
for iter = 1:T
    iter_count = iter;
    grad_y = y - y0;
    
    [cAg, cHg, cVg,cDg] = dwt2_undecimated(grad_y,'haar');
    
    dcH = cH - gamma*cHg;
    dcV = cV - gamma*cVg;
    dcD = cD - gamma*cDg;
    
    cH = SoftThr(dcH,lambda*gamma);
    cV= SoftThr(dcV,lambda*gamma);
    cD = SoftThr(dcD,lambda*gamma);
    
    x = cA;
    y = idwt2_undecimated(x,cH,cV,cD,'haar');
   
    if iter == 1
        pre_func_min = norm(y - y0)^2/norm(y)^2;% + lambda * norm(x,1);
        fprintf('1-level-Iteration = %d, R.PSNR = %.2f[dB], I.PSNR = %.2f[dB]\n',...,
                     iter_count, psnr(real(y),real(ori)), psnr(imag(y),imag(ori)));
        continue;
    end
    func_min = 0.5 * norm(y - y0)^2/norm(y)^2;% + lambda * norm(x,1);
    delta_func_min = abs(pre_func_min - func_min);
    pre_func_min = func_min;
    fprintf('1-level-Iteration = %d, R.PSNR = %.2f[dB], I.PSNR = %.2f[dB]\n',...,
                 iter_count, psnr(real(y),real(ori)), psnr(imag(y),imag(ori)));
    if delta_func_min < eps*1000
        break;
    end
%     if iter == 1
%         pre = norm(y-y0)^2;
%         fprintf('iter = %d, R = %.2f, I = %.2f\n', iter_count,psnr(real(y),real(ori)), psnr(imag(y),imag(ori)));
%         continue;
%     end
%         fun_c = norm(y-y0)^2;
%         delta = abs(pre - fun_c);
%         pre = fun_c;
%         fprintf('iter = %d, R = %.2f, I = %.2f\n', iter_count,psnr(real(y),real(ori)), psnr(imag(y),imag(ori)));
%     if delta < lambda*gamma
%         break;
%     end
end
y_hat = idwt2_undecimated(cA,cH,cV,cD,'haar');
toc
end