//
//  ReversiInteractor.swift
//  iReversi
//
//  Created by Julia on 04/09/2024.
//

import UIKit

protocol ReversiInteractorListener: AnyObject {
    func didUpdate(viewModel: ReversiViewModel)
}

class ReversiInteractor {
    private var game: ReversiGame!
    private let playerColor = ReversiBoard.Color.white
    private let opponentColor = ReversiBoard.Color.black
    private var mctsSearch: MonteCarloTreeSearch!
    private var activeOpponentInfo: String = ""
    private var highlightedMoves: [(move: ReversiMove, color: UIColor)] = []
    
    init() {
        game = ReversiGame()
    }
    
    var showTips: Bool = false { didSet {
        notifyViewModelDidChange()
        }
    }
    
    var listener: ReversiInteractorListener? {
        didSet {
            notifyViewModelDidChange()
        }
    }
    
    func makePlayerMove(_ move: ReversiMove) {
        guard case .turn(let color) = game.state , color == playerColor else {
            return
        }
        
        if game.isValidMove(move, for: color) {
            game.makeMove(move, for: color)
            notifyViewModelDidChange()
            
            checkAIOpponent()
        }
    }
}

private extension ReversiInteractor {
    private func checkAIOpponent() {
        if case .turn(let color) = game.state , color == opponentColor {
            let currentGameState = game
            
            if mctsSearch == nil {
                mctsSearch = MonteCarloTreeSearch(startingGameState: currentGameState!, opponentColor: opponentColor)
            }
            
            let aiThinkTime: TimeInterval = 2
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                self.runAIOpponentTurn(timeLimit: aiThinkTime, fromGameState: currentGameState!)
            }
        }
    }
    
    private func runAIOpponentTurn(timeLimit: TimeInterval, fromGameState currentGameState: ReversiGame) {
        print("Starting Monte Carlo Tree Search")
        
        mctsSearch.updateStartingState(currentGameState) // Use this to reuse already computed nodes
        //mctsSearch = MonteCarloTreeSearch(startingGameState: currentGameState, aiColor: aiColor) // Use this to start with a clean sheet.
        
        // Loop until allotted timeLimit is reached,
        // eport updates to ui frequently so the user doesn't have to start an static screen
        let uiUpdateInterval = 0.1
        let start = Date.timeIntervalSinceReferenceDate
        var lastUpdateTime = start
        while Date.timeIntervalSinceReferenceDate - start < timeLimit {
            if mctsSearch.hasUnsimulatedPlays() == false {
                break
            }
            
            mctsSearch.iterateSearch()
            
            let now = Date.timeIntervalSinceReferenceDate
            if now - lastUpdateTime > uiUpdateInterval {
                lastUpdateTime = now
                let tempSearchResults = mctsSearch.results()
                
                DispatchQueue.main.async {
                    self.updateAIOpponentWithInterimSearchResults(tempSearchResults)
                }
            }
        }
        let end = Date.timeIntervalSinceReferenceDate
        
        let searchResults = mctsSearch.results()
        
        printResults(searchResults)
        
        let bestMove = searchResults.bestMove
        print("    Simulated \(searchResults.simulations) games, conf: \(Int(searchResults.confidence * 100))%")
        print("    Chose move \(bestMove)")
        
        DispatchQueue.main.async {
            self.makeAIOpponentMove(bestMove, searchResults: searchResults, duration: end - start)
        }
    }
    
    private func updateAIOpponentWithInterimSearchResults(_ searchResults: (bestMove: ReversiMove, simulations: Int, confidence: Double, moves: [MCTSNode])) {
        activeOpponentInfo = "Simulated \(searchResults.simulations) games"
        
        highlightedMoves = searchResults.moves.map { moveNode in
            let winrate = CGFloat(moveNode.wins) / CGFloat(moveNode.plays)
            return (move: moveNode.move, color: UIColor(white: 0.2, alpha: winrate))
        }
        
        notifyViewModelDidChange()
    }
    
    private func makeAIOpponentMove(_ move: ReversiMove, searchResults: (bestMove: ReversiMove, simulations: Int, confidence: Double, moves: [MCTSNode]), duration: TimeInterval) {
        game.makeMove(move, for: opponentColor)
        
        highlightedMoves = []
        
        activeOpponentInfo = """
Simulated \(searchResults.simulations) games in \(Int(duration)) s, conf: \(Int(searchResults.confidence * 100))%
\(Int(Double(searchResults.simulations) / duration)) Games per second
"""
        
        notifyViewModelDidChange()
        
        checkAIOpponent()
    }
    
    private func printResults(_ searchResults: (bestMove: ReversiMove, simulations: Int, confidence: Double, moves: [MCTSNode])) {
        for moveNove in searchResults.moves.sorted(by: { (left: MCTSNode, right: MCTSNode) -> Bool in
            return Double(left.wins) / Double(left.plays) > Double(right.wins) / Double(right.plays)
        }) {
            if moveNove.plays > 0 {
                let winrate = Double(moveNove.wins) / Double(moveNove.plays)
                print("    Move \(moveNove.move): win confidence: \(Int(winrate * 100))%, \(moveNove.plays) plays")
            }
        }
    }
    
    static private func viewModel(for game: ReversiGame,
                                  showTips: Bool,
                                  opponentInfo: String,
                                  highlightedMoves: [(move: ReversiMove, color: UIColor)]) -> ReversiViewModel {
        let board = game.board
        
        let whiteScoreText = "White: \(game.board.numberOfWhitePieces())"
        let blackScoreText = "Black: \(game.board.numberOfBlackPieces())"
        
        let turnText: String
        let isTurnTextVisible: Bool
        let resultsText: String
        let isResultsTextVisible: Bool
        let highlightedSquares: [ReversiMove]
        
        switch game.state {
            case .turn(let color):
                turnText = "\(color) turn"
                isTurnTextVisible = true
                resultsText = ""
                isResultsTextVisible = false
                if showTips {
                    highlightedSquares = game.allMoves(color)
                } else {
                    highlightedSquares = []
                }
            case .tie:
                turnText = ""
                isTurnTextVisible = false
                isResultsTextVisible = true
                resultsText = "Game over: tied"
                highlightedSquares = []
            case .won(let color):
                turnText = ""
                isTurnTextVisible = false
                isResultsTextVisible = true
                resultsText = "\(color) won!"
                highlightedSquares = []
        }
        
        return ReversiViewModel(board: board,
                                whiteScoreText: whiteScoreText,
                                blackScoreText: blackScoreText,
                                turnText: turnText,
                                isTurnTextVisible: isTurnTextVisible,
                                resultsText: resultsText,
                                isResultsTextVisible: isResultsTextVisible,
                                highlightedSquares: highlightedSquares,
                                highlightedMoves: highlightedMoves,
                                opponentInfo: opponentInfo)
    }
}

private extension ReversiInteractor {
    func notifyViewModelDidChange() {
        guard let listener = listener else { return }
        
        let viewModel = ReversiInteractor.viewModel(for: game,
                                                    showTips: showTips,
                                                    opponentInfo: activeOpponentInfo,
                                                    highlightedMoves: highlightedMoves)
        
        listener.didUpdate(viewModel: viewModel)
    }
}
