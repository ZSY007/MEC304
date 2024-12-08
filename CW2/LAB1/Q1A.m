function retval = inecond1(D,H)
  % use grid points as inputs
  % you can find out the value of this constraint
  % with proper grid points D(i,:), H(:,j)
  % later on, when we draw curves/contours
  % we need to make this retval to be equal 0
  % this is related to proper grid points
 
  retval = 2*D-H;
end
function retval = obj_exercise(X1,X2)
  retval = 0.1*X1 + 0.05773*X2; % Objective function
 end

x1 = 6:0.1:20; % Constraint of x1
x2 = 7:0.1:20; % Constraint of x2
[X1, X2] = meshgrid(x1,x2);% Establish a 2D grid
ineq1 = inecond1(X1, X2); % Constraint equality function
f1 = obj_exercise(X1, X2); % Objective function
[C2, han2] = contour(x1,x2,ineq1,[0.1,0.1],'b-');
% Draw the constraint function at a resolution of 0.1
hold on
[C, han] = contour(x1,x2,f1,25,'g-');
% Draw 25 green contour lines of objective function
clabel(C,han) % Give the value of each contour line
gtext('Ans') % Select target point
