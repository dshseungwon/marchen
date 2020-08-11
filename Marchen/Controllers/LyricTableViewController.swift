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
    
    var selectedLyric : LyricModel? {
        didSet {
            loadLyric()
        }
    }
    
    var currentEditingLine: Int?
    
    var indexOfLineToFocus: Int?
    
    var focusToNewCell = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.LyricLineCellNibName, bundle: nil), forCellReuseIdentifier: K.LyricLineCellIdentifier)
        
        tableView.rowHeight = 80.0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard))
        
        tapGesture.cancelsTouchesInView = true
        
        tableView.keyboardDismissMode = .onDrag
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        loadLyric()
    }
    
    @objc func dissmissKeyboard() {
        tableView.endEditing(true)
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
            cell.lyricTextField.placeholder = nil
            cell.lyricTextField.text = selectedLyric?.lines[indexPath.row]
            cell.lyricTextField.tag = indexPath.row
        }
        
        cell.lyricTextField.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
        
        cell.lyricTextField.delegate = self
        
        cell.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width - CGFloat(20), height: cell.frame.size.height)
        cell.lyricTextField.frame = cell.frame
        cell.underlineView.frame = cell.frame
        cell.underlineView.layer.addBorder([.bottom], color: UIColor.label, width: 1.5)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let idx = indexOfLineToFocus {
            if indexPath.row == idx && focusToNewCell {
                (cell as! LyricLineTableViewCell).lyricTextField.becomeFirstResponder()
                focusToNewCell = false
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
        
        focusToNewCell = true
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: indexOfLineToFocus ?? lyric.lines.count - 1, section: 0), at: .none, animated: true)
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentEditingLine = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - New Song Button Clicked
    @IBAction func newSongButtonClicked(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "NewLyricToNewSong", sender: self)
    }
    
    //MARK: - Prepare Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! NewSongViewController
        
        destinationVC.selectedLyric = selectedLyric

    }
    
    
    
    //MARK: - View Functions
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            tableView.reloadData()
        } else {
            tableView.reloadData()
        }
    }
    
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
