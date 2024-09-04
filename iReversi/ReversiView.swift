//
//  ReversiView.swift
//  iReversi
//
//  Created by Julia Szczuczko on 04/09/2024.
//

import UIKit

class ReversiView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var board: ReversiBoard? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var highlightedSquares: [ReversiMove] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
        
    var highlightedMoves: [(move: ReversiMove, color: UIColor)] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func moveFromPoint(_ point: CGPoint) -> ReversiMove {
        guard let board = board else {
            return ReversiMove(x: -1, y: -1)
        }
        
        let frameRect = bounds
        let blockWidth: Int = Int(frameRect.size.width - 1) / board.boardWidth
        let blockHeight: Int = Int(frameRect.size.height - 1) / board.boardHeight
        
        var x = Int(point.x) / blockWidth
        var y = Int(point.y) / blockHeight
        
        if x < 0 {
            x = 0
        }
        if x > board.boardWidth - 1 {
            x = board.boardWidth - 1
        }
        if y < 0 {
            y = 0
        }
        if y > board.boardHeight - 1 {
            y = board.boardHeight - 1
        }
        
        return ReversiMove(x: x, y: y)
    }
}

// UIView overrides
extension ReversiView {
    override func draw(_ rect: CGRect) {
        guard let board = board else {
            return
        }
        
        let frameRect = bounds
        
        let blockWidth: Int = Int(frameRect.size.width - 1) / board.boardWidth;
        let blockHeight: Int = Int(frameRect.size.height - 1) / board.boardHeight;
        
        UIColor.white.set()
        UIRectFill(frameRect)
        
        UIColor.black.set()
        
        let blockRectCalculator = { (x: Int, y: Int) -> CGRect in
            let blockRect = CGRect(x: x * blockWidth,
                                   y: y * blockHeight,
                                   width: blockWidth + 1,
                                   height: blockHeight + 1)
            return blockRect
        }
        
        board.iterateBoard { (x, y, piece) in
            let blockRect = blockRectCalculator(x, y)
            
            UIRectFrame(blockRect)
            
            let path = UIBezierPath(ovalIn: blockRect.insetBy(dx: 2, dy: 2))
            
            switch piece {
                case .color(let color):
                    switch color {
                        case .white:
                            path.stroke()
                            break
                        case .black:
                            path.fill()
                            break
                    }
                    break;
                case .empty:
                    break;
            }
            
            if highlightedSquares.contains(ReversiMove(x: x, y: y)) {
                UIColor.blue.set()
                UIRectFrame(blockRect.insetBy(dx: 1, dy: 1))
                UIColor.black.set()
            }
        }
        
        for highlightedMove in highlightedMoves {
            highlightedMove.color.set()
            let blockRect = blockRectCalculator(highlightedMove.move.x, highlightedMove.move.y)
            let path = UIBezierPath(ovalIn: blockRect.insetBy(dx: 3, dy: 3))
            path.fill()
        }
    }
}
