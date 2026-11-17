function main()
    %The toolbox NLMSAP_code is used in this project
    addpath(genpath('C:\Users\13\Desktop\JL-40278106\NLMSAP_code'))

    % read iamge
    img = imread('C:\Users\13\Desktop\JL-40278106\images\Chemical Plant.jpg');
    img = im2double(img);
    %img=rgb2gray(img);
    %disp(size(img))

    %Add a gaussian white noise
    img_GN = imnoise(img, 'gaussian', 0, 0.01);

    %define the size of windows and parameter h
    size_searchWindow = 15;
    size_similarityWindow = 5;
    h=0.1;

    %symmetric padding
    pad = (size_searchWindow-1)/2+(size_similarityWindow-1)/2;
    padded_img = padarray(img_GN, [pad pad], 'symmetric');

    %NL-means
    img_denoise = zeros(size(img_GN));
    [raws, columns] = size(img_GN);
    for i = pad+1:pad+raws
        for j = pad+1:pad+columns
            img_denoise(i-pad,j-pad)=NL_means(padded_img,i,j,h,size_searchWindow,size_similarityWindow);
        end
    end

    %methods for comparison
    img_denoise_gaussian = imgaussfilt(img_GN, 0.5);
    img_denoise_wiener = wiener2(img_GN, [5 5]);
    img_denoise_NLMSAP = NLMSAP(img,img_GN);


    %dispaly the results
    fprintf('NLM:\n');
    evaluation_display(img_denoise,img)
    subplot(2,4,5);
    imshow(img_denoise, []);
    title('NL-Means');

    fprintf('Gaussian:\n');
    evaluation_display(img_denoise_gaussian,img)
    subplot(2,4,6);
    imshow(img_denoise_gaussian, []);
    title('Gaussian filter');

    fprintf('Wiener:\n');
    evaluation_display(img_denoise_wiener,img)
    subplot(2,4,7);
    imshow(img_denoise_wiener, []);
    title('Wiener Filter');

    fprintf('NLM-SAP:\n');
    evaluation_display(img_denoise_NLMSAP,img)
    subplot(2,4,8);
    imshow(img_denoise_NLMSAP, []);
    title('NLM-SAP');

    subplot(2,4,1);
    imshow(img, []);
    title('Original');
    subplot(2,4,4);
    imshow(img_GN, []);
    title('gaussian white noise');

end

%Extract the intensity vector of a patch centered at a given pixel(i,j)
function vector = vec(img,i,j,patch_size)
    k = (patch_size-1)/2;
    patch = img(i-k:i+k, j-k:j+k);
    vector = double(patch(:));
end

%Compute the Euclidean distance between vector_i and vector_j
function result = dist_Euclidean(vector_i,vector_j)
    patch_size = sqrt(length(vector_i));
    a = patch_size/3;
    Gaussian_kernel=fspecial('gaussian', patch_size, a);
    GK_vector = Gaussian_kernel(:);
    result = sum(sum(GK_vector.*(vector_i - vector_j).^2));
end

%Compute the normalizing constant Z(i),
function result = Z(img,i,j,h,size_searchWindow,size_similarityWindow)
    result=0;
    vector_i = vec(img,i,j,size_similarityWindow);
    k = (size_searchWindow-1)/2;
    for x = i-k:i+k
       for y = j-k:j+k
        vector_j = vec(img,x,y,size_similarityWindow);
        m = exp(-dist_Euclidean(vector_i,vector_j)/(h*h));
        result = result+m;
       end
    end
end

%Compute the weights of pixel(p,q)
function result = w(img,i,j,p,q,z,h,size_similarityWindow)
    vector_i = vec(img,i,j,size_similarityWindow);
    vector_j = vec(img,p,q,size_similarityWindow);
    result = (1/z)*exp(-dist_Euclidean(vector_i,vector_j)/(h*h));
end

%compute the final intensity
function NL = NL_means(img,i,j,h,size_searchWindow,size_similarityWindow)
    NL=0;
    k = (size_searchWindow-1)/2;
    z = Z(img,i,j,h,size_searchWindow,size_similarityWindow);
    for x = i-k:i+k
     for y = j-k:j+k
          NL=NL+w(img,i,j,x,y,z,h,size_similarityWindow)*img(x,y);
     end
    end
end

function evaluation_display(img_denoise,img_origin)
    img_denoise = im2double(img_denoise);
    img_origin = im2double(img_origin);

    mse = immse(img_denoise, img_origin);
    psnr = 10 * log10(1 / mse);
    rmse = sqrt(mse);
    ssim_ = ssim(img_denoise, img_origin);

    fprintf('MSE  = %.6f\n', mse);
    fprintf('RMSE = %.6f\n', rmse);
    fprintf('PSNR = %.6f\n', psnr);
    fprintf('SSIM = %.6f\n', ssim_);
end

%% The following functions are adapted from DEMO_NLMSAP in NLMSAP_code
%  The relevant toolbox is included in the submission.
function img_NLMSAP = NLMSAP(img,img_nse) 
% Parameters initialization
sig             = 0.1;            % standard-deviation of the noise
hW              = 7;             % half-size of the search window
alpha           = 0.5;           % h^2=alpha^2*sigma^2/2 for 7x7 patches
                                 % h^2 is adapted for other shapes in
                                 % proportion of the 0.99-quantile.
temperature     = 0.4*sig.^2;    % Temperature for EWA

% Initialize random seed
randn('seed', 2);

% Build the true and noisy images
[M,N]   = size(img);
         
tic
% Build the shapes
L = 2;           % number of size levels
R = 4;           % radius of the first level (evolution as R*sqrt(2)^(n-1)
A = 0;           % number of angle partitions (precisely 2^A)
shapes = cat(3, ...
             build_pie(M,N,L,R/2,A), ...
             build_pie(M,N,L,R/sqrt(2),A), ...
             build_pie(M,N,L,R,A));

% Display the shapes
figure
%plot_shapes(shapes);        
tic

% Compute the NL-Shapes estimations
[nlsum, sumphi, sumphi2, deriv] = ...
    NLMSAP_trapezoid(img_nse, hW, shapes, alpha, sig);
nbshapes = size(nlsum, 3);

% Compute risks maps
riskmat = risk_sure(img_nse, nlsum, deriv, sig);

% Filter risks maps
riskemp = (repmat(img_nse, [1 1 nbshapes]) - nlsum).^2;
divmat = riskmat - riskemp;
[divmat_diff riskmat_diff] = riskfilter_yaroslavsky(divmat, riskmat);

%Aggregation step with EWA
[img_NLMSAP, beta_NLMSAP] = ...
    aggregation_EWA(nlsum, divmat_diff, temperature);
toc
end
