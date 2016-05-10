function  DisplayMatches( f1, f2, image1, image2, matches )
%% ICV Assignment # 2 
% NAME : EU YOUNG KIM
% SNUID: 2014-22547
%
% This function visualizes the matchings of features extrated from two
% consecutive images of a scene 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imagesc(cat(2, image1, image2));
axis image off;

x_1 = f1(1, matches(1,:));
y_1 = f1(2, matches(1,:));
x_2 = f2(1, matches(2,:)) + 256;
y_2 = f2(2, matches(2,:));
hold on ;

corr = line([x_1 ; x_2], [y_1 ; y_2]);
set(corr, 'linewidth', 1, 'color', 'y');
end

