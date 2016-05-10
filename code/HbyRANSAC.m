
function max_H = HbyRANSAC( matches, f1, f2 )

%% RANSAC Prameters
t = 1.25;
p = 0.99;

N = 1000*1000 ;
smpl_cnt = 0;
n_subset = 4;
max_H = 0;
max_inliers = 0;

match_list = 1 : size(matches, 2) ;

while ( N > smpl_cnt ) ;

	if mod(smpl_cnt, 10) == 0 ;
		fprintf('RANSAC--ing : %d\n', smpl_cnt);
	end

	sel = randsample( match_list, n_subset );
	pts1 = f1(1:2,matches(1, sel));
	pts2 = f2(1:2,matches(2, sel));

	H = ComputeHomography( pts1, pts2, n_subset );

	%% can be optimzied more using vector calcuation
	cnt_inliers = 0;
	for i =1:1:size(matches, 2);
		pt1 = f1(1:2, matches(1,i) );
		pt2 = f2(1:2, matches(2,i) );
		pt1_homo = [pt1; 1];
		pt2_homo = [pt2; 1];

		pt1_c1 = H*pt1_homo ;
		pt1_convert = pt1_c1(1:2,:) / pt1_c1(3,:);
		
		pt2_c1 = H\pt2_homo ;
		pt2_convert = pt2_c1(1:2,:) / pt2_c1(3,:);
		
		d_error = sum( (pt1-pt2_convert).^2) + sum((pt2-pt1_convert).^2 ) ;
		if d_error < t;
			cnt_inliers = cnt_inliers + 1;
		end
	end

	if cnt_inliers > max_inliers;
		max_inliers = cnt_inliers;
		max_H = H;
	end

	if cnt_inliers ~= 0;
		epsilon = 1 - cnt_inliers/size(matches, 2) ;
		N = log(1-p)/log(1-(1-epsilon)^n_subset);
		% fprintf('N = %f\n', N);
	end
	% if cnt_inliers == 0;
	% 	fprintf('fffffffff\n');
	% end
	smpl_cnt = smpl_cnt + 1;
end

end

