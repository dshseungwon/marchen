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

class ChordPlayViewController: UIViewController, AKKeyboardDelegate {
    
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
        let keyboardView = AKKeyboardView()
        keyboardView.delegate = self
        
        stackView.addArrangedSubview(keyboardView)
        
//        keyboardView.widthAnchor.constraint(equalToConstant: stackView.frame.width).isActive = true
//        keyboardView.heightAnchor.constraint(equalToConstant: stackView.frame.height).isActive = true
//
//        keyboardView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
//        keyboardView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        guard let key = selectedKey else { fatalError("Key did not set.") }
        guard let progression = selectedDiatonicProgression else { fatalError("Progression did not set.") }

        songEngine.setIsRepeat(as: true)
        songEngine.setBPM(as: 240)
        songEngine.setKeyAndDiatonicProgression(key: key, diatonicProgression: progression)
        songEngine.play()
    }
    
    @IBAction func stopButtonClicked(_ sender: UIButton) {
        songEngine.reset()
    }
    
    
    func noteOn(note: MIDINoteNumber) {
        
    }
    
    func noteOff(note: MIDINoteNumber) {
        
    }
}
