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

class ChordPlayViewController: UIViewController, MyKeyboardDelegate {
    
    @IBOutlet weak var progressView: UIProgressView!
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
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    private func setupUI() {
        let keyboardView = MyKeyboardView()
        keyboardView.delegate = self
        
        keyboardView.keyOnColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        keyboardView.polyphonicMode = true
        keyboardView.polyphonicButton = #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1)
        stackView.addArrangedSubview(keyboardView)
        
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        guard let key = selectedKey else { fatalError("Key did not set.") }
        guard let progression = selectedDiatonicProgression else { fatalError("Progression did not set.") }

        songEngine.setIsRepeat(as: true)
        songEngine.setBPM(as: 280)
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
