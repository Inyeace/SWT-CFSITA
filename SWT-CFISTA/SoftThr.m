function y = SoftThr(x,lambda)
%SOFTTHER この関数の概要をここに記述
%   詳細説明をここに記述

% if(isreal(x))
%     y = zeros(size(x));
%     temp = find(x>lambda);
%     y(temp) = x(temp) - lambda;
%     
%     temp = find(x < - lambda);
%     y(temp) = x(temp) + lambda;
% else
    y = zeros(size(x));
 
    temp = find(x > lambda);
    y(temp) = x(temp) - lambda;
    temp = find(x < - lambda);
    y(temp) = x(temp) + lambda;

% end