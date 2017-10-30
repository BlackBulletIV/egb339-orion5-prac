function [] = print_shape(shape_type, index, shape)

if shape(1) == 1
    c = 'red';
elseif shape(1) == 2
    c = 'green';
else
    c = 'n/a';
end

if shape(2) == 1
    sh = 'circle';
elseif shape(2) == 2
    sh = 'square';
elseif shape(2) == 3
    sh = 'triangle';
else
    sh = 'n/a';
end

if shape(3) == 1
    sz = 'small';
elseif shape(3) == 2
    sz = 'large';
else
    sz = 'n/a';
end

fprintf('%s shape %i is a %s %s %s located at %.1fmm, %.1fmm\n', shape_type, index, sz, c, sh, shape(5), shape(6));

end

