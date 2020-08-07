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

class ChordPlayViewController: UIViewController, MyKeyboardDelegate, ChordKeyObserver {
    
    func update(_ notifyValue: Set<MIDINoteNumber>) {
        
        var newSet = Set<MIDINoteNumber>()
        for note in notifyValue {
            var startNote = note % 12
            while startNote <= 128 {
                newSet.insert(startNote)
                startNote += 12
            }
        }
        
        keyboardView.chordKeys = newSet
        keyboardView.setNeedsDisplay()
    }
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var bpmLabel: UILabel!
    
    @IBOutlet weak var stepperUI: UIStepper!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        if isPlaying {
            songEngine.reset()
            playButton.setTitle("Play", for: .normal)
        }
        songEngine.setBPM(as: Int(sender.value))
        bpmLabel.text = "BPM: \(Int(sender.value).description)"
    }
    
    // From the Previous VC
    var selectedDiatonicProgression: [Diatonic]? // e.g. [I, V, VI, IV]
    
    var selectedKey: Key? // e.g. Key.C
    
    private let songEngine = SongEngine()
    private let keyboardView = MyKeyboardView()
    
    private var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songEngine.attachChordKeyObserver(self)
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    private func setupUI() {
        playButton.backgroundColor = .clear
        playButton.layer.cornerRadius = 5
        playButton.layer.borderWidth = 1
        playButton.layer.borderColor = UIColor.black.cgColor
        
        stepperUI.value = 120
        
        keyboardView.delegate = self
        keyboardView.polyphonicMode = true
        stackView.addArrangedSubview(keyboardView)
        
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
    
    func noteOn(note: MIDINoteNumber) {
        songEngine.play(note: note)
    }
    
    func noteOff(note: MIDINoteNumber) {
        songEngine.stop(note: note)
    }
}
