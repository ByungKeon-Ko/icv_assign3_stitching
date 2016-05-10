    function [ H ] = my_DLT( corr_feat)
%% ICV Assignment # 2 
% NAME : EU YOUNG KIM
% SNUID: 2014-22547
%
% This function computes a homography using DLT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% correspondences btw (x1,y1) <-> (x1',y1')

A = [zeros(1,3),corr_feat(1).homog_pos1',(-1.*corr_feat(1).homog_pos2(2))*corr_feat(1).homog_pos1' ; 
    corr_feat(1).homog_pos1'   zeros(1,3)  (-1.*corr_feat(1).homog_pos2(1))*corr_feat(1).homog_pos1' ; 
    zeros(1,3) corr_feat(2).homog_pos1'   (-1.*corr_feat(2).homog_pos2(2))*corr_feat(2).homog_pos1' ; 
    corr_feat(2).homog_pos1'   zeros(1,3)  (-1.*corr_feat(2).homog_pos2(1))*corr_feat(2).homog_pos1' ; 
    zeros(1,3) corr_feat(3).homog_pos1'   (-1.*corr_feat(3).homog_pos2(2))*corr_feat(3).homog_pos1' ; 
    corr_feat(3).homog_pos1'   zeros(1,3)  (-1.*corr_feat(3).homog_pos2(1))*corr_feat(3).homog_pos1' ; 
    zeros(1,3) corr_feat(4).homog_pos1'   (-1.*corr_feat(4).homog_pos2(2))*corr_feat(4).homog_pos1' ;
    corr_feat(4).homog_pos1'   zeros(1,3)  (-1.*corr_feat(4).homog_pos2(1))*corr_feat(4).homog_pos1'];

% obtaining SVD of A
[~,~,V] = svd(A);
H = reshape(V(:,end), 3, 3)';
    
end

