alpha1 = 0.0031;
beta = 0.33;

eps = 0.001; % Error limited to 0.001
x10 = -1.2;
x20 = 1; % Initial value
alpha = alpha1; % Learning rate
k = 0; % Iterations
err = 1;

f0 = 100*(x20-x10^2)^2 + (1-x10)^2;
% Objective function

S_space = [k,x10,x20,f0];

while err >= eps % Continue iteration when there is a significant error
  df1dx1 = -400*x10*(x20-x10^2) - 2*(1-x10);
  x11 = x10 - alpha*df1dx1;
  %err1 = absolute value of (x11 - x10);
  
  df1dx2 = 200*(x20-x10^2);
  x21 = x20 - alpha*df1dx2;
  %err2 = absolute value of (x21 - x20);
  
  %Subtract the gradient from the result of the previous iteration to obtain the answer for this iteration

  %err = Vector length of [err1 err2 err3]
  df1dx = [df1dx1,df1dx2];
  err = norm(df1dx);
  
  f0 = 100*(x20-x10^2)^2 + (1-x10)^2;
  f1 = 100*(x21-x11^2)^2 + (1-x11)^2;
  
  A = f1-f0;
  B = -0.5*alpha*(norm(df1dx)).^2;
  
  if (A > B) % Choose whether to choose a smaller learning rate Ba
    alpha=alpha1*beta;
  else
    alpha=alpha1;
  end
  
 
  k = k + 1; % Iterations +1
  x10 = x11;
  x20 = x21; % Obtain the answer after iteration

  S_space(k,:) = [k,x10,x20,f1];
  
  if (k>20000) % End loop when the number of steps is too large
    break
  end
  
end

disp(['x1 = ',num2str(x10)])
disp(['x2 = ',num2str(x20)])
disp(['f = ',num2str(f0)])
disp(['step = ',num2str(k)])

xx = linspace(-5,5,100);
yy = linspace(-5,5,100); % Variable variation range in the graph

[XX,YY]=meshgrid(xx,yy);
ZZ = 100.*XX.^4 - 200.*(XX.^2).*YY + 100.*YY.^2 + XX.^2 - 2.*XX +1;
surf(XX,YY,ZZ); % Create 3D graph

hold on;
plot3(S_space(:,2),S_space(:,3),S_space(:,4),'ro-')
% Draw a change line for the iteration point in the 3D graph
figure
plot3(S_space(:,2),S_space(:,3),S_space(:,4),'o-')
% Draw a change line for the iteration point


colormap hsv % Color the graph
colorbar % Add Color Bar