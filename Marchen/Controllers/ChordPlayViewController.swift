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
    
    var selectedChordProgression: [Diatonic]?
    var selectedKey: Key?
    
    
    let waveform = AKTable(AKTableType.triangle)
    
    var oscillatorArray: [AKOscillator] = []
    
    var currentAmplitude = 1.0
    var currentRampDuration = 0.0
    
    var bpm = 120
    
    func bpmToBarPlaySec (bpm: Int)  -> Double {
        return Double(60) / Double(bpm) * Double(4)
    }
    
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        
        guard let chordProgression = selectedChordProgression  else { fatalError("Error initializing Chord") }
        guard let key = selectedKey else { fatalError("Error initializing Key") }
        
        let barPlaySec = bpmToBarPlaySec(bpm: bpm)
        
        let estimatedPlayTime = barPlaySec * chordProgression.count
        
        for (idx, diatonic) in chordProgression.enumerated() {
            let chord = Utils.getChordNotesToPlay(key: key, diatonic: diatonic)
            Timer.scheduledTimer(withTimeInterval: barPlaySec * idx, repeats: false) { (timerObj) in
                for (idx, note) in chord.enumerated() {
                    self.playNoteSound(oscillator: self.oscillatorArray[idx], note: MIDINoteNumber(note))
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: estimatedPlayTime, repeats: false) { (timerObj) in
            for osc in self.oscillatorArray {
                    osc.amplitude = 0
                }
        }
        
        
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
        for osc in oscillatorArray {
            osc.amplitude = 0
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let oscillatorA = AKOscillator(waveform: waveform)
        oscillatorArray.append(oscillatorA)
        
        
        let oscillatorB = AKOscillator(waveform: waveform)
        oscillatorArray.append(oscillatorB)
        
        
        let oscillatorC = AKOscillator(waveform: waveform)
        oscillatorArray.append(oscillatorC)
        
        
        let mixer = AKMixer(oscillatorA, oscillatorB, oscillatorC)
        let booster = AKBooster(mixer)
        AudioKit.output = booster
        
        try! AudioKit.start()
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        try! AudioKit.stop()
    }
    
}
