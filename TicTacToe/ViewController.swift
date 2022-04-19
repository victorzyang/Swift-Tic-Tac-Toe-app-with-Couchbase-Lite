//
//  ViewController.swift
//  TicTacToe
//
//  Created by Victor Yang
//  Copyright © 2020 COMP2601. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift

class ViewController: UIViewController {

    var database:Database? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("Opening database")
        
        // Get the database (and create it if it doesn’t exist).
        //let database: Database
        do {
            print("Successfully opened Database")
            database = try Database(name: "gamesDB")
        } catch {
            fatalError("Error opening database")
        }
        
    }
    
    func addGameDocument(mutableDoc: MutableDocument){
        // Saves document to the database.
        print("Adding new game document to database")
        do {
            print("Successfully added document to database")
            try database?.saveDocument(mutableDoc)
        } catch {
            fatalError("Error saving document")
        }
    }

    //function for viewing the database data
    @IBAction func displayData(_ sender: UIButton){
        print("displayData button clicked")
        
        //query to fetch documents of type "game"
        let resultSet = QueryBuilder
            .select(
                SelectResult.expression(Meta.id),
                SelectResult.property("Games"))
            .from(DataSource.database(database!))
            .where(Expression.property("type").equalTo(Expression.string("game")))
        
        var message = "" //this is the variable containing everything to display to the UI
        
        print("Selecting all games from the games table")
        
        //run the 'resultSet' query
        do {
            for result in try resultSet.execute() { //iterates through all games in the database to append information to display to the message variable
                message += "Games: {Id: "
                message += result.string(forKey: "id")!
                message += ", Player 1 Steps: ["
                
                let p1steps = (result.dictionary(forKey: "Games")?.array(forKey: "Player 1 Steps")!)!
                for index in 0..<p1steps.count{
                    message += "{Cell_x: "
                    let p1cell_x = (p1steps.dictionary(at: index)?.int(forKey: "Cell_x"))!
                    message += "\(p1cell_x), Cell_y: "
                    let p1cell_y = (p1steps.dictionary(at: index)?.int(forKey: "Cell_y"))!
                    message += "\(p1cell_y)}"
                }
                    
                //message += (result.dictionary(forKey: "Games")?.array(forKey: "Player 1 Steps")!)!
                message += "], Player 2 Steps: "
                
                let p2steps = (result.dictionary(forKey: "Games")?.array(forKey: "Player 2 Steps")!)!
                for index in 0..<p2steps.count{
                    message += "{Cell_x: "
                    let p2cell_x = (p2steps.dictionary(at: index)?.int(forKey: "Cell_x"))!
                    message += "\(p2cell_x), Cell_y: "
                    let p2cell_y = (p2steps.dictionary(at: index)?.int(forKey: "Cell_y"))!
                    message += "\(p2cell_y)}"
                }
                
                message += ", Outcome: "
                message += (result.dictionary(forKey: "Games")?.string(forKey: "Outcome"))!
                message += "}\n\n"
            }
            
            showMessage(title: "Database Data", message: message) //calls function to trigger an alert that displays the database data
        } catch {
            print(error)
        }
        
    }
    
    //function for which an alert pops up to display database data
    func showMessage(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
                case .default:
                print("default")
                
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
                
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

