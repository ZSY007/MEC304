function [h,ev] = golden (x,d,a,c,tol,mu,f,p,q,dm)
%-----------------------------------------------------------------------
% Usage:        [h,ev] = golden (x,d,a,c,tol,mu,f,p,q,dm)
%
% Description:  Use the golden section search to solve the following
%               one-dimensional optimization problem:
%
%                   minimize:   F(y) = f(x+y*d) + mu*(P(x) + Q(x))
%                   subject to: a < y < c
%
%               It is assumed that F(y) has a minimum in the interval
%               [a,c]. The interval [a,c] is obtained by a call to
%               function bracket.  Here P(x) is a penalty function
%               associated with the r equality constraints, p(x) = 0,
%               and Q(x) is a penalty function associated with the s
%               inequality constraints, q(x) >= 0.
%
% Inputs:       x   = n by 1 start vector
%               d   = n by 1 search direction vector
%               a   = lower limit on step length
%               c   = upper limit on step length
%               tol = upper bound on size of interval of uncertainty    
%               mu  = penalty paramter (mu >= 0)
%               f   = name of objective function: minimize: f(x)
%               p   = name of equality constraint function: p(x) = 0
%               q   = name of inequality constraint function: q(x) >= 0
%
%                     The forms of f, p, and q are:
%
%                     function y = f(x)
%                     function u = p(x)
%                     function v = q(x)
%
%                     When f is called with n by 1 vector x, it must
%                     return the scalar y = f(x).  When p is called with 
%                     n by 1 vector x,it must compute r by 1 vector 
%                     u = p(x). When q is called with n by 1 vector x, 
%                     it must compute s by 1 vector v = q(x).
%               
%               dm = optional display mode.  If present,
%                    intermediate values are displayed.
% 
% Outputs:      h  = optimal step length
%               ev = number of scalar function evaluations
%
% Notes:        If F(y) is a unimodal function, then the returned value
%               is within tol*|z| of the exact solution z.  It is
%               recommended that tol be no smaller than the square
%               root of the machine epsilon. */
%-----------------------------------------------------------------------

% Initialize

   chkvec (x,1,'golden');
   chkvec (d,2,'golden');
   tol = args (tol,eps,tol,5,'golden');
   mu  = args (mu,0,mu,6,'golden');

   display = nargin > 9; 
   ev = 2;
   em = sqrt(eps);
   n = length (x);
   u = zeros (n,1);
       
% Reduce the length of the interval of uncertainty/

   g1 = (3 - sqrt(5))/2;
   g2 = 1 - g1;
   b1 = a + g1*(c - a);
   b2 = a + g2*(c - a);
   u = x + b1*d;
   F1 = fmu (f,p,q,u,mu);
   u = x + b2*d;
   F2 = fmu (f,p,q,u,mu);
   b = (a + c)/2;
   if display
      fprintf ('\ngolden section search in [%g, %g]',a,c); 
   end
   
   while (c - a) > 2*em*b 
      if F1 < F2
       	 c = b2;
       	 b2 = b1; 
      	 F2 = F1;
         b1 = a + g1*(c - a);
         u = x + b1*d;
         F1 = fmu (f,p,q,u,mu);
      else 
         a = b1;
         b1 = b2; 
         F1 = F2;
         b2 = a + g2*(c - a);
         u = x + b2*d;
         F2 = fmu (f,p,q,u,mu);
      end
      if display
         fprintf ('\n [a b1 b2 c] = [%g %g %g %g]',a,b1,b2,c);
      end
      b = (a + c)/2;   
      ev = ev + 1;
   end

% Finalize

   if display
      wait
   end
   h = b;
%-----------------------------------------------------------------------

   
