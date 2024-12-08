function [Shortest_Route, Shortest_Length] = optimized_ACO_TSP(C, params)
% Optimized Ant Colony Optimization for TSP
% Input:
%   C: City coordinates matrix [x,y]
%   params: Structure containing parameters
% Output:
%   Shortest_Route: Best route found
%   Shortest_Length: Length of best route
C = [[1304,2312];[3639,1315];
    [4312,790];[4386,570];[3007,1970];
    [2562,1756];[2788,1491];[2381,1676];
[4177,2244];[2370,2975]];
% Set default parameters if not provided
if nargin < 2
    params.NC_max = 300;  % Maximum iterations
    params.m = 10;        % Number of ants
    params.Alpha = 1;     % Pheromone importance
    params.Beta = 5;      % Distance importance
    params.Rho = 0.5;     % Evaporation rate
    params.Q = 10;        % Pheromone intensity
end

% Extract parameters
NC_max = params.NC_max;
m = params.m;
Alpha = params.Alpha;
Beta = params.Beta;
Rho = params.Rho;
Q = params.Q;

% Initialize problem parameters
n = size(C, 1);
D = calculate_distances(C);
Eta = 1./D;  % Desirability matrix
Tau = ones(n);  % Initial pheromone matrix

% Initialize storage for best solutions
R_best = zeros(NC_max, n);
L_best = inf(NC_max, 1);
L_ave = zeros(NC_max, 1);

% Main iteration loop
for NC = 1:NC_max
    % Generate initial ant positions
    Tabu = zeros(m, n);
    Tabu(:,1) = generate_initial_positions(m, n);
    
    % If not first iteration, use best previous route
    if NC >= 2
        Tabu(1,:) = R_best(NC-1,:);
    end
    
    % Route construction
    Tabu = construct_routes(Tabu, Tau, Eta, Alpha, Beta, m, n);
    
    % Calculate route lengths
    [L, L_best(NC), R_best(NC,:), L_ave(NC)] = evaluate_routes(Tabu, D);
    
    % Update pheromone
    Tau = update_pheromone(Tau, Tabu, L, Q, Rho, n, m);
end

% Get final results
[Shortest_Length, idx] = min(L_best);
Shortest_Route = R_best(idx,:);

% Visualization
plot_results(C, Shortest_Route, L_best, L_ave);
end

function D = calculate_distances(C)
% Calculate distance matrix between cities
n = size(C, 1);
D = zeros(n);
for i = 1:n
    for j = 1:n
        if i ~= j
            D(i,j) = norm(C(i,:) - C(j,:));
        else
            D(i,j) = eps;
        end
    end
end
end

function initial_positions = generate_initial_positions(m, n)
% Generate initial random positions for ants
positions = [];
for i = 1:ceil(m/n)
    positions = [positions, randperm(n)];
end
initial_positions = positions(1:m)';
end

function Tabu = construct_routes(Tabu, Tau, Eta, Alpha, Beta, m, n)
% Construct routes for all ants
for j = 2:n
    for i = 1:m
        visited = Tabu(i,1:(j-1));
        unvisited = setdiff(1:n, visited);
        
        % Calculate selection probabilities
        P = (Tau(visited(end), unvisited).^Alpha) .* (Eta(visited(end), unvisited).^Beta);
        P = P / sum(P);
        
        % Select next city
        cumP = cumsum(P);
        next_city = unvisited(find(cumP >= rand(), 1));
        Tabu(i,j) = next_city;
    end
end
end

function [L, L_best_current, R_best_current, L_ave_current] = evaluate_routes(Tabu, D)
% Evaluate all routes
m = size(Tabu, 1);
L = zeros(m, 1);

for i = 1:m
    route = Tabu(i,:);
    L(i) = sum(D(sub2ind(size(D), route(1:end-1), route(2:end)))) + D(route(end), route(1));
end

L_best_current = min(L);
best_idx = find(L == L_best_current, 1);
R_best_current = Tabu(best_idx,:);
L_ave_current = mean(L);
end

function Tau = update_pheromone(Tau, Tabu, L, Q, Rho, n, m)
% Update pheromone levels
Delta_Tau = zeros(n);
for i = 1:m
    route = Tabu(i,:);
    for j = 1:n-1
        Delta_Tau(route(j), route(j+1)) = Delta_Tau(route(j), route(j+1)) + Q/L(i);
    end
    Delta_Tau(route(end), route(1)) = Delta_Tau(route(end), route(1)) + Q/L(i);
end
Tau = (1-Rho).*Tau + Delta_Tau;
end

function plot_results(C, Route, L_best, L_ave)
% Plot results
figure('Position', [100, 100, 1200, 500]);

% Plot route
subplot(1,2,1);
scatter(C(:,1), C(:,2), 'b', 'filled');
hold on;
for i = 1:length(Route)-1
    plot([C(Route(i),1), C(Route(i+1),1)], [C(Route(i),2), C(Route(i+1),2)], 'g');
end
plot([C(Route(end),1), C(Route(1),1)], [C(Route(end),2), C(Route(1),2)], 'g');
title('Optimized Route');
xlabel('X Coordinate');
ylabel('Y Coordinate');
grid on;

% Plot convergence
subplot(1,2,2);
plot(L_best, 'b-', 'LineWidth', 1.5);
hold on;
plot(L_ave, 'r--', 'LineWidth', 1.5);
title('Convergence Plot');
xlabel('Iteration');
ylabel('Route Length');
legend('Best Length', 'Average Length');
grid on;
end
% 调用优化的ACO-TSP算法
[Shortest_Route, Shortest_Length] = optimized_ACO_TSP(C);
% 打印结果
disp('Shortest Route:');
disp(Shortest_Route);
disp('Shortest Length:');
disp(Shortest_Length);