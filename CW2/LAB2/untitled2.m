%------------------------------------------------------------------
% Example 6.3.1: Golden section search                             
%------------------------------------------------------------------
   clc
   clear
   n = 1;
   p = 200;
   r = 0;
   s = 0;
   mu = 0;
   h = 1;
   dx = 1;	
   x = zeros (n,1);
   d = ones (n,1);
   t = zeros (p,1);
   y = zeros (p,1);
   fun631 = inline('x(1)*(x(1) - 1.5) + 1', 'x');

% Find a three-point pattern 

   fprintf ('Example 6.3.1: Golden Section Search\n');
   [a,b,c,err,k] = bracket (h,x,d,mu,fun631,'','');
   fprintf ('\nFunction evaluations = %g',k);
   fprintf ('\nThree-point pattern = (%.7f,%.7f,%.7f).',a,b,c);

% Reduce interval of uncertainty     

   tol = sqrt(eps);
   [h,ev] = golden (x,d,a,c,tol,mu,fun631,'','');
   fprintf ('\nOptimal x = %.7f',x(1));
   fprintf ('\nf(%g) = %.7f',x(1),fun631(x));
   fprintf ('\nFunction evaluations = %g\n',ev);
   
% Graph the function 

   for i = 1 : p
      t(i) = (i-1)*dx/(p-1);
      x(1) = t(i);
      y(i) = fun631(x);
   end
   graphxy (t,y,'Golden Section Search','y','F(y)')
%------------------------------------------------------------------

   




