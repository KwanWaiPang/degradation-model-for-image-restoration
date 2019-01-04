function Test_Realistic_Noise_Model()
%%% Test Code for realistic noise model
addpath('./utils');   %%%%%%%%%%%%%this is the function

%% load CRF parameters, the pipeline of the camera, is should be turn off
load('201_CRF_data.mat');
load('dorfCurvesInv.mat');
I_gl = I;
B_gl = B;
I_inv_gl = invI;
B_inv_gl = invB;
mod_scale = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set parameters
% comment the unnecessary line
input_folder = '/home/guanwp/BasicSR_datasets/DIV2K800_sub_blur_bicLRx4';
%%%%%%%%%%%%%%%%%%%%% save_mod_folder = '';
save_LR_folder = '/home/guanwp/BasicSR_datasets/DIV2K800_sub_blur_bicLRx4_noiseALL';
%%%%%%%%%%%%%5% save_bic_folder = '';
save_residual_folder='/home/guanwp/BasicSR_datasets/DIV2K800_sub_blur_bicLRx4_residualALL'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%save_noiselevelmap_folder='/home/guanwp/BasicSR_datasets/val_set5/Set5_l';%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('save_mod_folder', 'var')
    if exist(save_mod_folder, 'dir')
        disp(['It will cover ', save_mod_folder]);
    else
        mkdir(save_mod_folder);
    end
end
if exist('save_LR_folder', 'var')
    if exist(save_LR_folder, 'dir')
        disp(['It will cover ', save_LR_folder]);
    else
        mkdir(save_LR_folder);
    end
end
if exist('save_bic_folder', 'var')
    if exist(save_bic_folder, 'dir')
        disp(['It will cover ', save_bic_folder]);
    else
        mkdir(save_bic_folder);
    end
end

if exist('save_residual_folder', 'var')
    if exist(save_residual_folder, 'dir')
        disp(['It will cover ', save_residual_folder]);
    else
        mkdir(save_residual_folder);
    end
end

%if exist('save_noiselevelmap_folder', 'var')
    %if exist(save_noiselevelmap_folder, 'dir')
        %disp(['It will cover ', save_noiselevelmap_folder]);
    %else
        %mkdir(save_noiselevelmap_folder);
    %end
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

idx = 0;
filepaths = dir(fullfile(input_folder,'*.*'));
for i = 1 : length(filepaths)
    [paths,imname,ext] = fileparts(filepaths(i).name);
    if isempty(imname)
        disp('Ignore . folder.');
    elseif strcmp(imname, '.')
        disp('Ignore .. folder.');
    else
        idx = idx + 1;
        str_rlt = sprintf('%d\t%s.\n', idx, imname);
        fprintf(str_rlt);
        % read image
        img = imread(fullfile(input_folder, [imname, ext]));
        img = im2double(img);
        % modcrop
        %%%img = modcrop(img, mod_scale);
        if exist('save_mod_folder', 'var')
            imwrite(img, fullfile(save_mod_folder, [imname, '.png']));
        end
        % LR%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%add noise
        %%%%%%%%%%random
        channel = size(img,3);
        %%%%%%%%%%%sigma_s = 0.16*rand(1,channel,'single'); % original 0.16.signal-dependent noise 
        %%%%%%%%%%%%%sigma_c =0.06*rand(1,channel,'single'); % original 0.06.stationary noise
        %%%%%%%%%%%%%%%%sigma_s=[0.18,0.18,0.18];
        %%%%%%%%%%%%%%%%sigma_c=[0.03,0.03,0.03];

        %%%used the default value
        CRF_index = 5;  % 1~201
        pattern = 5;    % 1: 'gbrg', 2: 'grbg', 3: 'bggr', 4: 'rggb', 5: no mosaic

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5[im_LR,noise_level_map] = AddNoiseMosai(img,I_gl,B_gl,I_inv_gl,B_inv_gl, sigma_s,sigma_c, CRF_index, pattern);
        im_LR = AddNoise(img);%%%%%%%%%%%%%%jingwen%%%%%%
        im_residual=im_LR-img;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5im_residual=rgb2gray(im_residual);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%im_residual=mat2gray(im_residual);
        



        if exist('save_LR_folder', 'var')
            imwrite(im_LR, fullfile(save_LR_folder, [imname, '_bicLRx4.png']));
        end
        % Bicubic
        if exist('save_bic_folder', 'var')
            im_B = imresize(im_LR, up_scale, 'bicubic');
            imwrite(im_B, fullfile(save_bic_folder, [imname, '_bicx4.png']));
        end

        if exist('save_residual_folder', 'var')
            imwrite(im_residual, fullfile(save_residual_folder, [imname, '_bicLRx4.png']));
        end
        %if exist('save_noiselevelmap_folder', 'var')
            %imwrite(noise_level_map, fullfile(save_noiselevelmap_folder, [imname, '_bicLRx4.png']));
        %end
    end
end
end


%% modcrop
function img = modcrop(img, modulo)
if size(img,3) == 1
    sz = size(img);
    sz = sz - mod(sz, modulo);
    img = img(1:sz(1), 1:sz(2));
else
    tmpsz = size(img);
    sz = tmpsz(1:2);
    sz = sz - mod(sz, modulo);
    img = img(1:sz(1), 1:sz(2),:);
end
end


