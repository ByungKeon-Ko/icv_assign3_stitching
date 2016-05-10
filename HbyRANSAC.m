function [ H ] = HbyRANSAC( matches , f1, f2 )
%% ICV Assignment # 2 
% NAME : EU YOUNG KIM
% SNUID: 2014-22547
%
% This function computes a homography using RANSAC with adaptive
% determination method.
% RANSAC threshold is set to 1.25 and p is set to 0.99
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = length(matches)+1;
threshold = 1.25;
p = 0.99;
% init_epsilon = 1.0;
iter = 0;
max_count = 0;

while (N > iter)
    % randomly selecting 4 putative correspondences
    rndsample = randperm(length(matches),4);

    % correspondences btw (x1,y1) <-> (x1',y1')
    corr_feat = struct();
%     inlier_feat = struct();
    
    for i = 1:4
        corr_feat(i).homog_pos1 = padarray(f1(1:2,matches(1,rndsample(i))), [1 0], 1, 'post'); % (xi,yi,1)
        corr_feat(i).homog_pos2 = padarray(f2(1:2,matches(2,rndsample(i))), [1 0], 1, 'post'); % (xi',yi',1)
    end
    
    H = my_DLT(corr_feat);
    
    %% RANSAC
    count = 0;
    for i = 1:length(matches)   
        pt1 = padarray(f1(1:2,matches(1,i)), [1 0], 1, 'post');
        pt2 = padarray(f2(1:2,matches(2,i)), [1 0], 1, 'post');
        mapping = H*pt1;
        mapping = mapping/mapping(3);
        inv_mapping = H\pt2;
        inv_mapping = inv_mapping/inv_mapping(3);
        
        d = sum((pt1 - inv_mapping).^2) + sum((pt2 - mapping).^2);
        if (d<threshold)
            count = count + 1;
%             inlier_feat(count).homog_pos1 = pt1;
%             inlier_feat(count).homog_pos2 = pt2;
        end
    end
    epsilon = 1-count/length(matches);
%     if (epsilon < init_epsilon)
        N = log(1-p)/log(1-(1-epsilon)^2);
%         init_epsilon = epsilon;
%         H = my_DLT(inlier_feat);
%     end
    
    % using H with the most inliers
    if (max_count < count)
        max_count = count;
        max_H = H;
    end
    
    iter = iter + 1;
end
if (max_H ~= 0)
    H = max_H;
end

end

