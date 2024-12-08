clear all
close all
clc


d = 5:0.1:8; % Side constraint on d
h = 5:0.1:20; % Side constraint on h

[D, H] = meshgrid(d,h);
% mesh the 2D plane by grids


eq1 = eqcond1(D,H); % a function for inequality constraint

ineq1 = inecond1(D,H); % a function for equality constraint% 

f1 = obj_lab1(D,H); % objective function

% draw iso-contour of the surface, eq1, related to 
%equality/inequality constrait numner, i.e. level
%level = 250
% when use this "contour" function
% if to define the leval of iso-contour
% specify it as a 2 element row vector
% k = 250 [250,250] 
[C1, han1] = contour(d,h,eq1,[250,250],'r-');

%figure

%mesh(D, H, eq1)
%hold on
%[C1, han1] = contour(d,h,eq1,[250,250],'r-');

hold on %% you will plot additional figures without overwriting

gtext('h1')

[C2, han2] = contour(d,h,ineq1,[0,0],'b-');
gtext('g1')

[C, han] = contour(d,h,f1,20,'g-');
clabel(C,han) % give the value of each iso contour