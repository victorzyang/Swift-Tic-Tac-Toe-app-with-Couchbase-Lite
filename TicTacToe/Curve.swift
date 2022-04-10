//
//  Curve.swift
//  TicTacToe
//
//  Created by gliao on 2020-03-24.
//  Copyright © 2020 COMP2601. All rights reserved.
//

import Foundation
import CoreGraphics

struct Curve {
    var points: [CGPoint] = [];
    
    enum Direction {
        case UP, DOWN, LEFT, RIGHT
    }
    
    static let CLOSENESS_THRESHOLD: Float = 10.0;
    static let SLOPE_CLOSENESS_THRESHOLD: Float = 5;
    
    static func isO(_ curve: Curve) -> (Bool, String?) {
        return (true, "An O is drawn");
        
        // If a curve follows one of these general directions, then it's an O
        let expectedDirections1 = [Direction.LEFT, Direction.DOWN, Direction.RIGHT, Direction.UP, Direction.LEFT];
        let expectedDirections2 = [Direction.DOWN, Direction.RIGHT, Direction.UP, Direction.LEFT];
        
        // Go through each consecutive pair of points
        // If they all follow the expected direction then it is a circle
        var followsDirections = true;
        var currentDirectionIndex = 0;
        
        for expectedDirections in [expectedDirections1, expectedDirections2] {
            for pointIndex in stride(from: 0, to: curve.points.count-1, by: 1) {
                let point1 = curve.points[pointIndex];
                let point2 = curve.points[pointIndex+1];
                
                let direction = getGeneralDirection(between: point1, and: point2);
                print(direction);
                
                // Still on current direction
                if (direction == expectedDirections[currentDirectionIndex]) {
                    continue;
                }
                // Move onto next direction
                else if (currentDirectionIndex+1 != expectedDirections.count &&
                    direction == expectedDirections[currentDirectionIndex+1]) {
                    
                    currentDirectionIndex += 1;
                    continue;
                }
                else {
                    followsDirections = false;
                    break;
                }
            }
            
            // If directions have been followed to the last step, it's an O
            if followsDirections && currentDirectionIndex == expectedDirections.count - 1 {
                return (true, nil);
            }
            else {  // Else reset followsDirections and index for next set of expectedDirections
                followsDirections = true;
                currentDirectionIndex = 0;
            }
        }

        print("------");
        
        return (false, "What type of O was that?! Please redraw.");
    }
    
    static func getGeneralDirection(between first: CGPoint, and second: CGPoint) -> Direction {
        // Note: x and y are measured from top left
        
        let xDist = second.x - first.x;
        let yDist = second.y - first.y;
        
        let horizontalDirection = xDist >= 0 ? Direction.RIGHT : Direction.LEFT;
        let verticalDirection = yDist >= 0 ? Direction.DOWN : Direction.UP;
        
        if (abs(xDist) >= abs(yDist)) {
            return horizontalDirection;
        }
        else {
            return verticalDirection;
        }
    }
    
    
    static func isX(curve1: Curve, curve2: Curve) -> (Bool, String?) {
        
        for curve in [curve1, curve2] {
            // Check if lines are long enough
            if curve.points.count < 5 {
                return (false, "Bad X: line(s) aren't long enough. Please redraw.");
            }
            
            let firstPoint = curve.points.first!;
            let lastPoint = curve.points.last!;
            if (Math.distance(from: firstPoint, to: lastPoint) < 50) {
                return (false, "Bad X: line(s) aren't long enough. Please redraw.");
            }
            
            // Check if each line is kind of straight
            //     by checking the standard deviation of slopes between every pair of points
            if (!isStraight(curve: curve)) {
                return (false, "Bad X: line(s) aren't straight enough. Please redraw.");
            }
        }
        
        // Check if lines are around the same size
        let line1Length = Math.distance(from: curve1.points.first!, to: curve1.points.last!);
        let line2Length = Math.distance(from: curve2.points.first!, to: curve2.points.last!);
        if abs(line1Length - line2Length) > 50 {
            return (false, "Bad X: lines aren't the same length. Please redraw.");
        }
        
        // Check if lines intersect:
        //   - Either the lines created by the two endpoints intersect, or
        //   - one of their points are close enough
        var intersects = Curve.intersects(curve1: curve1, curve2: curve2);
        
        outerloop: for point1 in curve1.points {
            for point2 in curve2.points {
                if (Math.distance(from: point1, to: point2) < CLOSENESS_THRESHOLD) {
                    intersects = true;
                    break outerloop;
                }
            }
        }
        
        if (!intersects) {
            return (false, "Bad X: doesn't intersect. Please redraw.");
        }

        // Passed all checks
        return (true, nil);
    }
    
    static func isStraight(curve: Curve) -> Bool {
        var slopes: [Float] = [];
        
        // Compare pairs such that the second point is always at least 3 indexes after
        //     the first point
        for point1 in 0..<curve.points.count-2 {
            for point2 in stride(from: point1 + 3, to: curve.points.count, by: 1) {
                slopes.append(Math.slope(between: curve.points[point1], and: curve.points[point2]));
            }
        }
        
        // Empirically, zeroes ruin the standard deviation so I filter it out
        slopes = slopes.filter { $0 != 0 };
        
        let stdDev = Math.standardDeviation(of: slopes);
        
        return stdDev < 2.0;
    }
    
    
    // Algorithm adapted from stackoverflow
    static func intersects(curve1: Curve, curve2: Curve) -> Bool {
        // Assume each curve is somewhat straight and has at least 2 points
        
        let c1Start = curve1.points.first!;
        let c1End = curve1.points.last!;
        let c2Start = curve2.points.first!;
        let c2End = curve2.points.last!;
        
        let determinant = (c1End.x - c1Start.x) * (c2End.y - c2Start.y) - (c2End.x - c2Start.x) * (c1End.y - c1Start.y);
        
        if determinant == 0 {
            return false;
        }
        else {
            let lambda = ((c2End.y - c2Start.y) * (c2End.x - c1Start.x) + (c2Start.x - c2End.x) * (c2End.y - c1Start.y)) / determinant;
            let gamma = ((c1Start.y - c1End.y) * (c2End.x - c1Start.x) + (c1End.x - c1Start.x) * (c2End.y - c1Start.y)) / determinant;
            return lambda > 0 && lambda < 1 && gamma > 0 && gamma < 1;
        }
    }
    
    static func getCenter(of curves: Curve...) -> CGPoint {
        var xSum: CGFloat = 0;
        var ySum: CGFloat = 0;
        var numPoints: CGFloat = 0;
        
        for curve in curves {
            for point in curve.points {
                xSum += point.x;
                ySum += point.y;
                numPoints += 1;
            }
        }
        
        return CGPoint(x: xSum / numPoints, y: ySum / numPoints);
    }
    
}
