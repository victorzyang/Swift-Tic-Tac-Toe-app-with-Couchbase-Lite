//
//  TicTacToe.swift
//  TicTacToe
//
//  Created by gliao on 2020-03-24.
//  Copyright © 2020 COMP2601. All rights reserved.
//

import Foundation
import CoreGraphics

class TicTacToe: CustomStringConvertible {
    
    // Constants
    let NUM_ROWS = 3;
    let NUM_COLS = 3;
    
    // Instance variables
    private var board: [[Player]];
    
    // Constructor
    init() {
        board = Array(repeating: Array(repeating: Player.EMPTY, count: 3), count: 3);
    }
    
    func getBoard() -> [[Player]] { //added for thesis
        return board;
    }
    
    func getWinner() -> Player? {
        for row in 0..<NUM_ROWS {
            if board[row][0] == board[row][1] && board[row][1] == board[row][2] && board[row][0] != Player.EMPTY {
                return board[row][0];
            }
        }
        
        for col in 0..<NUM_COLS {
            if board[0][col] == board[1][col] && board[1][col] == board[2][col] && board[0][col] != Player.EMPTY {
                return board[0][col];
            }
        }
        
        if board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0] != Player.EMPTY{
            return board[0][0];
        }
        if board[2][0] == board[1][1] && board[1][1] == board[0][2] && board[2][0] != Player.EMPTY{
            return board[2][0];
        }
        
        return nil;
    }
    
    func isFull() -> Bool {
        for row in 0..<NUM_ROWS {
            for col in 0..<NUM_COLS {
                if board[row][col] == Player.EMPTY {
                    return false;
                }
            }
        }
        return true;
    }
    
    // toString()
    var description: String {
        var toReturn = "";
        
        for row in 0..<NUM_ROWS {
            for col in 0..<NUM_COLS {
                toReturn += String(board[row][col].rawValue);
                toReturn += "|";
            }
            toReturn.remove(at: toReturn.index(before: toReturn.endIndex));
            toReturn += "\n"
        }
        
        return toReturn;
    }
    
    // Setter
    func play(player: Player, row: Int, col: Int) {
        board[row][col] = player;
        print(self);
    }
    
}
