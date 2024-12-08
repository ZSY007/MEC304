# -*- coding: cp936 -*-
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
        # parameters for the ACO algorithm
        self.alpha = 1
        self.beta = 2
        self.learningRate = 0.9
        self.q = 100

        # define the number of ants and simulations
        self.bestPath = []
        self.numAnt = 20
        self.numSim = 200
        self.NumTotal = self.numAnt * self.numSim
        
    # move instructions for Pacman
    def getAction(self, state):
        if self.bestPath != []:
            return self.bestPath.pop(0)
        simulationNum = 0
        # keep simulating until a best path is found or the max number of simulation is reached
        while simulationNum < self.NumTotal or self.bestPath == []:
            # create ant in Class Ant
            ant = Ant(state)
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
    def decayPheromone(self,a):
        path = a.path[:]
        pathLen = len(path)
        for i in range(1, len(path)):
            ph = pheromoneGraph.get((path[i-1], path[i]))
            if ph:
                ph[0]=(1-self.learningRate)*ph[0]
                ph[1]=(1-self.learningRate)*ph[1]
            else:
                pass

    # increase the concentration of pheromone accoring to q and path length     
    def updatePheromone(self, a):
        path = a.path[:]
        pathLen = len(path)
        for i in range(1, len(path)):
            ph = pheromoneGraph.get((path[i-1], path[i]))
            if ph:
                ph[0] = ph[0] + self.q / 1
                ph[1] = 1 / pathLen
            else:
                ph = (self.q / 1, 1 / pathLen)
        

class Ant():
    def __init__(self, state):
        self.state = state
        # initialization for path
        self.path = []
        self.directionPath = []
        self.stateList = []
        
    # move strategy for ants (based on the pheromone)
    def move(self):
        if self.isGoalState():
            return 0

        # select actions but not stop
        nextActions = self.state.getLegalPacmanActions()[:]
        nextActions.remove('Stop')

        # select next action
        # getNextActionPheromone = pheromone based
        nextAction, nextState = self.getNextActionPheromone(nextActions)
        
        # finish the movement if there is no instruction for next action
        if nextAction is None:
            # update the previous state to the current state for next iteration 
            self.markClosedEntry()
            return -1

        # get the current position of ant and ghost position
        currentPosition = self.state.getPacmanPosition()
        ghostPosition = self.state.getGhostPositions()
        # if they are equal (ant encounters the ghost), then inverse the action to go back to the previous position
        if currentPosition == ghostPosition:
            if nextAction == 'North':
                nextAction = 'South'
                nextState = self.getNextActionPheromone(nextAction)
            elif nextAction == 'South':
                nextAction = 'North'
                nextState = self.getNextActionPheromone(nextAction)
            elif nextAction == 'East':
                nextAction = 'West'
                nextState = self.getNextActionPheromone(nextAction)
            else:
                nextAction = 'East'
                nextState = self.getNextActionPheromone(nextAction)
                
        # add the path
        self.path.append(nextState.getPacmanPosition())
        self.directionPath.append(nextAction)
        # update the state
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
        # position is a tuple with format (x, y)
        currentPosition = self.state.getPacmanPosition()
        score = []
        sumPh = 0
        phScore = 0

        if (len(nextActions) == 0):
            return None, None

        # set pheromone and score that based on pheromone
        for i in range(len(nextActions)):
            nextState = self.state.generatePacmanSuccessor(nextActions[i])
            nextPosition = nextState.getPacmanPosition()
            ghostPosition = self.state.getGhostPositions()
            
            # get pheromone from pheromoneGraph
            ph = pheromoneGraph.get((currentPosition, nextPosition))
            # if ph has no value, then initialize it to (0,0)
            if not ph:
                ph = (0, 0)
            # if ant meets the ghost, then keep the phScore as the current pheromone
            elif currentPosition == ghostPosition:
                phScore = ph[0]
            # else increase the phScore by use the multplication
            else:
                phScore = ph[0] * ph[1]

            # update the whole pheromone and score
            score.append((phScore, nextActions[i], nextState))
            sumPh += phScore

        # if there is no pheromone, ants will choose a path randomly
        if sumPh == 0:
            return self.getRandom(nextActions)
 
        score.sort(key=lambda tup: tup[0], reverse=True)

        # set score for random paths
        for i in range(len(score)):
            if random.random() <= score[i][0] / sumPh:
                return score[i][1], score[i][2]

        return self.getRandom(nextActions)

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
