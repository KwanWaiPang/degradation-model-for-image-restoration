
function [y] = AddNoise(x,sigma_s,sigma_c)
% default value
channel = size(x,3);
rng('default');
% randn('seed', 0);
if nargin < 2
    rng('shuffle');
    sigma_s = 0.16*rand(1,channel,'single'); % original 0.16
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%sigma_s=[0.08,0.08,0.08];
    rng('shuffle');
    sigma_c = 0.06*rand(1,channel,'single'); % original 0.06
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%sigma_c=[0.03,0.03,0.03];
    
end  
temp_x = x;

noise_s_map = bsxfun(@times,permute(sigma_s,[3 1 2]),temp_x);
noise_s = randn(size(temp_x),'single').* noise_s_map;
temp_x = temp_x + noise_s;

noise_c_map = repmat(permute(sigma_c,[3 1 2]),[size(x,1),size(x,2)]);
noise_c = noise_c_map .* randn(size(temp_x),'single');
temp_x = temp_x + noise_c;

y = temp_x;
end