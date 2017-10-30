function test_shapes = identify_shapes(file_name)

global r_thresh
global g_thresh
global c_circ
global s_circ
global t_circ
global min_size

testim = iread(file_name, 'double', 'gamma', 2.2);

testR = testim(:, :, 1);
testG = testim(:, :, 2);
testB = testim(:, :, 3);
testY = testR + testG + testB;

shapeR = iclose((testR ./ testY) > r_thresh, ones(5));
shapeG = iclose((testG ./ testY) > g_thresh, ones(5));
blobsR = iblobs(shapeR, 'class', 1, 'boundary', 'area', [min_size, 100000000]);
blobsG = iblobs(shapeG, 'class', 1, 'boundary', 'area', [min_size, 100000000]);

% structure
% shape #1: 1 color, 2 shape, 3 size, 4 blob id
% shape #2, etc.
num_shapes = 0;
test_shapes = zeros(3, 6);
test_sizes = [];
test_pos = [];

if ~isempty(blobsR)
    for i = 1:length(blobsR)
        num_shapes = num_shapes + 1;
        
        circ = blobsR(i).circularity;
        test_shapes(num_shapes, 1) = 1; % red
        
        if circ > c_circ
            test_shapes(num_shapes, 2) = 1; % circle
        elseif circ > s_circ
            test_shapes(num_shapes, 2) = 2; % square
        else
            test_shapes(num_shapes, 2) = 3; % triangle
        end
        
        test_sizes = [test_sizes blobsR(i).bboxarea];
        test_pos = [test_pos blobsR(i).uc];
    end
end

if ~isempty(blobsG)
    for i = 1:length(blobsG)
        num_shapes = num_shapes + 1;
        
        circ = blobsG(i).circularity;
        test_shapes(num_shapes, 1) = 2; % green
        
        if circ > c_circ
            test_shapes(num_shapes, 2) = 1; % circle
        elseif circ > s_circ
            test_shapes(num_shapes, 2) = 2; % square
        else
            test_shapes(num_shapes, 2) = 3; % triangle
        end
        
        test_sizes = [test_sizes blobsG(i).bboxarea];
        test_pos = [test_pos blobsG(i).uc];
    end
end

% ASSUMPTION: one large, one small, and one either
[~, size_order] = sort(test_sizes);

for i = 1:num_shapes
    real_i = size_order(i);
    if i == 1
        test_shapes(real_i, 3) = 1; % small
    elseif i == num_shapes
        test_shapes(real_i, 3) = 2; % large
    else
        sdiff = test_sizes(real_i) - test_sizes(size_order(1));
        ldiff = test_sizes(size_order(num_shapes)) - test_sizes(real_i);
        
        if sdiff < ldiff
            test_shapes(real_i, 3) = 1; % small
        else
            test_shapes(real_i, 3) = 2; % large
        end
    end
end

[~, pos_order] = sort(test_pos);
test_shapes = test_shapes(pos_order, :);

end