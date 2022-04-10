//
//  Line.swift
//  TicTacToe
//
//  Created by gliao on 2020-03-24.
//  Copyright © 2020 COMP2601. All rights reserved.
//

import Foundation

import CoreGraphics

struct Line {
    var begin = CGPoint.zero;
    var end = CGPoint.zero;
    
    let MIN_LENGTH = 100;
    let MAX_SLOPPINESS = 25;
    
    func isHorizontal() -> (Bool, Float?) {
        let horizontalLength = abs(begin.x - end.x);
        let verticalLength = abs(begin.y - end.y);
        
        let isHorizontal = Int(horizontalLength) >= MIN_LENGTH && Int(verticalLength) <= MAX_SLOPPINESS;
        
        if (!isHorizontal) {
            return (false, nil);
        }
        
        let lineYCoordinate = Float(begin.y + end.y) / 2.0;
        return (true, lineYCoordinate);
    }
    
    func isVertical() -> (Bool, Float?) {
        let horizontalLength = abs(begin.x - end.x);
        let verticalLength = abs(begin.y - end.y);
        
        let isVertical = Int(verticalLength) >= MIN_LENGTH && Int(horizontalLength) <= MAX_SLOPPINESS;
        
        if (!isVertical) {
            return (false, nil);
        }
        
        let lineXCoordinate = Float(begin.x + end.x) / 2.0;
        return (true, lineXCoordinate);
    }
}
