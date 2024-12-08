
[X1,X2]=meshgrid(-1:0.05:1);
% Establish a matrix of variables with a variable resolution of 0.05
Z=X1.^2+2*X2.^2-0.3*cos(3*pi*X1)-0.4*cos(4*pi*X2)+0.7;
% Applying the objective function to matrices

c = contourf(X1,X2,Z); % Establish a 2D contour map
clabel(c); % Mark the values of contour lines

hold on

[DX1,DX2]= gradient(Z);
% Obtain the gradient of the function
quiver(X1,X2,DX1,DX2)
% Place the gradient at the corresponding position in the graph

colormap hsv % Color the graph
colorbar % Add Color Bar