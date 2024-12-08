eps = 0.001; % Error limited to 0.001
x10 = 1;
x20 = 1;
x30 = 1; % Initial value
alpha = 0.135; % Learning rate
k = 0; % Iterations
err = 1;

f0 = 4*x10^2 + 3*x20^2 + 5*x30^2 +6*x10*x20 + x10*x30 -3*x10 -2*x20 +15;
% Objective function

S_space = [k,x10,x20,x30,f0];

while err >= eps % Continue iteration when there is a significant error
  df1dx1 = 8*x10 + 6*x20 +x30 - 3;
  x11 = x10 - alpha*df1dx1;
  %err1 = absolute value of (x11 - x10);
  
  df1dx2 = 6*x10 + 6*x20 - 2;
  x21 = x20 - alpha*df1dx2;
  %err2 = absolute value of (x21 - x20);
  
  df1dx3 = x10 + 10*x30;
  x31 = x30 - alpha*df1dx3;
  %err3 = absolute value of (x31 - x30);
  
  %Subtract the gradient from the result of the previous iteration to obtain the answer for this iteration
  
  %err = Vector length of [err1 err2 err3]
  df1dx = [df1dx1,df1dx2,df1dx3];
  err = norm(df1dx);
  
  k = k + 1; % Iterations +1
  x10 = x11;
  x20 = x21;
  x30 = x31; % Obtain the answer after iteration

  f0 = 4*x10^2 + 3*x20^2 + 5*x30^2 +6*x10*x20 + x10*x30 -3*x10 -2*x20 +15;
  S_space(k,:) = [k,x10,x20,x30,f0];
  
  if (k>20000) % End loop when the number of steps is too large
    break
  end
  
end

disp(['x1 = ',num2str(x10)])
disp(['x2 = ',num2str(x20)])
disp(['x3 = ',num2str(x30)])
disp(['f = ',num2str(f0)])
disp(['step = ',num2str(k)])

