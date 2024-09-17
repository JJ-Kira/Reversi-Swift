//
//  AlphaBetaPruning.swift
//  iReversi
//
//  Created by Julia Szczuczko on 21.08.2024.
//

import Foundation

final class AlphaBetaPruning {
    private let maxDepth: Int
    private let opponentColor: ReversiBoard.Color
    private var gamestateEvaluation: ABPEvaluation

    init(maxDepth: Int = 5, opponentColor: ReversiBoard.Color) {
        self.maxDepth = maxDepth
        self.opponentColor = opponentColor
        self.gamestateEvaluation = ABPEvaluation() // build a container node
    }


    // Entry point for the AI move, similar to bestAction() in MonteCarloTreeSearch
    func findBestMove(gameState: ReversiGame) -> ReversiMove {
        let availableMoves = gameState.allMoves(opponentColor)
        var bestMove: ReversiMove? = nil
        var bestScore = Int.min

        // Iterate through all possible moves and apply Alpha-Beta Pruning
        for move in availableMoves {
            var newState = gameState
            newState.makeMove(move, for: opponentColor)
            
            let score = alphaBeta(gameState: newState, depth: maxDepth, alpha: Int.min, beta: Int.max, maximizingPlayer: false)
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
        }

        return bestMove ?? availableMoves.randomElement()!  // Fallback to a random move if none found
    }

    // Alpha-Beta Pruning algorithm
    private func alphaBeta(gameState: ReversiGame, depth: Int, alpha: Int, beta: Int, maximizingPlayer: Bool) -> Int {
        if depth == 0 || gameState.state == .won(opponentColor) || gameState.state == .tie {
            return gamestateEvaluation.evaluate(gameState: gameState, forPlayer: opponentColor)
        }

        var alpha = alpha
        var beta = beta
        if maximizingPlayer {
            var maxEval = Int.min
            let availableMoves = gameState.allMoves(opponentColor)
            for move in availableMoves {
                var newState = gameState
                newState.makeMove(move, for: opponentColor)
                
                let eval = alphaBeta(gameState: newState, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: false)
                maxEval = max(maxEval, eval)
                alpha = max(alpha, eval)
                if beta <= alpha {
                    break
                }
            }
            return maxEval
        } else {
            var minEval = Int.max
            let availableMoves = gameState.allMoves(opponentColor.opposite())
            for move in availableMoves {
                var newState = gameState
                newState.makeMove(move, for: opponentColor.opposite())
                
                let eval = alphaBeta(gameState: newState, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: true)
                minEval = min(minEval, eval)
                beta = min(beta, eval)
                if beta <= alpha {
                    break
                }
            }
            return minEval
        }
    }
}
