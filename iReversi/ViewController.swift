//
//  GameViewController.swift
//  iReversi
//
//  Created by Julia Szczuczko on 21.08.2024.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var reversiView: ReversiView!
    @IBOutlet weak var whiteScoreLabel: UILabel!
    @IBOutlet weak var blackScoreLabel: UILabel!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var boardConstraint: NSLayoutConstraint!
    @IBOutlet weak var opponentInfoLabel: UILabel!
    
    private var interactor: ReversiInteractor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactor = ReversiInteractor()
        interactor.listener = self
        
        opponentInfoLabel.font = UIFont.monospacedDigitSystemFont(ofSize: opponentInfoLabel.font.pointSize, weight: .regular)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBoardMargin(view.bounds.size)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateBoardMargin(size)
    }
    
    private func updateBoardMargin(_ size: CGSize) {
        boardConstraint.constant = floor(size.width * 0.025)
    }
}

private extension ViewController {
    @IBAction func boardTapped(_ tapRecognizer: UITapGestureRecognizer) {
        let move = reversiView.moveFromPoint(tapRecognizer.location(in: reversiView))
        
        interactor.makePlayerMove(move)
    }
    
    @IBAction func toggleShowTips(_ sender: AnyObject) {
        interactor.showTips = !interactor.showTips
    }
}

extension ViewController: ReversiInteractorListener {
    func didUpdate(viewModel: ReversiViewModel) {
        reversiView.board = viewModel.board
        
        whiteScoreLabel.text = viewModel.whiteScoreText
        blackScoreLabel.text = viewModel.blackScoreText
        
        turnLabel.text = viewModel.turnText
        turnLabel.isHidden = !viewModel.isTurnTextVisible
        resultsLabel.text = viewModel.resultsText
        resultsLabel.isHidden = !viewModel.isResultsTextVisible
        
        reversiView.highlightedSquares = viewModel.highlightedSquares
        reversiView.highlightedMoves = viewModel.highlightedMoves
        
        opponentInfoLabel.text = viewModel.opponentInfo
    }
}
