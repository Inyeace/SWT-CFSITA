function new_angle = kaiten(y);
    value = abs(y);
    ori_imag_real_angle = atan(imag(y)/real(y));
    pre_angle = angle(y);
    for k = 1:numel(pre_angle)
        new_angle = (value^2/sqrt(2))*(abs(cos(deg2rad(k*pi/2)+ori_imag_real_angle - pre_angle))+abs(sin(deg2rad(k*pi/2)+ori_imag_real_angle - pre_angle)));
    end
end