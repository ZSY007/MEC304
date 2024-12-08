clc
clear all
a=0; b=1; % Boundary of variable

f=@(x) (x-1.5)*x+1; % Objective function
ezplot('(x-1.5)*x+1',[0,1]) % Draw objective function within x in [0,1]
eps=0.001; % Error limited to 0.01
step=0;
while((b-a)>=eps)
    x1=a+0.382*(b-a);
    x2=a+0.618*(b-a); % 0.618=(x2-a)/(b-a)=(b-x1)/(b-a)
    if f(x1)<f(x2)
            b=x2; % a<x<x2
    elseif f(x1)>f(x2)
            a=x1; % x1<x<b
    else
        a=x1;
        b=x2; % x1<x<x2
    end
    
    step=step+1;
    x=(a+b)/2;
    S(step,:) = [step,x,f(x)];

end

hold on;
plot(S(:,2),S(:,3),'ro-')
% Draw a change line for the iteration point in the graph

x=(a+b)/2;
disp(['x = ',num2str(x)])
disp(['f(x) = ',num2str(f(x))])
disp(['step = ',num2str(step)])
