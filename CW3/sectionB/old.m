% The coordinates of cities
C = [[1304,2312];[3639,1315];
    [4312,790];[4386,570];[3007,1970];
    [2562,1756];[2788,1491];[2381,1676];
[4177,2244];[2370,2975]];
NC_max=300; % Maximum number of iterations
m=10; % The number of ants
Alpha=1; % control parameter to pheromone importance
Beta=5; % control parameter to desirability importance
Rho=0.5;% evaporation rate 
Q=10; % intensity of pheromone concentration


% STEP1: Parameter initialization
n=size(C,1); % Record the number of cities
D=zeros(n,n); % List a matrix for filling in the distance between cities
for i=1:n
    for j=1:n
        if i~=j
            D(i,j)=((C(i,1)-C(j,1))^2+(C(i,2)-C(j,2))^2)^0.5; % The distance between cities
        else
            D(i,j)=eps;
% The distance between the city and itself is 0, but the reciprocal needs to be taken later, so eps (floating-point relative precision) is taken
        end
    end
end

Eta=1./D; % Desirability, set to 1/distance
Tau=ones(n,n); % Matrix of pheromone concentration at initial stage
Tabu=zeros(m,n); % Matrix recording the creation of routes
NC=1; % Counter for iteration No.
R_best=zeros(NC_max,n); %Best path at any iteration, row number is the iteration number, 
L_best=inf.*ones(NC_max,1); %Best path length by any ants
L_ave=zeros(NC_max,1); % average path length of all ants


while NC<=NC_max % stop when max specified iteration no. is reached


% STEP2: Place m ants randomly on n cities
  Randpos=[]; % randomly allocate m ants to different cities
  for i=1:(ceil(m/n)) % ceil(m/n),The result of m/n is taken as an integer in the positive infinite direction
    Randpos=[Randpos,randperm(n)];
  end
  Tabu(:,1)=(Randpos(1,1:m))';  %the first column of Tabu now stored with
                                  %the m ants starting city
    

% STEP3: m ants choose the next city according to probability, and complete their travel

  for j=2:n % Do not include the city ants are already in
    for i=1:m
      visited=Tabu(i,1:(j-1)); % Record already visited city, not to visit again
      J=zeros(1,(n-j+1)); % Record cities to be visited
      P=J; % Initialize a vector for probability of visiting the cities
      Jc=1;                   
      for k=1:n
        if isempty(find(visited==k, 1)) % if the city is not visited
          J(Jc)=k;
          Jc=Jc+1; % Add 1 more to be visited city
        end
      end

      % Calculate the probability of city to be visited
      for k=1:length(J) % for all to-be-visited city
        P(k)=(Tau(visited(end),J(k))^Alpha)*(Eta(visited(end),J(k))^Beta);
      end
      P=P/(sum(P));

      % Use Roulette Wheel principle to select the next city to be visited
      Pcum=cumsum(P); % find cumulative sum
      Select=find(Pcum>=rand); % if the cumulative sum > the random number
      to_visit=J(Select(1)); % find the next city to vist
      Tabu(i,j)=to_visit; % for ith ant, record the city no. to vist next
    end
  end
  
  %put the best route of the previous iteration to 1st row of Tabu
  %this is just to attemp to add a constraint so that the results for
  %iteration can have good quality 
 
 if NC>=2
    Tabu(1,:)=R_best(NC-1,:);
 end
    

% STEP4: record the best route of this iteration
  L=zeros(m,1); % record route length for m ants
  for i=1:m
    R=Tabu(i,:);%R Route
    for j=1:(n-1)
      L(i)=L(i)+D(R(j),R(j+1)); % original distance plus the distance between jth city and (j+1)th city
    end
    L(i)=L(i)+D(R(1),R(n)); % distance after 1 iteration
  end
  L_best(NC)=min(L);% take the shortest length
  pos=find(L==L_best(NC));
  R_best(NC,:)=Tabu(pos(1),:); % best path after this iteration
  L_ave(NC)=mean(L); % average length after this iteration
  NC=NC+1; % continue the iteration
    

% STEP5: update pheromone concentration
  Delta_Tau=zeros(n,n); % initial matrics about pheromone concentration
  for i=1:m
    for j=1:(n-1)
      Delta_Tau(Tabu(i,j),Tabu(i,j+1))=Delta_Tau(Tabu(i,j),Tabu(i,j+1))+Q/L(i);          
        %the increase rate of pheromone concentration on edge i, j
    end
    Delta_Tau(Tabu(i,n),Tabu(i,1))=Delta_Tau(Tabu(i,n),Tabu(i,1))+Q/L(i);
        %the increase rate of pheromone concentration on the entire route
  end
  Tau=(1-Rho).*Tau+Delta_Tau; % pheromone concentration update considering evaporation rate


% STEP6: clear Tabu
  
  Tabu=zeros(m,n); % until the max iteration number

end


% STEP7: output results
Pos=find(L_best==min(L_best)); % find the best route
Shortest_Route=R_best(Pos(1),:); % best route after the max iteration number
Shortest_Length=L_best(Pos(1)); % the shortest length after max iteration number

figure
    N=length(R);
    scatter(C(:,1),C(:,2)); % in a figure, plot the city locations
    hold on
    plot([C(R(1),1),C(R(N),1)],[C(R(1),2),C(R(N),2)],'r')
    hold on
    for ii=2:N
        plot([C(R(ii-1),1),C(R(ii),1)],[C(R(ii-1),2),C(R(ii),2)],'g')
        hold on
    end
    title('Result of ACO/TSP optimization') % title

figure 
plot(L_best);
hold on ;                        
plot(L_ave,'r');
title('Mean and Optimized distance of travel'); % title

disp(Shortest_Route);
disp(Shortest_Length);