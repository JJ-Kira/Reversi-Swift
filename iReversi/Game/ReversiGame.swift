//
//  ReversiGame.swift
//  iReversi
//
//  Created by Julia Szczuczko on 21.08.2024.
//

import Foundation

struct ReversiGame: Equatable {
    enum State {
        case turn(ReversiBoard.Color)
        case won(ReversiBoard.Color)
        case tie
    }
    
    private(set) var board: ReversiBoard
    private(set) var state: State
    
    init () {
        board = ReversiBoard()
        board[3, 3] = ReversiBoard.Piece.color(ReversiBoard.Color.white)
        board[4, 4] = ReversiBoard.Piece.color(ReversiBoard.Color.white)
        board[3, 4] = ReversiBoard.Piece.color(ReversiBoard.Color.black)
        board[4, 3] = ReversiBoard.Piece.color(ReversiBoard.Color.black)
        
        state = .turn(ReversiBoard.Color.white)
    }
    
    func allMoves(_ color: ReversiBoard.Color) -> [ReversiMove] {
        var moves: Array<ReversiMove> = []
        moves.reserveCapacity(32)
        
        for x in 0..<board.boardWidth {
            for y in 0..<board.boardHeight {
                let move = ReversiMove(x: x, y: y)
                if isValidMove(move, for:color) {
                    moves.append(move)
                }
            }
        }
        
        return moves
    }
    
    func currentColor() -> ReversiBoard.Color? {
        if case .turn(let currentPlayerColor) = state {
            return currentPlayerColor
        } else {
            return nil
        }
    }
    
    func hasMoves(for color: ReversiBoard.Color) -> Bool {
        for x in 0..<board.boardWidth {
            for y in 0..<board.boardHeight {
                let move = ReversiMove(x: x, y: y)
                if isValidMove(move, for: color) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func isTurnOf(_ color: ReversiBoard.Color) -> Bool {
        if case .turn(let currentPlayerColor) = state , currentPlayerColor == color {
            return true
        } else {
            return false
        }
    }
    
    func isValidMove(_ move: ReversiMove, for color: ReversiBoard.Color) -> Bool {
        return processLinesForMove(move, for: color, lineProcessor: nil)
    }
    
    mutating func makeMove(_ move: ReversiMove, for color: ReversiBoard.Color) {
        self = ReversiGame.makeMove(startingState: self, move: move, forColor: color)
    }
    
    static let xDirs = [ -1, -1, -1,  0,  1,  1,  1,  0 ]
    static let yDirs = [ -1,  0,  1,  1,  1,  0, -1, -1 ]
    
    func processLinesForMove(_ move: ReversiMove, for color: ReversiBoard.Color, lineProcessor: ((_ endX: Int, _ endY: Int, _ dx: Int, _ dy: Int) -> Void)?) -> Bool {
        if !board.isValidCoordinate(x: move.x, y: move.y) {
            return false
        }
        
        if !board.isEmptyAt(x: move.x, y: move.y) {
            return false
        }
        
        let opposite = color.opposite()
        
        var moveIsValid = false
        for dir in 0..<ReversiGame.xDirs.count {
            var tempX = move.x
            var tempY = move.y
            
            var hasFoundOpposite = false
            
            directionSearch: while true {
                tempX += ReversiGame.xDirs[dir]
                tempY += ReversiGame.yDirs[dir]
                
                if !board.isValidCoordinate(x: tempX, y: tempY) {
                    break
                }
                
                let piece = board.pieceAt(x: tempX, y: tempY)
                
                switch piece {
                    case .color(let pieceColor):
                        if pieceColor == color {
                            if hasFoundOpposite {
                                if lineProcessor != nil {
                                    moveIsValid = true
                                    lineProcessor!(tempX, tempY, ReversiGame.xDirs[dir], ReversiGame.yDirs[dir])
                                } else {
                                    return true
                                }
                            }
                            break directionSearch
                        } else if pieceColor == opposite {
                            hasFoundOpposite = true
                        }
                    case .empty:
                        break directionSearch
                }
            }
        }
        
        return moveIsValid
    }
}

extension ReversiGame {
    static func makeMove(startingState: ReversiGame, move: ReversiMove, forColor color: ReversiBoard.Color) -> ReversiGame {
        if !startingState.isTurnOf(color) {
            return startingState
        }
        
        var newState = startingState
        
        _ = newState.processLinesForMove(move, for: color) { (endX, endY, dx, dy) in
            var curX = endX
            var curY = endY
            while !(curX == move.x && curY == move.y) {
                curX -= dx
                curY -= dy
                
                newState.board[curX, curY] = .color(color)
            }
        }
        
        let boardFull = newState.board.isFull
        
        if boardFull == false && newState.hasMoves(for: color.opposite()) {
            // Pass turn to the other player
            newState.state = .turn(color.opposite())
        } else if boardFull == false && newState.hasMoves(for: color) {
            // Same player continues, because the other player doens't have moves
        } else {
            // Game has ended
            if newState.board.numberOfWhitePieces() > newState.board.numberOfBlackPieces() {
                newState.state = .won(.white)
            } else if newState.board.numberOfWhitePieces() < newState.board.numberOfBlackPieces() {
                newState.state = .won(.black)
            } else {
                newState.state = .tie
            }
        }
        
        return newState
    }
}

extension ReversiGame.State: Equatable {}

func ==(lhs: ReversiGame.State, rhs: ReversiGame.State) -> Bool {
    switch (lhs, rhs) {
        case (.turn(let lColor), .turn(let rColor)) where lColor == rColor:
            return true
        case (.won(let lColor), .won(let rColor)) where lColor == rColor:
            return true
        case (.tie, .tie):
            return true
        default:
            return false
    }
}

extension ReversiGame : Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(board)
    }
}
