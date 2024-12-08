
[X1,X2]=meshgrid(-1:0.05:1);
% Establish a matrix of variables with a variable resolution of 0.05
Z=X1.^2+2*X2.^2-0.3*cos(3*pi*X1)-0.4*cos(4*pi*X2)+0.7;
% Applying the objective function to matrices

surfc(X1,X2,Z,'FaceAlpha',0.7)
% Establish a 3D image with transparency set to 0.7

hold on

colormap hsv % Color the graph
colorbar % Add Color Bar
