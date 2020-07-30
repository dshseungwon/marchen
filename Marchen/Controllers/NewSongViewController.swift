//
//  NewSongViewController.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/29.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit

class NewSongViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    // Key(Diatonic Chord Progression) -> Chords
    // C(I - V - VI - IV) -> C - G - AM - F
    
    // Needs to define
    // Chord DS
    // Chord: Set of keys
    
    
    // Diatonic Chord Progression DS
    // -> List of Diatonic chords
    
    
    // Chord Progression DS
    // -> List of Chords
    
    
    // getChord(Key, Diatonic Chord)
    // getChord(Key.C, DiatonicChords.I) -> C
    
    
    var selectedLyric : LyricModel?
    {
        didSet {
            loadLyric()
        }
    }
    
    var selectedChord: Diatonic?
    var selectedKey: Key?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.ChordCellNibName, bundle: nil), forCellReuseIdentifier: K.ChordCellIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
    }
    
    //MARK: - Load Lyric Function
    func loadLyric() {
        title = selectedLyric?.title
    }
    
}

//MARK: - TableView Datasource Methods
extension NewSongViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Diatonic.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.ChordCellIdentifier, for: indexPath) as! ChordTableViewCell
        
        guard let chord = Diatonic(rawValue: indexPath.row) else { fatalError("No such chord exists") }
        
        cell.chordTextLabel.text = Utils.diatonicToStrDic[chord]
        
        return cell
    }
}

//MARK: - TableView Delegate Methods
extension NewSongViewController: UITableViewDelegate {
    // Choose Chord to make song with.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChord = Diatonic(rawValue: indexPath.row)
    }
    
}

//MARK: - PickerView Datasource Methods
extension NewSongViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Key.allCases.count
    }
    
    
}

//MARK: - PickerView Delegate Methods
extension NewSongViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let key = Key(rawValue: row) else { fatalError("No such key exists") }
        
        return Utils.keyToStr(key: key)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedKey = Key(rawValue: row)
    }
}

//MARK: - Prepare Segue
extension NewSongViewController {
    
    @IBAction func generateButtonClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "NewSongToChordPlay", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ChordPlayViewController
        
        destinationVC.selectedKey = selectedKey
        destinationVC.selectedChord = selectedChord
        
    }
}
