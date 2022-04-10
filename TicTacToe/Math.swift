//
//  Math.swift
//  TicTacToe
//
//  Created by gliao on 2020-03-25.
//  Copyright © 2020 COMP2601. All rights reserved.
//

import Foundation
import CoreGraphics

struct Math {
    static func distance(from point1: CGPoint, to point2: CGPoint) -> Float {
        let xDist = point2.x - point1.x;
        let yDist = point2.y - point1.y;
        
        return Float(sqrt(pow(xDist, 2) + pow(yDist, 2)));
    }
    
    // This might not be the actual slope due to reversed coordinates, but it
    // doesn't matter since I'm only comparing differences of slopes
    static func slope(between point1: CGPoint, and point2: CGPoint) -> Float {
        let xDist = point2.x - point1.x;
        let yDist = point2.y - point1.y;
        
        if (xDist == 0 || yDist == 0) {
            return 0;
        }
        
        return Float(yDist / xDist);
    }
    
    static func standardDeviation(of array: [Float]) -> Float {
        let mean = Math.mean(of: array);  // Not the most efficient but whatever
        
        var sum: Float = 0;
        for value in array {
            sum += pow((value - mean), 2);
        }
        
        return sqrt(sum / Float(array.count));
    }
    
    static func mean(of array: [Float]) -> Float {
        var sum: Float = 0;
        for value in array {
            sum += value;
        }
        
        return sum / Float(array.count);
    }
    
}
