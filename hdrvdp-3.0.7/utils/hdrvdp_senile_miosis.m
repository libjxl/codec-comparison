function [lum_reduction, d_age] = hdrvdp_senile_miosis( L_adapt, age )
% light reduction due to senile miosis

d = 4.6 - 2.8*tanh(0.4 * log10(0.625*L_adapt));   
dslope = -.05 ./ (1 + ((.0025 .* L_adapt).^.5)); % Watson Fig.15b

d_age = d + dslope.*(clamp( age, 20, 80 )-20);

lum_reduction = d_age.^2 ./ d.^2;

end