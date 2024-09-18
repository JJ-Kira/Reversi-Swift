//
//  ABPEvaluation.swift
//  iReversi
//
//  Created by Julia Szczuczko on 21.08.2024.
//

import Foundation

struct ABPEvaluation {
    
    static func evaluateBoard(_ board: ReversiBoard, for playerColor: ReversiBoard.Color) -> Float {
        var score: Float = 0
        
        // Heuristic: Disc Difference
        score += discDifference(board, for: playerColor)
        
        // Heuristic: Mobility
        score += mobility(board, for: playerColor)
        
        // Heuristic: Corner Control
        score += cornerControl(board, for: playerColor)
        
        return score
    }
    
    private static func discDifference(_ board: ReversiBoard, for playerColor: ReversiBoard.Color) -> Float {
        let playerDiscs = playerColor == .white ? board.numberOfWhitePieces() : board.numberOfBlackPieces()
        let opponentDiscs = playerColor == .white ? board.numberOfBlackPieces() : board.numberOfWhitePieces()
        return Float(playerDiscs - opponentDiscs) / 64.0
    }
    
    private static func mobility(_ board: ReversiBoard, for playerColor: ReversiBoard.Color) -> Float {
        // Mobility heuristic implementation would go here
        // For now, we'll assume a neutral score
        return 0
    }
    
    private static func cornerControl(_ board: ReversiBoard, for playerColor: ReversiBoard.Color) -> Float {
        let corners = [
            (0, 0), (0, board.boardWidth - 1),
            (board.boardHeight - 1, 0), (board.boardHeight - 1, board.boardWidth - 1)
        ]
        
        var playerCorners = 0
        var opponentCorners = 0
        
        for (x, y) in corners {
            switch board.pieceAt(x: x, y: y) {
            case .color(playerColor):
                playerCorners += 1
            case .color(let opponent) where opponent == playerColor.opposite():
                opponentCorners += 1
            default:
                break
            }
        }
        
        return Float(playerCorners - opponentCorners) / 4.0
    }
}
