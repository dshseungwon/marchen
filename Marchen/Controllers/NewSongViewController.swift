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
    
    @IBOutlet weak var generateButton: UIBarButtonItem!
    
    var selectedLyric : LyricModel?
    {
        didSet {
            loadLyric()
        }
    }
    
    var selectedChordProgression: [Diatonic]?
    {
        didSet {
            generateButton.isEnabled = true
        }
    }
    
    var selectedKey: Key?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.ChordCellNibName, bundle: nil), forCellReuseIdentifier: K.ChordCellIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        generateButton.isEnabled = false
        
    }
    
    //MARK: - Load Lyric Function
    func loadLyric() {
        title = selectedLyric?.title
    }
    
}

//MARK: - TableView Datasource Methods
extension NewSongViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chordProgressions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.ChordCellIdentifier, for: indexPath) as! ChordTableViewCell
        
        let chordProgression = chordProgressions[indexPath.row]
       
        let strArray = Utils.TransformChordProgressionToStringArray(chordProgression: chordProgression, key: selectedKey ?? Key.C)
        
        let format = "%@ - %@ - %@ - %@"
        let formattedString = String(format: format, arguments: strArray)
        
        cell.chordTextLabel.text = formattedString
        
        return cell
    }
}

//MARK: - TableView Delegate Methods
extension NewSongViewController: UITableViewDelegate {
    // Choose Chord to make song with.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChordProgression = chordProgressions[indexPath.row]
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
        tableView.reloadData()
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
        destinationVC.selectedChordProgression = selectedChordProgression
        
    }
}


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
