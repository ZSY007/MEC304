function retval = inecond1(D,H)
  % use grid points as inputs
  % you can find out the value of this constraint
  % with proper grid points D(i,:), H(:,j)
  % later on, when we draw curves/contours
  % we need to make this retval to be equal 0
  % this is related to proper grid points
 
  retval = 2*D-H;
 end