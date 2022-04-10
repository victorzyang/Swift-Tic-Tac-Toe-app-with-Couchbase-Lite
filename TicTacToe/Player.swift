//
//  Player.swift
//  TicTacToe
//
//  Created by gliao on 2020-03-24.
//  Copyright © 2020 COMP2601. All rights reserved.
//

import Foundation

enum Player: Character {
    case X = "X"
    case O = "O"
    case EMPTY = " "
    
    func get() -> String {
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
