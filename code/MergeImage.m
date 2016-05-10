
function [ img_pnrm, y_pnrm, x_pnrm ] = MergeImage( im1, im2, H )

%% Projective Transform each images
tform = maketform('projective', H');
[im1_proj, x_data, y_data] = imtransform( im1, tform);

x_data = int16(x_data + 0.5 );
y_data = int16(y_data + 0.5 );
im1_x = double(x_data) ;
im1_y = double(y_data) ;
im2_x = [1, size(im2, 2)];
im2_y = [1, size(im2, 1)];

%% Calculated Size of Image to be merged
min_y = 1;
max_y = max(im1_y(2), im2_y(2)) - min(im1_y(1), im2_y(1));
height = max_y - min_y +10;

min_x = 1;
max_x = max(im1_x(2), im2_x(2)) - min(im1_x(1), im2_x(1));
width = max_x - min_x + 10;

y_pnrm = [ min( im1_y(1), im2_y(1)), min( im1_y(1), im2_y(1)) + height-1 ];
x_pnrm = [ min( im1_x(1), im2_x(1)), min( im1_x(1), im2_x(1)) + width-1 ];

%% Merge With Max Operation
merged1 = uint8( zeros(height, width, 3) );
im1_y_d = max(im1_y(1) -min(im1_y(1),im2_y(1)) , 0) + 1;
im1_x_l = max(im1_x(1) -min(im1_x(1),im2_x(1)) , 0) + 1;

im1_rng_y = im1_y_d:im1_y_d + size(im1_proj, 1) -1;
im1_rng_x = im1_x_l:im1_x_l + size(im1_proj, 2) -1;
merged1(im1_rng_y,im1_rng_x,:  ) = im1_proj ;

im2_y_d = max(im2_y(1) -min(im1_y(1),im2_y(1)) , 0) + 1;
im2_x_l = max(im2_x(1) -min(im1_x(1),im2_x(1)) , 0) + 1;
im2_rng_y = im2_y_d:im2_y_d + size(im2, 1) -1;
im2_rng_x = im2_x_l:im2_x_l + size(im2, 2) -1;
merged2 = uint8( zeros(height, width, 3) );
merged2(im2_rng_y,im2_rng_x,:  ) = im2 ;

img_pnrm = max(merged1, merged2);

% imshow( img_pnrm );


end

