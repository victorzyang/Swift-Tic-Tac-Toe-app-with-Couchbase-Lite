//
//  DrawView.swift
//  TicTacToe
//
//  Created by Victor Yang
//  Copyright © 2020 COMP2601. All rights reserved.
//

import Foundation
import UIKit
import CouchbaseLiteSwift //this resolved the 'Use of Unresolved Identifier' error which I was getting from the MutableDocument()

extension UIView { //needed for calling UIViewController (ie. ViewController.swift) from UIView
    var parentViewController: UIViewController? {
        // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}

class DrawView: UIView {
    // Constants
    @IBInspectable var finishedLineColor: UIColor = UIColor.black {
        didSet { setNeedsDisplay(); }
    }
    @IBInspectable var currentLineColor: UIColor = UIColor.red {
        didSet { setNeedsDisplay(); }
    }
    @IBInspectable var selectedLineColor: UIColor = UIColor.yellow {
        didSet { setNeedsDisplay(); }
    }
    @IBInspectable var lineThickness: CGFloat = 10 {
        didSet { setNeedsDisplay(); }
    }
    
    let MIN_GRID_DISTANCE: Float = 100;
    
    // Status of game
    enum Status {
        case X_TURN, O_TURN, GRID_SETUP
    }
    // let MAX_TOUCHES = [Status.X_TURN: 2, Status.O_TURN: 1, Status.GRID_SETUP: 4];
    var status = Status.GRID_SETUP;
    var errorMessage: String?;
    
    // Board
    var board: TicTacToe?;
    var gridX: [Float]?;
    var gridY: [Float]?;
    
    // User drawings
    var currentCurves = [UITouch: Curve]();
    var currentLines = [UITouch: Line]();
    
    var finishedCurves = [Curve]();
    var finishedLines = [Line]();
    
    
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder);
        print("Game is ready");
    }
    
    // Methods for detecting touch
//    required init?(coder aDecoder: NSCoder){
//        super.init(coder: aDecoder);
//
//        // Listen for double taps
//        let doubleTapRecognizer = UITapGestureRecognizer(target: self,
//                                                         action: #selector(DrawView.doubleTap(_:)));
//        doubleTapRecognizer.numberOfTapsRequired = 2;
//        doubleTapRecognizer.delaysTouchesBegan = true;
//        addGestureRecognizer(doubleTapRecognizer);
//
//        // Listen for single taps
//        let tapRecognizer = UITapGestureRecognizer(target: self,
//                                                   action: #selector(DrawView.tap(_:)));
//        tapRecognizer.delaysTouchesBegan = true;
//        tapRecognizer.require(toFail: doubleTapRecognizer);
//        addGestureRecognizer(tapRecognizer);
//    }
    
//    @objc func doubleTap(_ gestureRecognizer: UIGestureRecognizer) {
//        print("I got a double tap...");
//        if let selectedIndex = selectedLineIndex {
//            finishedLines.remove(at: selectedIndex);
//            print("and deleted line", selectedIndex, ".");
//        }
//        else {
//            currentLines.removeAll(keepingCapacity: false);
//            finishedLines.removeAll(keepingCapacity: false);
//            print("and deleted all lines.");
//        }
//        selectedLineIndex = nil;
//        setNeedsDisplay();
//    }
    
//    @objc func tap(_ gestureRecognizer: UIGestureRecognizer) {
//        let tapPoint = gestureRecognizer.location(in: self);
//        selectedLineIndex = getLineNearPointIndex(point: tapPoint)
//        print("I got a tap on line ", selectedLineIndex);
//        setNeedsDisplay();
//    }


    

    /** Draws a line on this DrawView.  */
    func strokeLine(line: Line) {
        let path = UIBezierPath();
        path.lineWidth = lineThickness;
        path.lineCapStyle = CGLineCap.round;
          
        path.move(to: line.begin);
        path.addLine(to: line.end);
        path.stroke();
    }
    
    /** Draws a line on this DrawView.  */
    func strokeCurve(curve: Curve) {
        for point in curve.points {
            strokeCircle(location: point, radius: Int(lineThickness/2));
        }
    }
    
    /** Draws a circle */
    func strokeCircle(location: CGPoint, radius: Int) {
        let path = UIBezierPath(ovalIn:
            CGRect(
                x: Int(location.x) - radius,
                y: Int(location.y) - radius,
                width: 2 * radius,
                height: 2 * radius
            )
        );
        
        path.lineWidth = lineThickness;
        
        // Fill circle with its colour attribute
        path.fill();
        path.stroke();
    }
      
    /** Draws all lines onto the DrawView. */
    override func draw(_ rect: CGRect) {
        
        // Draw finished
        finishedLineColor.setStroke();
        finishedLineColor.setFill();
        for line in finishedLines {
            strokeLine(line: line);
        }
        for curve in finishedCurves {
            strokeCurve(curve: curve);
        }
        
        // Draw current
        currentLineColor.setStroke();
        currentLineColor.setFill();
        for (_, line) in currentLines {
            strokeLine(line: line);
        }
        for (_, curve) in currentCurves {
            strokeCurve(curve: curve);
        }
        
        // Draw message
        
        var prompt: String;
        if (status == Status.GRID_SETUP) {
            prompt = "Welcome! Please draw the board for Tic Tac Toe.";
        }
        else if (status == Status.X_TURN) {
            prompt = "It is X's turn.";
        }
        else {
            prompt = "It is O's turn.";
        }
        if let message = errorMessage {
            prompt += "\n" + message;
        }
        
        let fieldColor: UIColor = UIColor.darkGray;
        let fieldFont = UIFont(name: "Helvetica Neue", size: 18);
        let paraStyle = NSMutableParagraphStyle();
        paraStyle.lineSpacing = 6.0;
        paraStyle.alignment = NSTextAlignment.center;
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: fieldColor,
            NSAttributedString.Key.paragraphStyle: paraStyle,
            NSAttributedString.Key.font: fieldFont!
        ];
       
        // Draw the text
        NSString(string: prompt).draw(in: CGRect(x: 0.0, y: rect.height - 100.0, width: rect.width, height: 50.0), withAttributes: attributes);
    }
    
    //Override Touch Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (status == Status.GRID_SETUP) {
            for touch in touches {
                let location = touch.location(in: self);
                let newLine = Line(begin: location, end: location);
                currentLines[touch] = newLine;
            }
        }
        else {
            // Ignore touches if max number of concurrent touches reached
            if (status == Status.X_TURN && currentCurves.count >= 2) {
                return;
            }
            if (status == Status.O_TURN && currentCurves.count >= 1) {
                return;
            }
            
            // Take only the first touch
            let touch = touches.first!;
            
            let initialLocation = touch.location(in: self);
            let newCurve = Curve(points: [initialLocation]);
            currentCurves[touch] = newCurve;
        }
        
        setNeedsDisplay();
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (status == Status.GRID_SETUP) {
            for touch in touches {
                let endLocation = touch.location(in: self);
                currentLines[touch]?.end = endLocation;
                // Might be nil if another touchEnded cancels this
            }
        }
        else {
            // Take only the first touch
            let touch = touches.first!;
            
            let newLocation = touch.location(in: self);
            currentCurves[touch]!.points.append(newLocation);  // Shouldn't be nil
        }
        
        setNeedsDisplay();
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touchesMoved(touches, with: event);
        
        /****  GRID SETUP MODE ****/
        if (status == Status.GRID_SETUP) {
            // Move current line/curve to finished
            for touch in touches {
                if let finishedLine = currentLines[touch] {
                    finishedLines.append(finishedLine);
                }
                currentLines[touch] = nil;
            }
            
            // Done drawing -- do validation
            if (finishedLines.count == 4) {
                // Find horizontal/vertical lines
                var horizontalCount = 0;
                var yCoords: [Float] = [];
                var verticalCount = 0;
                var xCoords: [Float] = [];
                
                for line in finishedLines {
                    let (isHorizontal, yCoord) = line.isHorizontal();
                    let (isVertical, xCoord) = line.isVertical();
                    
                    if (isHorizontal) {
                        horizontalCount += 1;
                        yCoords.append(yCoord!);
                    }
                    else if (isVertical) {
                        verticalCount += 1;
                        xCoords.append(xCoord!);
                    }
                }
                
                // There aren't 2 vertical and 2 horizontal lines
                if !(horizontalCount == 2 && verticalCount == 2) {
                    finishedLines.removeAll();
                    errorMessage = "Lines are too crooked! Please redraw.";
                }
                else if abs(xCoords[0] - xCoords[1]) < MIN_GRID_DISTANCE || abs(yCoords[0] - yCoords[1]) < MIN_GRID_DISTANCE {
                    finishedLines.removeAll();
                    errorMessage = "Lines are too close together! Please redraw.";
                }
                // Move to X's turn
                else {
                    board = TicTacToe();
                    gridX = xCoords.sorted();
                    gridY = yCoords.sorted();
                    status = Status.X_TURN;
                    errorMessage = nil;
                }
            }
        }
        
        /****  DONE DRAWING X ****/
        else if (status == Status.X_TURN && currentCurves.count == 2) {
            let curves = Array(currentCurves.values);
            
            let (isX, notXReason) = Curve.isX(curve1: curves[0], curve2: curves[1]);
            errorMessage = notXReason;
            
            if (isX) {
                finishedCurves.append(curves[0]);
                finishedCurves.append(curves[1]);
                
                let position = Curve.getCenter(of: curves[0], curves[1]);
                board!.play(player: Player.X, row: getRow(position), col: getCol(position));
                status = Status.O_TURN;
            }

            currentCurves.removeAll();
        }
        
        /****  DONE DRAWING O ****/
        else if (status == Status.O_TURN) {
            let curve = currentCurves.first!.value;
            
            let (isO, notOReason) = Curve.isO(curve);
            errorMessage = notOReason;
            
            if (isO) {
                finishedCurves.append(curve);
                
                let position = Curve.getCenter(of: curve);
                board!.play(player: Player.O, row: getRow(position), col: getCol(position));
                
                status = Status.X_TURN;
            }
            
            currentCurves.removeAll();
        }
        
        //A document is added whenever game is over. That is whenever there's a winner or the game board is full
        if let winner = board?.getWinner() { //creates all required data to insert a new document into database whenever there's a winner
            errorMessage = "Player \(winner) wins!";
            let mutableDoc = MutableDocument(); // Create a new document (i.e. a record) to add in the database
            //let mutableDict = DictionaryObject();
            let gamesDict = MutableDictionaryObject();
            //let mutableDict = NSMutableDictionary(); // I don't think this works
            //let mutableDict = CFMutableDictionary(); // I don't think this works either
            
            //these are the arrays to be added to document
            let p1steps = MutableArrayObject() //I think this is the right collection
            let p2steps = MutableArrayObject()

            //iterate over TicTacToe.board to get the coordinates of where each player played
            for row in 0..<3 {
                for col in 0..<3 {
                    if (board?.getBoard()[row][col].get() == "X") {
                        let p1stepsDict = MutableDictionaryObject();
                        p1stepsDict.setInt(col, forKey: "Cell_x")
                        p1stepsDict.setInt(row, forKey: "Cell_y")
                        p1steps.addDictionary(p1stepsDict)
                    } else if (board?.getBoard()[row][col].get() == "O") {
                        let p2stepsDict = MutableDictionaryObject();
                        p2stepsDict.setInt(col, forKey: "Cell_x")
                        p2stepsDict.setInt(row, forKey: "Cell_y")
                        p2steps.addDictionary(p2stepsDict)
                    }
                }
            }
            
            //let arrayOfNums = [1, 2, 3, 4, 5] //I don't think this format is acceptable for ArrayObject...
            
            //populate the document to be inserted
            gamesDict.setArray(p1steps, forKey: "Player 1 Steps")
            gamesDict.setArray(p2steps, forKey: "Player 2 Steps")
            gamesDict.setString("Player \(winner) Win", forKey: "Outcome")
            mutableDoc.setString("game", forKey: "type")
            mutableDoc.setDictionary(gamesDict, forKey: "Games")
            
            let vc: ViewController = self.parentViewController! as! ViewController //ViewController object used to call the method for adding a row to the database
            vc.addGameDocument(mutableDoc: mutableDoc) //calls addGameDocument function in ViewController.swift with mutableDoc passed as argument to insert into database
        }
        else if board != nil && board!.isFull() { //creates all required data to insert a row into database whenever game ends in a tie
            errorMessage = "It's a tie!";
            let mutableDoc = MutableDocument(); // Create a new document (i.e. a record) to add in the database
            let gamesDict = MutableDictionaryObject();
            
            //these are the arrays to be added to document
            let p1steps = MutableArrayObject()
            let p2steps = MutableArrayObject()
            
            //iterate over TicTacToe.board to get the coordinates of where each player played
            for row in 0..<3 {
                for col in 0..<3 {
                    if (board?.getBoard()[row][col].get() == "X") {
                        let p1stepsDict = MutableDictionaryObject();
                        p1stepsDict.setInt(col, forKey: "Cell_x")
                        p1stepsDict.setInt(row, forKey: "Cell_y")
                        p1steps.addDictionary(p1stepsDict)
                    } else if (board?.getBoard()[row][col].get() == "O") {
                        let p2stepsDict = MutableDictionaryObject();
                        p2stepsDict.setInt(col, forKey: "Cell_x")
                        p2stepsDict.setInt(row, forKey: "Cell_y")
                        p2steps.addDictionary(p2stepsDict)
                    }
                }
            }
            
            //populate the document to be inserted
            gamesDict.setArray(p1steps, forKey: "Player 1 Steps")
            gamesDict.setArray(p2steps, forKey: "Player 2 Steps")
            gamesDict.setString("Tie", forKey: "Outcome")
            mutableDoc.setString("game", forKey: "type")
            mutableDoc.setDictionary(gamesDict, forKey: "Games")
            
            let vc: ViewController = self.parentViewController! as! ViewController //ViewController object used to call the method for adding a row to the database
            vc.addGameDocument(mutableDoc: mutableDoc) //calls addGameDocument function in ViewController.swift with mutableDoc passed as argument to insert into database
        }
        
        setNeedsDisplay();
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event);
    }
    
    
    func getRow(_ position: CGPoint) -> Int {
        if Float(position.y) < gridY![0] {
            return 0;
        }
        else if Float(position.y) < gridY![1] {
            return 1;
        }
        else {
            return 2;
        }
    }

    func getCol(_ position: CGPoint) -> Int {
        if Float(position.x) < gridX![0] {
            return 0;
        }
        else if Float(position.x) < gridX![1] {
            return 1;
        }
        else {
            return 2;
        }
    }
}
