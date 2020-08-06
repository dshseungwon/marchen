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
    
    var selectedKey: Key = Key.C
    
    var songEngine : SongEngine?
    
    private var nowPlayingChord = false
    private var playingCellTag: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.ChordCellNibName, bundle: nil), forCellReuseIdentifier: K.ChordCellIdentifier)
        tableView.rowHeight = 50.0
        
        tableView.dataSource = self
        tableView.delegate = self
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        generateButton.isEnabled = false
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        songEngine = SongEngine()
        songEngine?.attachObserver(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
// 이러지 말고 새로 start 하기 전에 무조건 invalidate 해주는 logic 으로 변경
//        songEngine.invalidate()
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
        
        // Set Label
        let chordProgression = chordProgressions[indexPath.row]
        
        let strArray = Utils.TransformChordProgressionToStringArray(chordProgression: chordProgression, key: selectedKey )
        
        var format = "%@"
        for _ in 1 ..< chordProgression.count {
            format += " - %@"
        }
        
//        let format = "%@ - %@ - %@ - %@"
        let formattedString = String(format: format, arguments: strArray)
        
        cell.chordTextLabel.text = formattedString
        cell.cellDiatonicProgression = chordProgression
        
        // Set Button
        cell.delegate = self
        cell.tag = indexPath.row
        
        cell.chordPlayButton.imageView?.tintColor = .link
        cell.chordPlayButton.isEnabled = true
        
        // cell 을 reuse 하니까 isPlaying 까지 Reuse 되는 버그 발생.
        // isPlaying 정보를 여기 Controller가 가지고 있자.
        if nowPlayingChord && !cell.isPlaying {
            cell.chordPlayButton.imageView?.tintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            cell.chordPlayButton.isEnabled = false
        }
        
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
        
        guard let key = Key(rawValue: row) else { fatalError("Error in setting Key from the picker") }
        selectedKey = key
        
        changeTableViewSetting(tableView: tableView)
        
    }
    
    //MARK: - TableView Deselect The Selected Item
    func changeTableViewSetting(tableView: UITableView) {
        if let selectedTableViewItem = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedTableViewItem, animated: true)
        } else {
        }
        
        generateButton.isEnabled = false
        
        // Make music stop if was playing
        if nowPlayingChord {
            songEngine?.reset()
            update(true)
        } else {
            tableView.reloadData()
        }
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


// How to deal with the initializating timing problem?
// 1. Event-driven
// 2. Wrapper Class
// 3. isInitied
// 4. Some keyword


extension NewSongViewController: ChordPlayable {
    
    func play(diatonicProgression: [Diatonic], tag: Int) {
        songEngine?.setBPM(as: 240)
        songEngine?.setKeyAndDiatonicProgression(key: selectedKey, diatonicProgression: diatonicProgression)
        songEngine?.play()
        nowPlayingChord = true
        playingCellTag = tag
        tableView.reloadData()
    }
    
    func stop() {
        // RESET THE TICK
        songEngine?.reset()
        nowPlayingChord = false
        tableView.reloadData()
    }
    
}

extension NewSongViewController: Observer {
    func update(_ notifyValue: Bool) { // We only call this function when song has finshed its playing.
        guard let tag = playingCellTag else { fatalError("playingCellTag is nil") }
        nowPlayingChord = false // same with !notifyValue
        if let cell = tableView.cellForRow(at: IndexPath(row: tag, section: 0)) {
            let castedCell = cell as! ChordTableViewCell
            castedCell.songHasFinished()
            tableView.reloadData()
        }
    }
}
