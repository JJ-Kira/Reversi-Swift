//
//  ABPEvaluation.swift
//  iReversi
//
//  Created by Julia Szczuczko on 21.08.2024.
//

import Foundation

final class ABPEvaluation {

    // Score evaluation for the current game state
    func evaluate(gameState: ReversiGame, forPlayer playerColor: ReversiBoard.Color) -> Int {
        let board = gameState.board
        var score = 0

        let squareWeights = generateSquareWeights(boardSize: board.boardWidth)

        for x in 0..<board.boardWidth {
            for y in 0..<board.boardHeight {
                let squareColor = board.pieceAt(x: x, y: y)
                switch squareColor {
                case .color(let color) where color == playerColor:
                    score += squareWeights[x][y]
                case .color(let color) where color == playerColor.opposite():
                    score -= squareWeights[x][y]
                default:
                    break
                }
            }
        }

        return score
    }

    // Generates a weighted board similar to the C# version, prioritizing corners and edges
    private func generateSquareWeights(boardSize: Int) -> [[Int]] {
        var squareWeights = Array(repeating: Array(repeating: 0, count: boardSize), count: boardSize)

        let cornerWeight = 20
        let edgeWeight = 5
        let adjacentToCornerWeight = -5
        let centerWeight = 0

        // Set corner weights
        squareWeights[0][0] = cornerWeight
        squareWeights[0][boardSize - 1] = cornerWeight
        squareWeights[boardSize - 1][0] = cornerWeight
        squareWeights[boardSize - 1][boardSize - 1] = cornerWeight

        // Set edge weights
        for i in 1..<(boardSize - 1) {
            squareWeights[0][i] = edgeWeight  // Top edge
            squareWeights[boardSize - 1][i] = edgeWeight  // Bottom edge
            squareWeights[i][0] = edgeWeight  // Left edge
            squareWeights[i][boardSize - 1] = edgeWeight  // Right edge
        }

        // Set squares adjacent to corners
        squareWeights[0][1] = adjacentToCornerWeight
        squareWeights[1][0] = adjacentToCornerWeight
        squareWeights[0][boardSize - 2] = adjacentToCornerWeight
        squareWeights[1][boardSize - 1] = adjacentToCornerWeight
        squareWeights[boardSize - 2][0] = adjacentToCornerWeight
        squareWeights[boardSize - 1][1] = adjacentToCornerWeight
        squareWeights[boardSize - 2][boardSize - 1] = adjacentToCornerWeight
        squareWeights[boardSize - 1][boardSize - 2] = adjacentToCornerWeight

        return squareWeights
    }
}
