//
//  LyricTableViewController.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/27.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit
import RealmSwift

class LyricTableViewController: UITableViewController, UITextFieldDelegate {
    
    lazy var realm : Realm = {
        return try! Realm()
    }()
    
    var selectedLyric : LyricModel?
    {
        didSet {
            loadLyric()
        }
    }
    
    var currentEditingLine: Int?
    
    var indexOfLineToFocus: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.LyricLineCellNibName, bundle: nil), forCellReuseIdentifier: K.LyricLineCellIdentifier)
        
        tableView.rowHeight = 80.0
        
        tableView.keyboardDismissMode = .onDrag
        
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        guard let numOfLines = selectedLyric?.lines.count else {
            fatalError("Error in counting selectedLyric.lines")
        }
        if numOfLines == 0 {
            return 1
        } else {
            return numOfLines
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.LyricLineCellIdentifier, for: indexPath) as! LyricLineTableViewCell
        
        guard let numOfLines = selectedLyric?.lines.count else {
            fatalError("Error in counting selectedLyric.lines")
        }
        
        // 아직 Lyric line이 추가되지 않은 경우 Guide 표시
        if  indexPath.row == 0 && numOfLines == 0 {
            cell.lyricTextField.text = "'+' 버튼을 눌러 가사를 추가하세요."
            cell.lyricTextField.isEnabled = false
        }
        
        // 처음으로 생성된 Lyric line 일 경우 Placeholder 표시
        if  indexPath.row == 0 && numOfLines != 0 {
            cell.lyricTextField.placeholder = "숨가쁘게 살아가는 순간 속에도 "
            cell.lyricTextField.isEnabled = true
        }
        
        // 이미 있어서 불러온 Lyric 일 경우
        if numOfLines != 0 {
            cell.lyricTextField.text = selectedLyric?.lines[indexPath.row]
            cell.lyricTextField.tag = indexPath.row
        }
        
        cell.lyricTextField.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
        
        cell.lyricTextField.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let idx = indexOfLineToFocus {
            if indexPath.row == idx {
                print("Focusing: \(idx)")
                (cell as! LyricLineTableViewCell).lyricTextField.becomeFirstResponder()
            }
        }
    }
    
    //MARK: - Load Lyric Function
    func loadLyric() {
        title = selectedLyric?.title
    }
    
    //MARK: - Add Button Clicked
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        
        guard let lyric = selectedLyric else {
            fatalError("addButtonClicked: selectedLyric doesn't exist.")
        }
        
        try! realm.write {
            if let editingLineNum = currentEditingLine {
                lyric.lines.insert("", at: editingLineNum + 1)
                
                indexOfLineToFocus = editingLineNum + 1
            } else {
                lyric.lines.append("")
                
                indexOfLineToFocus = lyric.lines.count - 1
            }
        }
        
        tableView.reloadData()
    }
    
    
    //MARK: - Textfield Functions
    @objc func didChangeText(textField: UITextField) {
        try! realm.write {
            if let safeText = textField.text {
                // text
                selectedLyric?.lines[textField.tag] = safeText
                selectedLyric?.dateOfRecentEdit = Date()
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentEditingLine = textField.tag
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - View Functions
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        //        scrollToTop()
    //    }
    //
    //    func scrollToTop() {
    //        var offset = CGPoint(
    //            x: -tableView.contentInset.left,
    //            y: -tableView.contentInset.top
    //        )
    //
    //        if #available(iOS 11.0, *) {
    //            offset = CGPoint(
    //                x: -tableView.adjustedContentInset.left,
    //                // I don't know why this magic number works... lol.
    //                y: -(tableView.adjustedContentInset.top + 0.1667))
    //        }
    //
    //        tableView.setContentOffset(offset, animated: true)
    //    }
    
}
