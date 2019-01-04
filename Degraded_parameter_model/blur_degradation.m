function blur_degradation()

addpath('./utils');   %%%%%%%%%%%%%this is the function



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set parameters
% comment the unnecessary line
input_folder = '/home/guanwp/BasicSR_datasets/DIV2K800_sub';
%%%%%%%%%%%%%%%%%%%%% save_mod_folder = '';
save_LR_folder = '/home/guanwp/BasicSR_datasets/DIV2K800_sub_blur';
%%%%%%%%%%%%%5% save_bic_folder = '';
save_residual_folder='/home/guanwp/BasicSR_datasets/DIV2K800_sub_estimation'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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



        % LR%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%add blur
        % kernel
        HR=img;
        ksize  = 15;
        theta  = pi*rand(1);
        l1     = 0.1+9.9*rand(1);
        l2     = 0.1+(l1-0.1)*rand(1);
        kernel = anisotropic_Gaussian(ksize,theta,l1,l2); % double
        kernel = single(kernel);
        blurry_HR  = imfilter(HR,double(kernel),'replicate');
        im_LR=blurry_HR;


        kernel = cov(kernel);%%%%%transform the covariance matrix of the blur kernel
        %%%im_residual=kernel;

        global P;
        load('PCA_P.mat')
        kk = P*kernel(:);

        kk=reshape(kk,[1,3]);
        im_residual=bsxfun(@times,ones(size(img,1),size(img,2),1),permute(kk,[3 1 2]));

        %%%%%%%%%%%%im_residual=im_residual.*255;
        %im_residual=uint8(round(im_residual.*255)); 
        %im_residual=im_residual.*255; 
        %im_residual



        %%%%%%%%im_residual=rand(size(img));

        %%%%%%%%%%%%%%for i=1:3
            %%%%%%%%%%%%%%%%im_residual(:,:,i) = repmat(kk(i), [size(img,1), size(img,2)]);
        %%%%%%%%%%%%%end
        





        if exist('save_LR_folder', 'var')
            imwrite(im_LR, fullfile(save_LR_folder, [imname, '_bicLRx4.png']));
        end
        % Bicubic
        if exist('save_bic_folder', 'var')
            im_B = imresize(im_LR, up_scale, 'bicubic');
            imwrite(im_B, fullfile(save_bic_folder, [imname, '_bicx4.png']));
        end

        if exist('save_residual_folder', 'var')
            %%%%imwrite(im_residual, fullfile(save_residual_folder, [imname, '_bicLRx4.png']));
            save (fullfile(save_residual_folder, [imname, '_bicLRx4.mat']),'im_residual');
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


