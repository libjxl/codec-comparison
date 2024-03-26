function S_corr = hdrvdp_aesl( rho, metric_par )
% Age-related empiral sensitovity loss
%
% S_corr = hdrvdp_aesl( rho, metric_par )
%
% rho - spatial frequency in cpd
%
% The function is based on the paper: 
%
% Mantiuk, R. K., & Ramponi, G. (2018). 
% Age-dependent predictor of visibility in complex scenes. 
% Journal of the Society for Information Display. 
% https://doi.org/10.1002/jsid.623

gamma = 10^metric_par.aesl_base;
S_corr = 10.^( -(10^metric_par.aesl_slope_freq*log2(rho+gamma))*max(0, metric_par.age-24) );
    
end
