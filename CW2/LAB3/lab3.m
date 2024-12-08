clc
clear all

[X1,X2]=meshgrid(-1:0.05:1); %in the x-y plane, the x and y is from -1 to 1 with a invterval of 0.5
Z=X1.^2+2*X2.^2-0.3*cos(3*pi*X1)-0.4*cos(4*pi*X2)+0.7; % use a dot to do element multiplication /apply this fucntion to each element in the matrics

mesh(X1,X2,Z)


%surf(X1,X2,Z);
%colormap winter
%colorbar
%surfc(X1,X2,Z) % projection of the contour lines in the 2D pane

%surf(X1,X2,Z,'FaceAlpha',0.1) % color is become ligher, make the surface transparent,change the brightneess of the face color
% 0.5 shows a semitransparent surface

%contour(X1,X2,Z)

c = contourf(X1,X2,Z);
clabel(c) %label the contour plot (with number insert into each countour line)
%contourf(X1,X2,Z) % fill the contour with color
%colorbar

% then plot some vectors

hold on %we need to calculate the gradient

[DX1,DX2]= gradient(Z);

%colorbar
%c=contourf(X1,X2,Z)

quiver(X1,X2,DX1,DX2)% in the 2D coordiante system draw the vecter, teh direction of the arrow is determint by DX1 and DX2
% extends horizontally according to DX1, and extends vertically according to DX2
%hold on
%clabel(c)
colorbar
