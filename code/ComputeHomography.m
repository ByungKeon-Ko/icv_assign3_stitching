
function h = ComputeHomography( pts1, pts2, n_subset )

A = zeros(2*size(pts1, 2),  9);

A(1:2:end, 4:5) = pts1' ;
A(1:2:end, 6) = 1;
A(1:2:end, 7:9) = -repmat(pts2(2,:)', 1, 3) .* [pts1', ones(size(pts1,2), 1)] ;
A(2:2:end, 1:2) = pts1' ;
A(2:2:end, 3) = 1;
A(2:2:end, 7:9) = -repmat(pts2(1,:)', 1, 3) .* [pts1', ones(size(pts1,2), 1)] ;

% U : (2*#of_pts) * (2*#of_pts), S : (2*#of_pts) * 9, V : 9*9
[U,S,V] = svd(A) ;
% h = V(:,9)./V(9,9) ;
h = V(:,9) ;
h = reshape( h, 3,3 )';




