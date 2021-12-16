function [res, iter_count] = swt2_un(y, t, H, Ht, lammda, alpha, iteration, epsilon)

% keep_angle = angle(y);
y = abs(y);
y0 = y;
level = t;
iter_count = 0;
[weight, height] = size(y);
[ca, ch, cv ,cd] = swt2(y, level, 'haar');

h = zeros(weight, height, level);
v = zeros(weight, height, level);
d = zeros(weight, height, level);

h_k = zeros(weight, height, level);
v_k = zeros(weight, height, level);
d_k = zeros(weight, height, level);

h_old = zeros(weight, height, level);
v_old = zeros(weight, height, level);
d_old = zeros(weight, height, level);

for i = 1:level
% a = Ht(ca);
% a_k = a;
    h(:,:,i) = Ht(ch(:,:,i));
    h_k(:,:,i) = h(:,:,i);

    v(:,:,i) = Ht(cv(:,:,i));
    v_k(:,:,i) = v(:,:,i);

    d(:,:,i) = Ht(cd(:,:,i));
    d_k(:,:,i) = d(:,:,i);
end
t_1 = 1;
T = lammda/alpha;


for iter = 1:iteration
    iter_count = iter; 
    grad_y = y-y0;
    [cag, chg,cvg,cdg] = swt2(grad_y, t, 'haar');
    for i = 1:level
        %     a = a - T*cag;
        h(:,:,i) = h(:,:,i) - T*chg(:,:,i);
        v(:,:,i) = v(:,:,i) - T*cvg(:,:,i);
        d(:,:,i) = d(:,:,i) -T*cdg(:,:,i);

        %     a_old = a;
        h_old(:,:,i) = h(:,:,i);
        v_old(:,:,i) = v(:,:,i);
        d_old(:,:,i) = d(:,:,i);
    
    
        %     a = newsoft((a_k+(1/alpha)*Ht(ca-H(a_k))), T);
        h(:,:,i) = newsoft((h_k(:,:,i)+(0.1/alpha)*Ht(ch(:,:,i)-H(h_k(:,:,i)))), T);
        v(:,:,i) = newsoft((v_k(:,:,i)+(0.1/alpha)*Ht(cv(:,:,i)-H(v_k(:,:,i)))), T);
        d(:,:,i) = newsoft((d_k(:,:,i)+(0.1/alpha)*Ht(cd(:,:,i)-H(d_k(:,:,i)))), T);
        t_0 = t_1-1;
        t_1 = (1+sqrt(1+4*t_0^2))/2;
        %     a_k = a+(t_0/t_1)*(a-a_old);
        h_k(:,:,i) = h(:,:,i)+(t_0-1/t_1)*(h(:,:,i)-h_old(:,:,i));
        v_k(:,:,i) = v(:,:,i)+(t_0-1/t_1)*(v(:,:,i)-v_old(:,:,i));
        d_k(:,:,i) = d(:,:,i)+(t_0-1/t_1)*(d(:,:,i)-d_old(:,:,i));
    end
    y = iswt2(ca, h, v, d, 'haar');
    
    if iter_count ==1
        pre_error = norm(y - y0)/norm(y);
        continue;
    end
    err = norm(y-y0)^2/norm(y)^2;
    error = abs(pre_error-err);
    pre_error = err;

    fprintf('Iteration = %d, ERROR = %f\n', iter_count, error);
    if error < epsilon
        fprintf('------------------------------------\n');
        break;
    end
end
res = iswt2(ca, h, v, d, 'haar');
% res = res.*exp(1i*keep_angle);
end

    
    
    