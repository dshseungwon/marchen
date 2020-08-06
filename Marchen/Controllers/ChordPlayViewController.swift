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
    
    func noteOn(note: MIDINoteNumber) {
        
    }
    
    func noteOff(note: MIDINoteNumber) {
        
    }
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var stackView: UIStackView!
    
    // From the Previous VC
    var selectedChordProgression: [Diatonic]? // e.g. [I, V, VI, IV]
    
    var selectedKey: Key? // e.g. Key.C
    
//
//    var currentProgress: Float {
//         return Float(self.currentTick / self.songPlayTime)
//     }
//    self.progressView.setProgress(self.currentProgress, animated: true)
    
    func setupUI() {
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let keyboardView = AKKeyboardView()
        keyboardView.delegate = self
        
        stackView.addArrangedSubview(keyboardView)

        view.addSubview(stackView)

        stackView.widthAnchor.constraint(equalToConstant: stackView.frame.width).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: stackView.frame.height).isActive = true

        stackView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func stopButtonClicked(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
}
