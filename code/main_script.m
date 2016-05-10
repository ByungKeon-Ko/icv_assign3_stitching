
run('~/matlab_lib/vlfeat-0.9.20/toolbox/vl_setup');

%% 1. Taking panoramic pictures
im1 = imread('../../images/img1.jpg');
im2 = imread('../../images/img2.jpg');
im3 = imread('../../images/img3.jpg');
im4 = imread('../../images/img4.jpg');
im5 = imread('../../images/img5.jpg');

% im1 = imread('/home/mschoi/icv_homework/icv_assign3/ref_code/img1.jpg');
% im2 = imread('/home/mschoi/icv_homework/icv_assign3/ref_code/img2.jpg');
% im3 = imread('/home/mschoi/icv_homework/icv_assign3/ref_code/img3.jpg');
% im4 = imread('/home/mschoi/icv_homework/icv_assign3/ref_code/img4.jpg');
% im5 = imread('/home/mschoi/icv_homework/icv_assign3/ref_code/img5.jpg');

im1_resize = imresize( im1, [256,256] );
im2_resize = imresize( im2, [256,256] );
im3_resize = imresize( im3, [256,256] );
im4_resize = imresize( im4, [256,256] );
im5_resize = imresize( im5, [256,256] );

fprintf('step1 done\n');
%% 2. Feature Extraction
im1_gray = rgb2gray( im1_resize );
im2_gray = rgb2gray( im2_resize );
im3_gray = rgb2gray( im3_resize );
im4_gray = rgb2gray( im4_resize );
im5_gray = rgb2gray( im5_resize );

I1 = single(im1_gray );
I2 = single(im2_gray );
I3 = single(im3_gray );
I4 = single(im4_gray );
I5 = single(im5_gray );

[f1, d1] = vl_sift(I1) ;
[f2, d2] = vl_sift(I2) ;
[f3, d3] = vl_sift(I3) ;
[f4, d4] = vl_sift(I4) ;
[f5, d5] = vl_sift(I5) ;

fprintf('# of descriptors : %d,%d,%d,%d,%d\n', size(f1,2), size(f2,2), size(f3,2), size(f4,2), size(f5,2) );

fprintf('step2 done\n');
%% 3. Feature Matching
THRESH = 1.5 ;
[matches12, scores12] = vl_ubcmatch(d1, d2, THRESH) ;
[matches23, scores23] = vl_ubcmatch(d2, d3, THRESH) ;
[matches34, scores34] = vl_ubcmatch(d3, d4, THRESH) ;
[matches45, scores45] = vl_ubcmatch(d4, d5, THRESH) ;

%% Displaying images with the matches overlaid
%figure(1)
%DisplayMatches(f1, f2, im1_resize, im2_resize, matches12);
%title('Correspondence graph of image 1 & image 2')

fprintf('step3 done\n');
%% 4. Homography Estimation using RANSAC
H12 = HbyRANSAC( matches12, f1, f2) ;
H23 = HbyRANSAC( matches23, f2, f3) ;
H34 = HbyRANSAC( matches34, f3, f4) ;
H45 = HbyRANSAC( matches45, f4, f5) ;

%% 5. Warping Images
% tform12 = projective2d(H);
tform12 = maketform('projective', H12');
[im1_proj, x_data, y_data] = imtransform( im1_resize, tform12);

% [pano12, ~, ~] = MergeImage( im1_resize, im2_resize, H12 );
% [pano123, ~, ~] = MergeImage( pano12, im3_resize, H23 );
% [pano54, ~, ~] = MergeImage( im5_resize, im4_resize, inv(H45) );
% [pano12345, ~, ~] = MergeImage( pano54, pano123, inv(H34) );

%% Projective Transform each images
tform = maketform('projective', H12'*H23');
[im1_proj, x_data, y_data] = imtransform( im1_resize, tform);
im1_x = int16(x_data + 0.5 );
im1_y = int16(y_data + 0.5 );

tform = maketform('projective', H23');
[im2_proj, x_data, y_data] = imtransform( im2_resize, tform);
im2_x = int16(x_data + 0.5 );
im2_y = int16(y_data + 0.5 );

im3_x = [1, size(im3_resize, 2)];
im3_y = [1, size(im3_resize, 1)];

tform = maketform('projective', inv(H34)');
[im4_proj, x_data, y_data] = imtransform( im4_resize, tform);
im4_x = int16(x_data + 0.5 );
im4_y = int16(y_data + 0.5 );

tform = maketform('projective', inv(H34)'*inv(H45)');
[im5_proj, x_data, y_data] = imtransform( im5_resize, tform);
im5_x = int16(x_data + 0.5 );
im5_y = int16(y_data + 0.5 );

%% Calculated Size of Image to be merged
y_min = min( [im1_y(1), im2_y(1), im3_y(1), im4_y(1), im5_y(1) ] );
y_max = max( [im1_y(2), im2_y(2), im3_y(2), im4_y(2), im5_y(2) ] );
x_min = min( [im1_x(1), im2_x(1), im3_x(1), im4_x(1), im5_x(1) ] );
x_max = max( [im1_x(2), im2_x(2), im3_x(2), im4_x(2), im5_x(2) ] );

plot_min_y = 1;
plot_max_y = y_max - y_min;
height = plot_max_y - plot_min_y +10;

plot_min_x = 1;
plot_max_x = x_max - x_min;
width = plot_max_x - plot_min_x + 10;

y_pnrm = [ y_min, y_min + height-1 ];
x_pnrm = [ x_min, x_min + width-1 ];

%% Merge With Max Operation
merged1 = uint8( zeros(height, width, 3) );
im1_y_d = max(im1_y(1) -y_min, 0) + 1;
im1_x_l = max(im1_x(1) -x_min, 0) + 1;
im1_rng_y = im1_y_d:im1_y_d + size(im1_proj, 1) -1;
im1_rng_x = im1_x_l:im1_x_l + size(im1_proj, 2) -1;
merged1(im1_rng_y,im1_rng_x,:  ) = im1_proj ;

im2_y_d = max(im2_y(1) -y_min, 0) + 1;
im2_x_l = max(im2_x(1) -x_min, 0) + 1;
im2_rng_y = im2_y_d:im2_y_d + size(im2_proj, 1) -1;
im2_rng_x = im2_x_l:im2_x_l + size(im2_proj, 2) -1;
merged2 = uint8( zeros(height, width, 3) );
merged2(im2_rng_y,im2_rng_x,:  ) = im2_proj ;

im3_y_d = max(im3_y(1) -y_min, 0) + 1;
im3_x_l = max(im3_x(1) -x_min, 0) + 1;
im3_rng_y = im3_y_d:im3_y_d + size(im3_resize, 1) -1;
im3_rng_x = im3_x_l:im3_x_l + size(im3_resize, 2) -1;
merged3 = uint8( zeros(height, width, 3) );
merged3(im3_rng_y,im3_rng_x,:  ) = im3_resize ;

im4_y_d = max(im4_y(1) -y_min, 0) + 1;
im4_x_l = max(im4_x(1) -x_min, 0) + 1;
im4_rng_y = im4_y_d:im4_y_d + size(im4_proj, 1) -1;
im4_rng_x = im4_x_l:im4_x_l + size(im4_proj, 2) -1;
merged4 = uint8( zeros(height, width, 3) );
merged4(im4_rng_y,im4_rng_x,:  ) = im4_proj ;

im5_y_d = max(im5_y(1) -y_min, 0) + 1;
im5_x_l = max(im5_x(1) -x_min, 0) + 1;
im5_rng_y = im5_y_d:im5_y_d + size(im5_proj, 1) -1;
im5_rng_x = im5_x_l:im5_x_l + size(im5_proj, 2) -1;
merged5 = uint8( zeros(height, width, 3) );
merged5(im5_rng_y,im5_rng_x,:  ) = im5_proj ;

% img_pnrm = max( max( max(merged1, merged2), merged3), merged4);
img_pnrm = max( max( max( max(merged1, merged2), merged3), merged4), merged5);
% img_pnrm = max( merged4, merged5);

imshow( img_pnrm );


