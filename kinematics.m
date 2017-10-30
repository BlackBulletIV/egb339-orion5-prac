clear; clc; close all;

% settings
global r_thresh
global g_thresh
global b_thresh
global c_circ
global s_circ
global t_circ
global axis_ratio
global min_size
global max_size

% imaging settings
r_thresh = 0.6;
g_thresh = 0.6;
b_thresh = 0.5;
c_circ = 0.9;
s_circ = 0.7;
t_circ = 0.5;
axis_ratio = 0.8;
min_size = 400;
max_size = 1000000000;

% source images
source_file = 'source.jpg';
dest_file = 'dest.jpg';
exam_file = 'prac.jpg';

% arm height settings
hover_height = 0.1;
pickup_height = -0.005;
release_height = -0.005;

% identify specified shapes

source_shapes = identify_shapes(source_file);
dest_shapes = identify_shapes(dest_file);

% find calibration shapes

im = iread(exam_file, 'double', 'gamma', 2.2);

imR = im(:, :, 1);
imG = im(:, :, 2);
imB = im(:, :, 3);
imY = imR + imG + imB;
imr = imR ./ imY;
img = imG ./ imY;
imb = imB ./ imY;

calib = imb > b_thresh;
calib = iclose(calib, ones(5));
calib_blobs = iblobs(calib, 'class', 1, 'area', [min_size, max_size]);

% truncate blobs to largest 9 if necessary
if length(calib_blobs) > 9
    [~, calib_index] = sort(calib_blobs.bboxarea, 'descend');
    calib_blobs = calib_blobs(calib_index);
    calib_blobs = calib_blobs(1:9);
end

% locate specified shapes

shap = imr > r_thresh | img > g_thresh;
shap = iclose(shap, ones(5));
shape_blobs = iblobs(shap, 'class', 1, 'boundary', 'area', [min_size, max_size]);

source_shapes(:, 4) = find_shapes(shape_blobs, source_shapes, imr, img);
dest_shapes(:, 4) = find_shapes(shape_blobs, dest_shapes, imr, img);
source_blobs = [];
dest_blobs = [];

for i = 1:3
    if source_shapes(i, 4)
        b = shape_blobs(source_shapes(i, 4));
        source_blobs = [source_blobs b];
    end
end

for i = 1:3
    if dest_shapes(i, 4)
        b = shape_blobs(dest_shapes(i, 4));
        dest_blobs = [dest_blobs b];
    end
end

% homography 

% left to right, top to bottom (with x axis going down, y axis going right)
% origin top left
q = [
    20 20;    20 290;    20 560;
    182.5 20; 182.5 290; 182.5 560;
    345 20;   345 290;   345 560
];

% sort blobs
for i = 1:length(calib_blobs)
    blob_factors(i) = calib_blobs(i).vc * 10 + calib_blobs(i).uc;
end

[~, sort_index] = sort(blob_factors);

for i = 1:length(sort_index)
    b = calib_blobs(sort_index(i));
    pb(1, i) = b.uc;
    pb(2, i) = b.vc;
end

H = homography(pb, q');

for i = 1:length(source_blobs)
    b = source_blobs(i);
    rp = homtrans(H, [b.uc; b.vc]);
    source_shapes(i, 5) = rp(1);
    source_shapes(i, 6) = rp(2);
    print_shape('Source', i, source_shapes(i, :));
end

for i = 1:length(dest_blobs)
    b = dest_blobs(i);
    rp = homtrans(H, [b.uc; b.vc]);
    dest_shapes(i, 5) = rp(1);
    dest_shapes(i, 6) = rp(2);
    print_shape('Destination', i, dest_shapes(i, :));
end

disp('Press key to continue...');
pause()

% move blocks

claw = TheClaw();
claw.open();

for i = 1:3
    sx = source_shapes(i, 5) / 1000;
    sy = source_shapes(i, 6) / 1000;
    dx = dest_shapes(i, 5) / 1000;
    dy = dest_shapes(i, 6) / 1000;
    
    disp(['Going to shape ' num2str(i)]);
    claw.move_to(sx, sy, hover_height);
    disp(['Grabbing shape ' num2str(i)]);
    claw.move_to(sx, sy, pickup_height);
    claw.close();
    claw.move_to(sx, sy, hover_height);
    disp(['Moving shape ' num2str(i)]);
    claw.move_to(dx, dy, hover_height);
    disp(['Delivering shape ' num2str(i)]);
    claw.move_to(dx, dy, release_height);
    claw.open();
    claw.move_to(dx, dy, hover_height);
end

claw.stop();
