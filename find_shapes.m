function shape_ids = find_shapes(shape_blobs, test_shapes, imr, img)

global r_thresh
global g_thresh
global c_circ
global s_circ
global t_circ
global axis_ratio

shape_ids = zeros(size(test_shapes, 1), 1);

for i = 1:size(test_shapes, 1)
    cur_size = 0;
    cur_id = 0;
    
    if test_shapes(i, 1) == 1
        thresh = r_thresh;
        threshim = imr;
    else
        thresh = g_thresh;
        threshim = img;
    end
    
    for j = 1:length(shape_blobs)
        b = shape_blobs(j);
        x = int16(b.uc);
        y = int16(b.vc);
        
        if (b.b / b.a) > axis_ratio && median(median(threshim(y-7:y+7, x-7:x+7))) > thresh % color match
            shape_match = 0;
            
            if b.circularity > c_circ
                if test_shapes(i, 2) == 1
                    shape_match = 1;
                end
            elseif b.circularity > s_circ
                if test_shapes(i, 2) == 2
                    shape_match = 1;
                end
            elseif b.circularity > t_circ
                if test_shapes(i, 2) == 3
                    shape_match = 1;
                end
            end
            
            if shape_match
                if cur_size
                    if test_shapes(i, 3) == 1 && b.area < cur_size
                        cur_size = b.area;
                        cur_id = j;
                    elseif test_shapes(i, 3) == 2 && b.area > cur_size
                        cur_size = b.area;
                        cur_id = j;
                    end
                else
                    cur_id = j;
                    cur_size = b.area;
                end
            end
        end
    end
    
    if cur_id
       shape_ids(i) = cur_id;
    end
end

end

