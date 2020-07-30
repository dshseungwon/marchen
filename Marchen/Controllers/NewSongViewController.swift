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
