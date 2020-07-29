//
//  MyRepoTableViewController.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/27.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class MyRepoTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    
    lazy var realm : Realm = {
        return try! Realm()
    }()
    
    var lyrics : Results<LyricModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadLyrics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
//        tableView.rowHeight = 60.0
        
        tableView.reloadData()
    }
    
    //MARK: - Add Button Pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField: UITextField!
        
        let alert = UIAlertController(title: "Add New Lyric", message: "", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let okAction = UIAlertAction(title: "OK", style: .default) {
            (action) in
            
            let newLyric = LyricModel()
            
            newLyric.title = textField!.text!
            newLyric.dateOfCreation = Date()
            newLyric.dateOfRecentEdit = Date()
            
            self.saveLyric(lyric: newLyric)
        }
        // No Title, No OK.
        okAction.isEnabled = false
        
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "그대에게"
            textField = alertTextField
            
            // Observe the UITextFieldTextDidChange notification to be notified in the below block when text is changed
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { _ in
                // Being in this block means that something fired the UITextFieldTextDidChange notification.
                
                // Access the textField object from alertController.addTextField(configurationHandler:) above and get the character count of its non whitespace characters
                let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                let textIsNotEmpty = textCount > 0
                
                // If the text contains non whitespace characters, enable the OK Button
                okAction.isEnabled = textIsNotEmpty
            }
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Database Access Functions
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
        lyrics = realm.objects(LyricModel.self).sorted(byKeyPath: "dateOfRecentEdit", ascending: false)
        
        //        self.tableView.reloadData()
    }
    
    
    func deleteLyric(at indexPath: IndexPath) {
        if let lyricForDeletion = self.lyrics?[indexPath.row] {
            let alert = UIAlertController(title: "Delete Lyric", message: "Are you sure want to delete \'\(lyricForDeletion.title)\'?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            let okAction = UIAlertAction(title: "OK", style: .default) {
                (action) in
                // Code here for updating the lyric title
                do {
                    try self.realm.write {
                        self.realm.delete(lyricForDeletion)
                    }
                } catch {
                    print("Error in deleting the lyric \(error)")
                }
                
                self.tableView.reloadData()
            }
            
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    func editLyricTitle(at indexPath: IndexPath) {
        if let lyricForEdition = self.lyrics?[indexPath.row] {
            var textField: UITextField!
            
            let alert = UIAlertController(title: "Edit Lyric Title", message: "", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            let okAction = UIAlertAction(title: "OK", style: .default) {
                (action) in
                // Code here for updating the lyric title
                do {
                    try self.realm.write {
                        lyricForEdition.title = textField.text!
                    }
                } catch {
                    print("Error in editing lyric title \(error)")
                    
                }
                
                self.tableView.reloadData()
                
            }
            // No Title, No OK.
            okAction.isEnabled = false
            
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            
            alert.addTextField { (alertTextField) in
                let previousTitle = lyricForEdition.title
                alertTextField.text = previousTitle
                
                textField = alertTextField
                
                // Observe the UITextFieldTextDidChange notification to be notified in the below block when text is changed
                NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { _ in
                    // Being in this block means that something fired the UITextFieldTextDidChange notification.
                    
                    // Access the textField object from alertController.addTextField(configurationHandler:) above and get the character count of its non whitespace characters
                    let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let textIsNotEmpty = textCount > 0 && textField.text != previousTitle
                    
                    // If the text contains non whitespace characters, enable the OK Button
                    okAction.isEnabled = textIsNotEmpty
                }
            }
            
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    
    
    // MARK: - Tableview Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == K.LyricSectionNumber {
            return "Recent Lyrics"
        } else {
            return "Recent Songs"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == K.LyricSectionNumber {
            return lyrics?.count ?? 0
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        if let lyric = lyrics?[indexPath.row] {
            cell.textLabel?.text = lyric.title
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "MyRepoToLyric", sender: self)
    }
    
    //MARK: - Swipe Cell Functions
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if orientation == .right {
            let deleteAction = SwipeAction(style: .destructive, title: nil) { (action, indexPath) in
                self.deleteLyric(at: indexPath)
            }
            
            deleteAction.image = UIImage(systemName: "trash")
            
            return [deleteAction]
            
        } else if orientation == .left {
            let editAction = SwipeAction(style: .default, title: nil) { (action, indexPath) in
                self.editLyricTitle(at: indexPath)
            }
            
            editAction.image = UIImage(systemName: "pencil")
            return [editAction]
            
        } else {
            return nil
        }
        
    }
    
    
    //    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
    //        var options = SwipeTableOptions()
    //        options.expansionStyle = .destructive
    //
    //        return options
    //    }
    
    
    //MARK: - Prepare Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! LyricTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedLyric = lyrics?[indexPath.row]
        }
    }
    
}
