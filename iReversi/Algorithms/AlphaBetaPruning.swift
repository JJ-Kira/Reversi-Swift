//
//  AlphaBetaPruning.swift
//  iReversi
//
//  Created by Julia Szczuczko on 21.08.2024.
//

import Foundation

struct AlphaBetaPruning {
    
    static func bestMove(for board: ReversiBoard, depth: Int, playerColor: ReversiBoard.Color) -> (x: Int, y: Int)? {
        var bestScore = Float.leastNormalMagnitude
        var bestMove: (x: Int, y: Int)?
        
        // Iterate over all board positions to check valid moves
        board.iterateBoard { (x, y, piece) in
            if case .empty = piece {
                // Simulate the move by copying the board and flipping pieces accordingly
                var newBoard = board
                newBoard = simulateMove(on: newBoard, atX: x, y: y, for: playerColor)
                
                let score = alphaBeta(board: newBoard, depth: depth - 1, alpha: Float.leastNormalMagnitude, beta: Float.greatestFiniteMagnitude, maximizingPlayer: false, playerColor: playerColor)
                
                if score > bestScore {
                    bestScore = score
                    bestMove = (x, y)
                }
            }
        }
        
        return bestMove
    }
    
    private static func alphaBeta(board: ReversiBoard, depth: Int, alpha: Float, beta: Float, maximizingPlayer: Bool, playerColor: ReversiBoard.Color) -> Float {
        if depth == 0 || board.isFull {
            return ABPEvaluation.evaluateBoard(board, for: playerColor)
        }
        
        var alpha = alpha
        var beta = beta
        
        if maximizingPlayer {
            var maxEval = Float.leastNormalMagnitude
            board.iterateBoard { (x, y, piece) in
                if case .empty = piece {
                    var newBoard = board
                    newBoard = simulateMove(on: newBoard, atX: x, y: y, for: playerColor)
                    let eval = alphaBeta(board: newBoard, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: false, playerColor: playerColor)
                    maxEval = max(maxEval, eval)
                    alpha = max(alpha, eval)
                    if beta <= alpha {
                        return
                    }
                }
            }
            return maxEval
        } else {
            var minEval = Float.greatestFiniteMagnitude
            board.iterateBoard { (x, y, piece) in
                if case .empty = piece {
                    var newBoard = board
                    newBoard = simulateMove(on: newBoard, atX: x, y: y, for: playerColor.opposite())
                    let eval = alphaBeta(board: newBoard, depth: depth - 1, alpha: alpha, beta: beta, maximizingPlayer: true, playerColor: playerColor)
                    minEval = min(minEval, eval)
                    beta = min(beta, eval)
                    if beta <= alpha {
                        return
                    }
                }
            }
            return minEval
        }
    }
    
    private static func simulateMove(on board: ReversiBoard, atX x: Int, y: Int, for color: ReversiBoard.Color) -> ReversiBoard {
        let newBoard = board
        
        // Implement the flipping logic or move simulation by updating the board
        // This assumes you have some logic to flip the pieces based on the rules of Reversi.
        // You may need to look at adjacent pieces and determine if any flips should occur.
        
        return newBoard
    }
}

