//
//  MyRepoTableViewController.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/27.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit
import RealmSwift

class MyRepoTableViewController: UITableViewController {
    
    lazy var realm : Realm = {
        return try! Realm()
    }()
    
    var lyrics : Results<LyricModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLyrics()
    }
    
    //MARK: - Add Button Pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField: UITextField!
        
        let alert = UIAlertController(title: "Add New Lyric", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "그대에게"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Go", style: .default) {
            (action) in
            
            let newLyric = LyricModel()
            newLyric.title = textField!.text!
            self.saveLyric(lyric: newLyric)
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Access Realm Database
    func saveLyric(lyric: LyricModel) {
        do {
            try realm.write {
                realm.add(lyric)
            }
        } catch {
            print("Error saving lyric \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadLyrics() {
        print("loadLyrics")
        lyrics = realm.objects(LyricModel.self)
        
        self.tableView.reloadData()
    }
    
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lyrics?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let lyric = lyrics?[indexPath.row] {
            cell.textLabel?.text = lyric.title
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "MyRepoToLyric", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! LyricTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedLyric = lyrics?[indexPath.row]
        }
    }
    
}
