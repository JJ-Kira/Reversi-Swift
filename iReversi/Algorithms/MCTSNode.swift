//
//  MCTSNode.swift
//  iReversi
//
//  Created by Julia Szczuczko on 21.08.2024.
//

import Foundation

final class MCTSNode {
    let gameState: ReversiGame
    weak var parent: MCTSNode?
    var children: [MCTSNode]
    var wins: Int
    var plays: Int
    var move: ReversiMove
    var allMovesExpanded: Bool
    
    convenience init(gameState: ReversiGame) {
        self.init(gameState: gameState, move: ReversiMove(x: -1, y: -1))
    }
    
    init(gameState: ReversiGame, move: ReversiMove) {
        self.gameState = gameState
        self.move = move
        self.children = []
        self.wins = 0
        self.plays = 0
        self.allMovesExpanded = false
    }
    
    func hasVisitedMove(_ move: ReversiMove) -> Bool {
        children.first { $0.move == move } != nil
    }
    
    func addChild(_ child: MCTSNode) {
        child.parent = self
        children.append(child)
    }
    
    func hasUnsimulatedPlays() -> Bool {
        if case .tie = gameState.state {
            return false
        }
        if case .won(_) = gameState.state {
            return false
        }
        
        if allMovesExpanded == false {
            return true
        }
        
        if children.count == 0 {
            return true
        }
        
        for child in children {
            if child.hasUnsimulatedPlays() {
                return true
            }
        }
        
        return false
    }
}

extension MCTSNode : Equatable {}

func ==(lhs: MCTSNode, rhs: MCTSNode) -> Bool {
    return lhs.gameState == rhs.gameState //&& lhs.move == rhs.move
}

extension MCTSNode : Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(gameState)
    }
}
