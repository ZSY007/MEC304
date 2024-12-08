# -*- coding: utf-8 -*-
# pacmanAgents.py
# ---------------

import sys
from pacman import Directions
from game import Agent
import random
import game
import util

#############################################
#                Ant Agent:                 #
#           Your AI pacman agent!           #
#      Please Read Comments Carefully!      #
#############################################

pheromoneGraph = {}
closedEntry = []

class AntAgent(Agent):
    def __init__(self):
        # 调整参数以提高稳定性
        self.alpha = 1.0    # 保持信息素重要度适中
        self.beta = 2.5     # 增加食物启发式的权重
        self.rho = 0.15     # 略微增加信息素挥发率
        self.Q = 150.0      # 增加信息素强度
        
        # 增加蚂蚁数量以提高探索能力
        self.bestPath = []
        self.numAnt = 50    # 增加蚂蚁数量
        self.numSim = 200   # 增加模拟次数
        self.NumTotal = self.numAnt * self.numSim
        
    # move instructions for Pacman
    def getAction(self, state):
        if self.bestPath != []:
            return self.bestPath.pop(0)
        simulationNum = 0
        # keep simulating until a best path is found or the max number of simulation is reached
        while simulationNum < self.NumTotal or self.bestPath == []:
            # create ant in Class Ant
            ant = Ant(state, self.alpha, self.beta)
            while True:
                # get the result of ants movement
                result = ant.move()
                # find a feasible path
                if result == 0:
                    # decide the best path
                    if self.bestPath == []:
                        self.bestPath = ant.directionPath[:]
                        print("Found better length " + str(len(ant.directionPath)) + " of the optimal path \r")

                    # update the best path if another shorter path is found
                    elif len(ant.directionPath) < len(self.bestPath):
                        self.bestPath = ant.directionPath[:]
                        print("Found better length " + str(len(ant.directionPath)) + " of the optimal path \r")
                    # update pheromone of the shorter path
                    self.updatePheromone(ant)
                # no path is found
                if result <= 0:
                    break

            # if one simulation is completed, print the number of current simulation and decay pheromone
            if simulationNum % self.numAnt == 0:
                self.decayPheromone(ant)
                sys.stdout.write('Simulation: %d/%d\r' % (simulationNum / self.numAnt, self.numSim))
                sys.stdout.flush()
            simulationNum += 1
        sys.stdout.write('\b')
        return self.bestPath.pop(0)

    # decrease the concentration of pheromone accoring to learningRate
    def decayPheromone(self, ant):
        for key in pheromoneGraph.keys():
            ph = pheromoneGraph[key]
            if ph:
                # 信息素衰减公式：(1-ρ)*τ
                new_pheromone = (1 - self.rho) * ph[0]
                pheromoneGraph[key] = (new_pheromone, ph[1])

    # increase the concentration of pheromone accoring to q and path length     
    def updatePheromone(self, ant):
        path = ant.path[:]
        pathLen = len(path)
        delta_tau = self.Q / pathLen  # 计算信息素增量
        
        for i in range(1, len(path)):
            current = path[i-1]
            next = path[i]
            ph = pheromoneGraph.get((current, next))
            if ph:
                # 更新信息素，考虑路径长度的倒数
                new_pheromone = ph[0] + delta_tau
                ph = (new_pheromone, 1.0 / pathLen)
                pheromoneGraph[(current, next)] = ph
            else:
                pheromoneGraph[(current, next)] = (delta_tau, 1.0 / pathLen)

class Ant():
    def __init__(self, state, alpha, beta):
        self.state = state
        # initialization for path
        self.path = []
        self.directionPath = []
        self.stateList = []
        # 添加ACO参数
        self.alpha = alpha
        self.beta = beta
        self.gamma = 3.0    # 增加躲避幽灵的权重
        
    # move strategy for ants (based on the pheromone)
    def move(self):
        if self.isGoalState():
            return 0

        nextActions = self.state.getLegalPacmanActions()[:]
        nextActions.remove('Stop')
        
        # 初始化nextAction和nextState
        nextAction = None
        nextState = None
        
        # 获取当前位置和幽灵位置
        currentPosition = self.state.getPacmanPosition()
        ghostPositions = self.state.getGhostPositions()
        
        # 检查是否处于危险位置
        for ghostPos in ghostPositions:
            if util.manhattanDistance(currentPosition, ghostPos) <= 1:
                # 在危险情况下，优先选择远离幽灵的方向
                safeAction = self.getSafeAction(nextActions)
                if safeAction:
                    nextAction = safeAction
                    nextState = self.state.generatePacmanSuccessor(nextAction)
                break
        
        # 如果没有找到安全动作，使用基于信息素的选择
        if nextAction is None:
            nextAction, nextState = self.getNextActionPheromone(nextActions)
        
        # 如果仍然没有找到有效动作
        if nextAction is None:
            self.markClosedEntry()
            return -1
        
        self.path.append(nextState.getPacmanPosition())
        self.directionPath.append(nextAction)
        self.stateList.append(nextState)
        self.state = nextState
        
        return 1

    # check if goal achieves
    def isGoalState(self):
        return self.state.isWin()

    # in the case of that there is no nextAction
    def markClosedEntry(self):
        preState = None
        for state in self.stateList[::-1]:
            if len(state.getLegalPacmanActions()) > 3:
                if preState is not None:
                    closedEntry.append(preState.getPacmanPosition())
                break
            # update the previous state to the current state
            preState = state
            
    # get the next action for ants based pheromone
    def getNextActionPheromone(self, actions):
        nextActions = self.removeVisitedAction(actions)
        currentPosition = self.state.getPacmanPosition()
        
        if len(nextActions) == 0:
            return None, None
        
        probabilities = []
        total = 0
        
        for action in nextActions:
            nextState = self.state.generatePacmanSuccessor(action)
            nextPosition = nextState.getPacmanPosition()
            
            # 获取信息素值
            ph = pheromoneGraph.get((currentPosition, nextPosition))
            if not ph:
                ph = (0.1, 0.1)
            
            # 计算到食物的启发式信息
            food_distance = self.getDistanceToFood(nextState)
            food_heuristic = 1.0 / (food_distance + 1)  # 避免除零
            
            # 计算到幽灵的距离和启发式
            ghost_distance = self.getGhostDistance(nextState)
            ghost_heuristic = self.getGhostHeuristic(ghost_distance)
            
            # 如果下一个位置有食物，增加概率
            if nextPosition in self.state.getFood().asList():
                food_heuristic *= 2.0
            
            # 综合考虑各因素
            probability = (ph[0] ** self.alpha) * \
                         (food_heuristic ** self.beta) * \
                         (ghost_heuristic ** self.gamma)
            
            probabilities.append((probability, action, nextState))
            total += probability
        
        # 轮盘赌选择
        if total == 0:
            return self.getSafeAction(nextActions), None
            
        # 使用轮盘赌但偏向于选择高概率动作
        probabilities.sort(key=lambda x: x[0], reverse=True)
        r = random.random() * total
        current_sum = 0
        
        for prob, action, nextState in probabilities:
            current_sum += prob
            if current_sum >= r:
                return action, nextState
        
        return probabilities[0][1], probabilities[0][2]  # 返回最高概率的动作

    # decide the movement based on random paths
    def getRandom(self, actions):
        # decide the nect state
        next = random.choice(actions)
        nextState = self.state.generatePacmanSuccessor(next)
        return next, nextState

    # get the next actions for ants
    def getNextAction(self, actions):
        nextActions = self.removeVisitedAction(actions)
        if (len(nextActions) == 0):
            return None, None
        return self.getRandom(nextActions)

    # avoid repetitive actions 
    def removeVisitedAction(self, actions):
        nextActions = actions[:]
        for a in actions:
            # return the successor state for Pacman after taking the action
            nextState = self.state.generatePacmanSuccessor(a)
            if nextState.getPacmanPosition() in self.path:
                nextActions.remove(a)
        return nextActions
    
    # 添加计算到最近食物距离的辅助方法
    def getDistanceToFood(self, state):
        food = state.getFood()
        walls = state.getWalls()
        position = state.getPacmanPosition()
        
        foodList = food.asList()
        if not foodList:
            return 0
        
        # 使用曼哈顿距离
        minDistance = float("inf")
        for foodPos in foodList:
            distance = util.manhattanDistance(position, foodPos)
            if distance < minDistance:
                minDistance = distance
        
        return minDistance

    def getGhostDistance(self, state):
        """计算到最近幽灵的距离"""
        pacman_pos = state.getPacmanPosition()
        ghost_positions = state.getGhostPositions()
        
        min_distance = float('inf')
        for ghost_pos in ghost_positions:
            distance = util.manhattanDistance(pacman_pos, ghost_pos)
            min_distance = min(min_distance, distance)
        
        return min_distance

    def getGhostHeuristic(self, ghost_distance):
        """优化幽灵启发式函数"""
        if ghost_distance <= 1:    # 极度危险
            return 0.001
        elif ghost_distance <= 2:  # 非常危险
            return 0.05
        elif ghost_distance <= 3:  # 危险
            return 0.1
        elif ghost_distance <= 4:  # 警戒
            return 0.3
        elif ghost_distance <= 6:  # 注意
            return 0.7
        else:                      # 安全
            return 1.0

    def getSafeAction(self, actions):
        """改进安全动作选择策略"""
        currentPos = self.state.getPacmanPosition()
        ghostPositions = self.state.getGhostPositions()
        food = self.state.getFood()
        
        max_score = -float('inf')
        best_action = None
        
        for action in actions:
            nextState = self.state.generatePacmanSuccessor(action)
            nextPos = nextState.getPacmanPosition()
            
            # 计算到所有幽灵的最小距离
            min_ghost_distance = float('inf')
            for ghostPos in ghostPositions:
                distance = util.manhattanDistance(nextPos, ghostPos)
                min_ghost_distance = min(min_ghost_distance, distance)
            
            # 计算到最近食物的距离
            food_distance = self.getDistanceToFood(nextState)
            
            # 综合评分：考虑幽灵距离和食物距离
            safety_score = min_ghost_distance * 2.0
            food_score = 1.0 / (food_distance + 1)
            total_score = safety_score + food_score
            
            # 如果该位置有食物，增加分数
            if nextPos in food.asList():
                total_score += 2.0
                
            # 选择最高分的动作
            if total_score > max_score:
                max_score = total_score
                best_action = action
        
        return best_action

#############################################
#             Keyboard Agent:               #
#     You shouldn't need to modify this     #
#############################################

class KeyboardControllAgent(Agent):
    """
    An agent controlled by the keyboard.
    """
    # NOTE: Arrow keys also work.
    WEST_KEY  = 'a'
    EAST_KEY  = 'd'
    NORTH_KEY = 'w'
    SOUTH_KEY = 's'
    STOP_KEY = 'q'

    def __init__( self, index = 0 ):

        self.lastMove = Directions.STOP
        self.index = index
        self.keys = []

    def getAction( self, state):
        from graphicsUtils import keys_waiting
        from graphicsUtils import keys_pressed
        # print(state.getPacmanPosition())
        keys = keys_waiting() + keys_pressed()
        if keys != []:
            self.keys = keys

        legal = state.getLegalActions(self.index)
        move = self.getMove(legal)

        if move == Directions.STOP:
            # Try to move in the same direction as before
            if self.lastMove in legal:
                move = self.lastMove

        if (self.STOP_KEY in self.keys) and Directions.STOP in legal: move = Directions.STOP

        if move not in legal:
            move = random.choice(legal)

        self.lastMove = move

        return move

    def getMove(self, legal):
        move = Directions.STOP
        if   (self.WEST_KEY in self.keys or 'Left' in self.keys) and Directions.WEST in legal:  move = Directions.WEST
        if   (self.EAST_KEY in self.keys or 'Right' in self.keys) and Directions.EAST in legal: move = Directions.EAST
        if   (self.NORTH_KEY in self.keys or 'Up' in self.keys) and Directions.NORTH in legal:   move = Directions.NORTH
        if   (self.SOUTH_KEY in self.keys or 'Down' in self.keys) and Directions.SOUTH in legal: move = Directions.SOUTH
        return move
