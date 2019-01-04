%//////////////////////////////////////////////////////////////////////////
%                             AddNoiseMosai
%function: add realistic noise 
% If this Code is helpful to you, please Cite: https://arxiv.org/abs/1807.04686
%%% realistic noise model:
%%% I = M^{-1}(M(f(L + n_s + n_c) + n_q))
% n_s: shot noise, depend on L, E[n_s]= 0, var[n_s] = L*sigma_s
%      in [1], n_s is a Possion Shot
%      in [2], n_s is GMM, sigma_s: 0~0.16
%      we choose [2] here
% n_c: other type of noise, i.e. read noise, dark current
%      in [2], E[n_c] = 0, var[n_c] = sigma_c, sigma_c: 0.01~0.06
% n_q: ignore in [2]
%//////////////////////////////////////////////////////////////////////////
%inpus:
%-------x: image data, double or single datatype, [0,1]
%-------I, B: CRF parameters provided by [3]
%-------Iinv, Binv: inverse CRF parameters, created by "inverseCRF" for
%                   faster computation
%**(optional): if not defined by user,the following parameters are set
%              ramdomly
%-------sigma_s: signal-dependent noise level, [0, 0.16]
%-------sigma_c: sigma_independent noise level, [0, 0.06]
%-------crf_index: CRF index, [1, 201]
%-------pattern: 1: 'gbrg', 2: 'grbg', 3: 'bggr', 4: 'rggb', 5: no mosaic
%
%output:
%-------y: noisy image
%//////////////////////////////////////////////////////////////////////////
% reference:
% [1] G.E. Healey and R. Kondepudy, Radiometric CCD Camera Calibration and Noise Estimation,
%     IEEE Trans. Pattern Analysis and Machine Intelligence
% [2] Liu, Ce et al. Automatic Estimation and Removal of Noise from a Single Image. 
%     IEEE Transactions on Pattern Analysis and Machine Intelligence 30 (2008): 299-314.
% [3] Grossberg, M.D., Nayar, S.K.: Modeling the space of camera response functions.
%     IEEE Transactions on Pattern Analysis and Machine Intelligence 26 (2004)
%

function [y,noise_level_map] = AddNoiseMosai(x,I,B,Iinv,Binv,sigma_s,sigma_c,crf_index, pattern)
% default value
channel = size(x,3);
rng('default')
if nargin < 6
    rng('shuffle');
    sigma_s = 0.16*rand(1,channel,'single'); % original 0.16
    rng('shuffle');
    sigma_c = 0.06*rand(1,channel,'single'); % original 0.06
    rng('shuffle');
    rand_index = randperm(201);
    crf_index = rand_index(1);
    rng('shuffle');
    pattern = randperm(5);
end  
temp_x = x;

%%% x -> L
temp_x = ICRF_Map(temp_x,Iinv(crf_index,:),Binv(crf_index,:)); 
L=temp_x;

noise_s_map = bsxfun(@times,permute(sigma_s,[3 1 2]),temp_x);
noise_s = randn(size(temp_x),'single').* noise_s_map;
temp_x = temp_x + noise_s;

noise_c_map = repmat(permute(sigma_c,[3 1 2]),[size(x,1),size(x,2)]);
noise_c = noise_c_map .* randn(size(temp_x),'single');
temp_x = temp_x + noise_c;

%%%%%%%%%%%%%noise level map
%%%%%%%%%%%the stationary noise
%%%%%%%%%%%%%%%%%%noiseSigma_c=sigma_c*255;
%%%%%%%%%%%%%%%%%%%%%%[~,~,noiseSigma_c] = peaks(size(temp_x,1));
%%%%%%%%%%%%%%%%%%%%%%%%%%noiseSigma_c = 0  + (255 - 0).*(noiseSigma_c - min(noiseSigma_c(:)))./(max(noiseSigma_c(:)) - min(noiseSigma_c(:)));
%%%%%%%%%%%%%%%%%%%%%%%noiseSigma_c = flipud(noiseSigma_c);
%%%%%%%%%%%%%%%%%%%%%%noise_level_map_c =imresize(noiseSigma_c,1,'bicubic')/255;

%%%%%%%%%%%%%%%%%%%%the signal-dependent noise 
%%%%%%%%%%%%%%%%%%%noiseSigma_s=sigma_s*255;
%%%%%%%%%%%%%%%%%[~,~,noiseSigma_s] = peaks(size(temp_x,1));
%%%%%%%%%%%%%%%%%%noiseSigma_s = 0  + (255 - 0).*(noiseSigma_s - min(noiseSigma_s(:)))./(max(noiseSigma_s(:)) - min(noiseSigma_s(:)));
%%%%%%%%%%%%%%%%%%%%%%noiseSigma_s = flipud(noiseSigma_s);
%%%%%%%%%%%%%%%%%%%%%%%%%%noise_level_map_s =imresize(noiseSigma_s,1,'bicubic')/255;

%%%% three channel
%noise_level_map_c3(:,:,1)=noise_level_map_c;
%noise_level_map_c3(:,:,2)=noise_level_map_c;
%noise_level_map_c3(:,:,3)=noise_level_map_c;

%noise_level_map_s3(:,:,1)=noise_level_map_s;
%noise_level_map_s3(:,:,2)=noise_level_map_s;
%noise_level_map_s3(:,:,3)=noise_level_map_s;
%disp(size(noise_level_map_s3));
%disp(size(noise_level_map_c3));
%disp(size(L));

%%%%%%%%%%%%%%%%%%%%%%noise_level_map=noise_level_map_s+noise_level_map_c; 
%%%%%%%%%%%%%%%noise_level_map=noise_level_map_c;%%%%%%%%%%%%%%only the stationary noise
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
noise_level_map=L;%%%%%%noise_s_map.*L+noise_c_map;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% L -> x
temp_x = CRF_Map(temp_x,I(crf_index,:),B(crf_index,:));
y = temp_x;
end