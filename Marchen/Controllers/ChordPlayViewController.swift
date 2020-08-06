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
    
    
    @IBOutlet weak var stackView: UIStackView!
    
    // From the Previous VC
    var selectedDiatonicProgression: [Diatonic]? // e.g. [I, V, VI, IV]
    
    var selectedKey: Key? // e.g. Key.C
    
    //
    //    var currentProgress: Float {
    //         return Float(self.currentTick / self.songPlayTime)
    //     }
    //    self.progressView.setProgress(self.currentProgress, animated: true)
    

    let songEngine = SongEngine()
    let keyboardView = MyKeyboardView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songEngine.attachChordKeyObserver(self)
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    private func setupUI() {
        keyboardView.delegate = self
        keyboardView.polyphonicMode = true
        stackView.addArrangedSubview(keyboardView)
        
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        guard let key = selectedKey else { fatalError("Key did not set.") }
        guard let progression = selectedDiatonicProgression else { fatalError("Progression did not set.") }

        songEngine.setIsRepeat(as: true)
        songEngine.setBPM(as: 90)
        songEngine.setKeyAndDiatonicProgression(key: key, diatonicProgression: progression)
        songEngine.play()
    }
    
    @IBAction func stopButtonClicked(_ sender: UIButton) {
        songEngine.reset()
    }
    
    
    func noteOn(note: MIDINoteNumber) {
        songEngine.play(note: note)
    }
    
    func noteOff(note: MIDINoteNumber) {
        songEngine.stop(note: note)
    }
}
