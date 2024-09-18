//
//  ReversiViewModel.swift
//  iReversi
//
//  Created by Julia Szczuczko on 04/09/2024.
//

import UIKit

struct ReversiViewModel {
    let board: ReversiBoard
    let whiteScoreText: String
    let blackScoreText: String
    let turnText: String
    let isTurnTextVisible: Bool
    let resultsText: String
    let isResultsTextVisible: Bool
    let highlightedSquares: [ReversiMove]
    let highlightedMoves: [(move: ReversiMove, color: UIColor)]
    let opponentInfo: String
}
