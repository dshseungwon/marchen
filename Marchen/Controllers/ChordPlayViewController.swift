//
//  ChordPlayViewController.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/30.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI
import RealmSwift

class ChordPlayViewController: UIViewController, MyKeyboardDelegate, ChordKeyObserver, RecordedSongHasFinished {
    
    func update(_ notifyValue: Bool) {
        isPlayingRecorded = false
        playRecordedButton.image = UIImage(systemName: "play.circle")
    }
    
    
    func updateNextChordKeys(nextChordKeys: Set<MIDINoteNumber>) {
        var newSet = Set<MIDINoteNumber>()
        for note in nextChordKeys {
            var startNote = note % 12
            while startNote <= 128 {
                newSet.insert(startNote)
                startNote += 12
            }
        }
        
        keyboardView.nextChordKeys = newSet
        keyboardView.setNeedsDisplay()
    }
    
    func update(currentChordKeys: Set<MIDINoteNumber>) {
        var newSet = Set<MIDINoteNumber>()
        for note in currentChordKeys {
            var startNote = note % 12
            while startNote <= 128 {
                newSet.insert(startNote)
                startNote += 12
            }
        }
        
        keyboardView.chordKeys = newSet
        keyboardView.nextChordKeys.removeAll()
        keyboardView.setNeedsDisplay()
    }
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var recordButton: UIBarButtonItem!
    
    @IBOutlet weak var playRecordedButton: UIBarButtonItem!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var bpmLabel: UILabel!
    
    @IBOutlet weak var stepperUI: UIStepper!
    
    @IBOutlet weak var lyricScrollView: UIScrollView!
    @IBOutlet weak var lyricLabel: UILabel!
    
    @IBOutlet weak var keyboardStackView: UIStackView!
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        changeUIWhenStop()
        songEngine.setBPM(as: Int(sender.value))
        bpmLabel.text = "BPM: \(Int(sender.value).description)"
    }
    
    // From the Previous VC
    var selectedDiatonicProgression: [Diatonic]? // e.g. [I, V, VI, IV]
    
    var selectedKey: Key? // e.g. Key.C
    
    var selectedLyric : LyricModel?
    {
        didSet {
            loadLyric()
        }
    }
    
    // Could lead to a timing problem. Be careful!
    private lazy var songEngine = {
        return SongEngine(songName: selectedLyric!.title)
    }()
    
    private var scrollViewHasFlashed = false
    private let keyboardView = MyKeyboardView()
    
    private var isPlaying = false
    private var isRecording = false
    private var isPlayingRecorded = false
    
    private var songName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    // This method is called before ViewDidLoad
    private func loadLyric() {
        songName = selectedLyric?.title
        title = songName
        
        // Solve possible timing problem.
        songEngine.attachChordKeyObserver(self)
        songEngine.attachRecordedSongObserver(self)
    }
    
    private func setupUI() {
        playButton.backgroundColor = .clear
        playButton.layer.cornerRadius = 5
        playButton.layer.borderWidth = 1
        playButton.layer.borderColor = UIColor.label.cgColor
        
        stepperUI.value = 120
        
        keyboardView.delegate = self
        keyboardView.polyphonicMode = true
        keyboardStackView.addArrangedSubview(keyboardView)
        
        shareButton.isEnabled = false
        playRecordedButton.isEnabled = false
        
        lyricScrollView.backgroundColor = .clear
        lyricScrollView.layer.cornerRadius = 5
        lyricScrollView.layer.borderWidth = 1
        lyricScrollView.layer.borderColor = UIColor.label.cgColor
        
        guard let lyric = selectedLyric else { fatalError("selectedLyric is nil") }
        var lyricText = " "
        for line in lyric.lines {
            lyricText += "\(line) "
        }
        lyricLabel.text = lyricText
    }
    
    private func changeUIWhenStop() {
        if isPlaying {
            songEngine.reset()
            playButton.setTitle("Play", for: .normal)
            isPlaying = false
        }
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        isPlaying = !isPlaying
        if isPlaying {
            sender.setTitle("Stop", for: .normal)
            guard let key = selectedKey else { fatalError("Key did not set.") }
            guard let progression = selectedDiatonicProgression else { fatalError("Progression did not set.") }
            
            songEngine.setIsRepeat(as: true)
            songEngine.setKeyAndDiatonicProgression(key: key, diatonicProgression: progression)
            songEngine.play()
        } else {
            sender.setTitle("Play", for: .normal)
            songEngine.reset()
        }
        
    }
    
    @IBAction func repeatsOfAChordButtonClicked(_ sender: UIButton) {
        guard let buttonText = sender.titleLabel?.text else {fatalError("Error in getting buttonText")}
        songEngine.setRepeatsOfAChord(as: Int(buttonText) ?? 1)
        changeUIWhenStop()
    }
    
    
    @IBAction func chordShiftsInABarButtonClicked(_ sender: UIButton) {
        guard let buttonText = sender.titleLabel?.text else {fatalError("Error in getting buttonText")}
        songEngine.setChordsInABar(as: Int(buttonText) ?? 1)
        changeUIWhenStop()
    }
    
    func noteOn(note: MIDINoteNumber) {
        songEngine.play(note: note)
        
        // Scroll lyricLabel to right
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.lyricScrollView.contentOffset.x += 15
            }
            if !self.scrollViewHasFlashed {
                self.lyricScrollView.flashScrollIndicators()
                self.scrollViewHasFlashed = true
            }
        }
        
    }
    
    func noteOff(note: MIDINoteNumber) {
        songEngine.stop(note: note)
    }
    
    @IBAction func recordButtonClicked(_ sender: UIBarButtonItem) {
        if isRecording {
            // END RECORDING
            songEngine.stopRecording()
            isRecording = false
            
            // Button Image Change
            recordButton.image = UIImage(systemName: "recordingtape")
            
            shareButton.isEnabled = true
            playRecordedButton.isEnabled = true
        } else {
            // RESET THE PREVIOUS RECORD
            songEngine.resetRecording()
            
            // START RECORDING
            songEngine.startRecording()
            isRecording = true
            
            // Button Image Change
            recordButton.image = UIImage(systemName: "stop.fill")
        }
        
    }
    
    @IBAction func playRecordedButtonClicked(_ sender: UIBarButtonItem) {
        isRecording = false
        recordButton.image = UIImage(systemName: "recordingtape")
        
        if isPlayingRecorded {
            isPlayingRecorded = false
            playRecordedButton.image = UIImage(systemName: "play.circle")
        } else {
            isPlayingRecorded = true
            playRecordedButton.image = UIImage(systemName: "stop.circle")
        }
        songEngine.playRecording()
    }
    
    @IBAction func shareButtonClicked(_ sender: UIBarButtonItem) {
        var textField: UITextField!
        
        let alert = UIAlertController(title: "Save recording", message: "", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let okAction = UIAlertAction(title: "OK", style: .default) {
            (action) in
            
            self.songEngine.saveRecording(fileName: textField.text!) { (url) in
                
                // Due to Realm thread-contained policy.
                // Be careful not to update realm object on the UI Thread
                // It causes 'Realm accessed from incorrect thread' error.
                // In this case, as selectedLyric was Realm object, we shouldn't have accessed it on another thread.
                DispatchQueue.main.async {
                    do {
                        let realm = try! Realm()
                        let newRecordedSong = RecordedSongModel()
                        
                        if let name = self.songName {
                            newRecordedSong.songName = name
                        }
                        newRecordedSong.fileName = textField.text!
                        newRecordedSong.dateOfCreation = Date()
                        
                        try realm.write {
                            realm.add(newRecordedSong)
                        }
                        
                        // Export Dialog
                        let activity = UIActivityViewController(
                            activityItems: [url!],
                            applicationActivities: nil
                        )
                        activity.popoverPresentationController?.barButtonItem = sender
                        self.present(activity, animated: true, completion: nil)
                        
                    } catch {
                        print("Error saving song \(error)")
                    }
                }
            }
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "그대에게"
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
        
    }
    @IBAction func keyboardModeSwitch(_ sender: UISwitch) {
        if sender.isOn == true {
            if let keyOffset = selectedKey?.rawValue {
                keyboardView.setBaseMIDINote(as: 24 + keyOffset)
            }
        } else {
            keyboardView.setBaseMIDINote() // default = 24
        }
    }
    
    @IBAction func changeSoundButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func playIChordForNextButtonClicked(_ sender: UIButton) {
        
    }
}
