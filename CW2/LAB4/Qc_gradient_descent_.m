eps = 0.001; % Error limited to 0.001
x10 = 4;
x20 = 3; % Initial value
alpha = 0.0005; % Learning rate
k = 0; % Iterations
err = 1;

f0 = (-13+x10+((5-x20)*x20-2)*x20)^2 + (-29+x10+((x20+1)*x20-14)*x20)^2;
% Objective function

S_space = [k,x10,x20,f0];

while err >= eps % Continue iteration when there is a significant error
  df1dx1 = (-13+x10+((5-x20)*x20-2)*x20)*2 + (-29+x10+((x20+1)*x20-14)*x20)*2;
  x11 = x10 - alpha*df1dx1;
  %err1 = absolute value of (x11 - x10);
  
  df1dx2 = (-13+x10+((5-x20)*x20-2)*x20)*2*(-3*x20^2+10*x20-2) + (-29+x10+((x20+1)*x20-14)*x20)*2*(3*x20^2+2*x20-14);
  x21 = x20 - alpha*df1dx2;
  %err2 = absolute value of (x21 - x20);
  
  %Subtract the gradient from the result of the previous iteration to obtain the answer for this iteration
  
  %err = Vector length of [err1 err2]
  df1dx = [df1dx1,df1dx2];
  err = norm(df1dx);
  
  k = k + 1; % Iterations +1
  x10 = x11;
  x20 = x21; % Obtain the answer after iteration

  f0 = (-13+x10+((5-x20)*x20-2)*x20)^2 + (-29+x10+((x20+1)*x20-14)*x20)^2;
  S_space(k,:) = [k,x10,x20,f0];
  
  if (k>20000) % End loop when the number of steps is too large
    break
  end
  
end

disp(['x1 = ',num2str(x10)])
disp(['x2 = ',num2str(x20)])
disp(['f = ',num2str(f0)])
disp(['step = ',num2str(k)])

xx = linspace(-15,15,225);
yy = linspace(-15,15,225); % Variable variation range in the graph

[XX,YY]=meshgrid(xx,yy);
ZZ = (-13+XX+((5-YY).*YY-2).*YY).^2 + (-29+XX+((YY+1).*YY-14).*YY).^2;
surf(XX,YY,ZZ); % Create 3D graph

hold on;
plot3(S_space(:,2),S_space(:,3),S_space(:,4),'ro-')
% Draw a change line for the iteration point in the 3D graph
figure
plot3(S_space(:,2),S_space(:,3),S_space(:,4),'o-')
% Draw a change line for the iteration point