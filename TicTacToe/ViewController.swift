//
//  ViewController.swift
//  TicTacToe
//
//  Created by gliao on 2020-03-24.
//  Copyright © 2020 COMP2601. All rights reserved.
//

import UIKit
import CouchbaseLiteSwift

class ViewController: UIViewController {

    var database:Database? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Get the database (and create it if it doesn’t exist).
        //let database: Database
        do {
            database = try Database(name: "gamesDB")
        } catch {
            fatalError("Error opening database")
        }
        
        // Create a new document (i.e. a record) in the database.
        
        //Where do I make the document? In DrawView or TicTacToe?
        
        //I add a document whenever game is over. That is whenever there's a winner or the game board is full (TicTacToe has 2 methods for that)
        
        //So, I think I should create and add a document in the DrawView class at the end of the touchesEnded method
        
        // Creating a query to fetch documents of type SDK. (Where would I do this? I think in the displayData function down below)
        /*let query = QueryBuilder
            .select(SelectResult.all())
            .from(DataSource.database(database!))
            .where(Expression.property("type").equalTo(Expression.string("SDK")))*/
        
        // Running the 'query'.
        /*do {
            let result = try query.execute()
            print("Number of rows :: \(result.allResults().count)")
        } catch {
            fatalError("Error running the query")
        }*/
        
    }
    
    func addGameDocument(mutableDoc: MutableDocument){
        // Saving document to the database.
        do {
            try database?.saveDocument(mutableDoc)
        } catch {
            fatalError("Error saving document")
        }
    }

    //TODO: have a function for viewing the database data
    @IBAction func displayData(_ sender: UIButton){
        print("displayData button clicked")
        let resultSet = QueryBuilder
            .select(
                SelectResult.expression(Meta.id),
                SelectResult.property("Games"))
            .from(DataSource.database(database!))
            .where(Expression.property("type").equalTo(Expression.string("game")))
        
        var message = ""
        
        //TODO: run the query (ie. resultSet)
        do {
            for result in try resultSet.execute() {
                message += "Games: {Id: "
                message += result.string(forKey: "id")!
                message += ", Player 1 Steps: ["
                //TODO: iterate through ArrayObject
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
                //TODO: iterate through ArrayObject
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
            
            showMessage(title: "Database Data", message: message)
        } catch {
            print(error)
        }
        
    }
    
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

