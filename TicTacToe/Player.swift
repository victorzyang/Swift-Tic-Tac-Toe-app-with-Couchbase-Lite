//
//  Player.swift
//  TicTacToe
//
//  Created by Victor Yang
//  Copyright © 2020 COMP2601. All rights reserved.
//

import Foundation

enum Player: Character {
    case X = "X"
    case O = "O"
    case EMPTY = " "
    
    func get() -> String { //Added for thesis. Used for determining what character is played on a space in the game board
        switch self {
        case .X:
            return "X"
        case .O:
            return "O"
        case .EMPTY:
            return " "
        }
    }
}
