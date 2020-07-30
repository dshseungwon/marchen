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
    
    enum Diatonic: Int, CaseIterable {
        case I = 0
        case II = 1
        case III = 2
        case IV = 3
        case V = 4
        case VI = 5
        case VII = 6
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
    
    var chordProgression: [[Diatonic]] = [
        [Diatonic.I, Diatonic.V, Diatonic.VI, Diatonic.IV],
        [Diatonic.I, Diatonic.VI, Diatonic.II, Diatonic.V],
        [Diatonic.II, Diatonic.V, Diatonic.I, Diatonic.VI],
        [Diatonic.IV, Diatonic.V, Diatonic.III, Diatonic.VI],
        [Diatonic.I, Diatonic.II, Diatonic.III, Diatonic.IV],
        [Diatonic.IV, Diatonic.V, Diatonic.VI, Diatonic.III]
    ]
    
    /*
     Diatonic Chord Progression:
     
     1) I - V - VI - IV
     2) I - VI - II - V
     3) II - V - I - VI
     4) IV - V - III - VI
     5) I - II - III - IV
     6) IV - V - VI - III
     
     Ref) https://m.post.naver.com/viewer/postView.nhn?volumeNo=26918722&memberNo=16273960
     
     */
    
    // Scale 의 1 / 3 / 5 음 출력?
    
    var selectedLyric : LyricModel?
     {
         didSet {
             loadLyric()
         }
     }
    
    var selectedChord: Diatonic?
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
        return Diatonic.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.ChordCellIdentifier, for: indexPath) as! ChordTableViewCell
        
        guard let chord = Diatonic(rawValue: indexPath.row) else { fatalError("No such chord exists") }
        
        switch chord {
        case Diatonic.I:
            cell.chordTextLabel.text = "I"
        case Diatonic.II:
            cell.chordTextLabel.text = "II"
        case Diatonic.III:
            cell.chordTextLabel.text = "III"
        case Diatonic.IV:
            cell.chordTextLabel.text = "IV"
        case Diatonic.V:
            cell.chordTextLabel.text = "V"
        case Diatonic.VI:
            cell.chordTextLabel.text = "VI"
        case Diatonic.VII:
            cell.chordTextLabel.text = "VII"
        }
        
        
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
