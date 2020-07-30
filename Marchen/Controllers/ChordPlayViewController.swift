//
//  ChordPlayViewController.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/30.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit
import AudioKit

class ChordPlayViewController: UIViewController {
    
    
    let waveform = AKTable(.triangle) // .triangle, etc.
    
    var oscillatorA : AKOscillator?
    var oscillatorB : AKOscillator?
    var oscillatorC : AKOscillator?
    
    var currentAmplitude = 1.0
    var currentRampDuration = 0.0
    
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        let noteA : MIDINoteNumber = 48
        let noteB : MIDINoteNumber = 52
        let noteC : MIDINoteNumber = 55
        
        guard let oscltrA = oscillatorA else { fatalError() }
        guard let oscltrB = oscillatorB else { fatalError() }
        guard let oscltrC = oscillatorC else { fatalError() }
        
        playNoteSound(oscillator: oscltrA, note: noteA)
        playNoteSound(oscillator: oscltrB, note: noteB)
        playNoteSound(oscillator: oscltrC, note: noteC)
        
    }
    
    func playNoteSound(oscillator: AKOscillator, note: MIDINoteNumber) {
        // start from the correct note if amplitude is zero
        if oscillator.amplitude == 0 {
            oscillator.rampDuration = 0
        }
        oscillator.frequency = note.midiNoteToFrequency()
        
        // Still use rampDuration for volume
        oscillator.rampDuration = currentRampDuration
        oscillator.amplitude = currentAmplitude
        oscillator.play()
    }
    
    @IBAction func stopButtonClicked(_ sender: UIButton) {
        guard let oscltrA = oscillatorA else { fatalError() }
        guard let oscltrB = oscillatorB else { fatalError() }
        guard let oscltrC = oscillatorC else { fatalError() }
        
        oscltrA.amplitude = 0
        oscltrB.amplitude = 0
        oscltrC.amplitude = 0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oscillatorA = AKOscillator(waveform: waveform)
        oscillatorB = AKOscillator(waveform: waveform)
        oscillatorC = AKOscillator(waveform: waveform)

        
        let mixer = AKMixer(oscillatorA, oscillatorB, oscillatorC)
        let booster = AKBooster(mixer)
        AudioKit.output = booster
        
        try! AudioKit.start()
        
        
    }
    
}
