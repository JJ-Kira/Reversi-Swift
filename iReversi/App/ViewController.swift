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
    
    private var sideMenuViewController: SideMenuViewController!
    private var sideMenuRevealWidth: CGFloat = 260
    private let paddingForRotation: CGFloat = 150
    private var isExpanded: Bool = false

    // move the side menu by changing trailing's constant
    private var sideMenuTrailingConstraint: NSLayoutConstraint!

    private var revealSideMenuOnTop: Bool = true
    
    private var interactor: ReversiInteractor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactor = ReversiInteractor()
        interactor.listener = self
        
        opponentInfoLabel.font = UIFont.monospacedDigitSystemFont(ofSize: opponentInfoLabel.font.pointSize, weight: .regular)
        
        // Side Menu
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.sideMenuViewController = storyboard.instantiateViewController(withIdentifier: "SideMenuID") as? SideMenuViewController
        self.sideMenuViewController.defaultHighlightedCell = 0 // Default Highlighted Cell
        self.sideMenuViewController.delegate = self
        view.insertSubview(self.sideMenuViewController!.view, at: self.revealSideMenuOnTop ? 2 : 0)
        addChild(self.sideMenuViewController!)
        self.sideMenuViewController!.didMove(toParent: self)

       // Side Menu AutoLayout

       self.sideMenuViewController.view.translatesAutoresizingMaskIntoConstraints = false

       if self.revealSideMenuOnTop {
           self.sideMenuTrailingConstraint = self.sideMenuViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -self.sideMenuRevealWidth - self.paddingForRotation)
           self.sideMenuTrailingConstraint.isActive = true
       }
       NSLayoutConstraint.activate([
           self.sideMenuViewController.view.widthAnchor.constraint(equalToConstant: self.sideMenuRevealWidth),
           self.sideMenuViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
           self.sideMenuViewController.view.topAnchor.constraint(equalTo: view.topAnchor)
       ])
        
        // Default Main View Controller
        showViewController(viewController: UINavigationController.self, storyboardId: "ContentID")
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
    
    // Call this Button Action from the View Contr';oller you want to Expand/Collapse when you tap a button
    @IBAction open func revealSideMenu() {
        self.sideMenuState(expanded: self.isExpanded ? false : true)
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

extension ViewController: SideMenuViewControllerDelegate {
    func selectedCell(_ row: Int) {
        switch row {
        case 0:
            // MCTS
            self.showViewController(viewController: UINavigationController.self, storyboardId: "ContentID")
        case 1:
            // ABP
            self.showViewController(viewController: UINavigationController.self, storyboardId: "MusicNavID")
        case 2:
            // Quit
            exit(0)
        default:
            break
        }

        // Collapse side menu with animation
        DispatchQueue.main.async { self.sideMenuState(expanded: false) }
    }

    func showViewController<T: UIViewController>(viewController: T.Type, storyboardId: String) -> () {
        // Remove the previous View
        for subview in view.subviews {
            if subview.tag == 99 {
                subview.removeFromSuperview()
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: storyboardId) as! T
        vc.view.tag = 99
        view.insertSubview(vc.view, at: self.revealSideMenuOnTop ? 0 : 1)
        addChild(vc)
        DispatchQueue.main.async {
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                vc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                vc.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                vc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                vc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        }
        if !self.revealSideMenuOnTop {
            if isExpanded {
                vc.view.frame.origin.x = self.sideMenuRevealWidth
            }
            if self.sideMenuShadowView != nil {
                vc.view.addSubview(self.sideMenuShadowView)
            }
        }
        vc.didMove(toParent: self)
    }

    func sideMenuState(expanded: Bool) {
        if expanded {
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? 0 : self.sideMenuRevealWidth) { _ in
                self.isExpanded = true
            }
            // Animate Shadow (Fade In)
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.6 }
        }
        else {
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? (-self.sideMenuRevealWidth - self.paddingForRotation) : 0) { _ in
                self.isExpanded = false
            }
            // Animate Shadow (Fade Out)
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.0 }
        }
    }

    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            if self.revealSideMenuOnTop {
                self.sideMenuTrailingConstraint.constant = targetPosition
                self.view.layoutIfNeeded()
            }
            else {
                self.view.subviews[1].frame.origin.x = targetPosition
            }
        }, completion: completion)
    }
}

extension UIViewController {
    
    // With this extension you can access the MainViewController from the child view controllers.
    func revealViewController() -> ViewController? {
        var viewController: UIViewController? = self
        
        if viewController != nil && viewController is ViewController {
            return viewController! as? ViewController
        }
        while (!(viewController is ViewController) && viewController?.parent != nil) {
            viewController = viewController?.parent
        }
        if viewController is ViewController {
            return viewController as? ViewController
        }
        return nil
    }
    
}
