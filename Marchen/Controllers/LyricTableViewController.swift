//
//  LyricTableViewController.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/27.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit
import RealmSwift

class LyricTableViewController: UITableViewController {
    
    lazy var realm : Realm = {
        return try! Realm()
    }()
    
    var selectedLyric : LyricModel?
    {
        didSet {
            loadLyric()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.register(UINib(nibName: K.LyricLineCellNibName, bundle: nil), forCellReuseIdentifier: K.LyricLineCellIdentifier)
        
        tableView.rowHeight = 80.0
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        guard let numOfLines = selectedLyric?.lines.count else {
            fatalError("Error in counting selectedLyric.lines")
        }
        return numOfLines
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.LyricLineCellIdentifier, for: indexPath) as! LyricLineTableViewCell
        
        guard let numOfLines = selectedLyric?.lines.count else {
            fatalError("Error in counting selectedLyric.lines")
        }
        
        // 새로 생성된 Lyric 일 경우 Placeholder 표시
        if indexPath.row == 0 {
            cell.lyricTextField.placeholder = "숨가쁘게 살아가는 순간 속에도 "
        }
        
        // 이미 있어서 불러온 Lyric 일 경우
        if numOfLines != 0 {
            cell.lyricTextField.text = selectedLyric?.lines[indexPath.row]
            cell.lyricTextField.tag = indexPath.row
        }
        
        
        cell.lyricTextField.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
        
        return cell
    }
    func loadLyric() {
        title = selectedLyric?.title
    }
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        try! realm.write {
            selectedLyric?.lines.append("")
        }
        tableView.reloadData()
    }
    
    @objc func didChangeText(textField: UITextField) {
        try! realm.write {
            if let safeText = textField.text {
                selectedLyric?.lines[textField.tag] = safeText
            }
        }
    }
}
