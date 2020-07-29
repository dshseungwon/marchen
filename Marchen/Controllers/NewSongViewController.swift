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
    
    enum Keys: Int, CaseIterable {
        case C = 0
        case D = 1
        case E = 2
        case F = 3
        case G = 4
        case A = 5
        case B = 6
    }
    
//    let Keys : Dictionary<String, Int> = ["C":0, "D":1, "E":2, "F":3, "G":4, "A":5, "B":6]
    
    enum DiatonicChords: Int, CaseIterable {
        case I = 0
        case II = 1
        case III = 2
        case IV = 3
        case V = 4
        case VI = 5
        case VII = 6
    }
    
    var selectedLyric : LyricModel?
     {
         didSet {
             loadLyric()
         }
     }
    
    var selectedChord: DiatonicChords?
    var selectedKey: Keys?
    
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
        return DiatonicChords.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.ChordCellIdentifier, for: indexPath) as! ChordTableViewCell
        
        guard let chord = DiatonicChords(rawValue: indexPath.row) else { fatalError("No such chord exists") }
        
        switch chord {
        case DiatonicChords.I:
            cell.chordTextLabel.text = "I"
        case DiatonicChords.II:
            cell.chordTextLabel.text = "II"
        case DiatonicChords.III:
            cell.chordTextLabel.text = "III"
        case DiatonicChords.IV:
            cell.chordTextLabel.text = "IV"
        case DiatonicChords.V:
            cell.chordTextLabel.text = "V"
        case DiatonicChords.VI:
            cell.chordTextLabel.text = "VI"
        case DiatonicChords.VII:
            cell.chordTextLabel.text = "VII"
        }
        
        
        return cell
    }
}

//MARK: - TableView Delegate Methods
extension NewSongViewController: UITableViewDelegate {
    // Choose Chord to make song with.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedChord = DiatonicChords(rawValue: indexPath.row)
    }
    
}

//MARK: - PickerView Datasource Methods
extension NewSongViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Keys.allCases.count
    }
    
    
}

//MARK: - PickerView Delegate Methods
extension NewSongViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let key = Keys(rawValue: row) else { fatalError("No such key exists") }
        
        switch key {
        case Keys.C:
            return "C"
        case Keys.D:
            return "D"
        case Keys.E:
            return "E"
        case Keys.F:
            return "F"
        case Keys.G:
            return "G"
        case Keys.A:
            return "A"
        case Keys.B:
            return "B"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedKey = Keys(rawValue: row)
    }
}
