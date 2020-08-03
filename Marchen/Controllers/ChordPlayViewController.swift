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
    
    var isStop = true
    var DoesStopNext = false
    
    
    let waveform = AKTable(AKTableType.triangle)
    
    var oscillatorArray: [AKOscillator] = []
    
    var currentAmplitude = 1.0
    var currentRampDuration = 0.0
    
    var bpm = 120
    var playingIndex = 0
    
    func bpmToBarPlaySec (bpm: Int)  -> Double {
        return Double(60) / Double(bpm) * Double(4)
    }
    
    func playTriadChord(chord: [Int]) {
        print(self.playingIndex)
        if(!isStop) {
            for (idx, note) in chord.enumerated() {
                self.playNoteSound(oscillator: self.oscillatorArray[idx], note: MIDINoteNumber(note))
            }
            self.playingIndex += 1
        }
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        
        guard let chordProgression = selectedChordProgression  else { fatalError("Error initializing Chord") }
        guard let key = selectedKey else { fatalError("Error initializing Key") }
        
        let barPlaySec = bpmToBarPlaySec(bpm: bpm)
        
//        let estimatedPlayTime = barPlaySec * chordProgression.count
        playingIndex = 0
        isStop = false
        
        
        if (self.playingIndex < chordProgression.count) {
            let currentDiatonic = chordProgression[playingIndex]
            let currentChord = Utils.getChordNotesToPlay(key: key, diatonic: currentDiatonic)
            
            self.playTriadChord(chord: currentChord)
            
            if (self.playingIndex >= chordProgression.count) {
                self.playingIndex = 0
                self.isStop = true
                return
            }
            
            Timer.scheduledTimer(withTimeInterval: barPlaySec, repeats: true) { (timerObj) in
                // Should notified that isStop value changed and call timerObj.invalidate.
                if (self.isStop) {
                    timerObj.invalidate()
                }
                
                let currentDiatonic = chordProgression[self.playingIndex]
                let currentChord = Utils.getChordNotesToPlay(key: key, diatonic: currentDiatonic)
                self.playTriadChord(chord: currentChord)
                
                if (self.playingIndex >= chordProgression.count) {
                    timerObj.invalidate()
                    Timer.scheduledTimer(withTimeInterval: barPlaySec, repeats: false) { (timer) in
                        for osc in self.oscillatorArray {
                            osc.amplitude = 0
                        }
                        self.playingIndex = 0
                        self.isStop = true
                    }
                }
            }
        }
        
        //        for (idx, diatonic) in chordProgression.enumerated() {
        //            let chord = Utils.getChordNotesToPlay(key: key, diatonic: diatonic)
        //            Timer.scheduledTimer(withTimeInterval: barPlaySec * idx, repeats: false) { (timerObj) in
        //                for (idx, note) in chord.enumerated() {
        //                    if (self.isStop == false) {
        //                        self.playNoteSound(oscillator: self.oscillatorArray[idx], note: MIDINoteNumber(note))
        //                    }
        //                }
        //            }
        //        }
        //
        //        Timer.scheduledTimer(withTimeInterval: estimatedPlayTime, repeats: false) { (timerObj) in
        //            for osc in self.oscillatorArray {
        //                osc.amplitude = 0
        //
        //            }
        //        }
        
        
    }
    
    func anotherPlayButtonClicked() {
        /*
        moves 'tick'
        when tick hits the another chord, changes osciliator information
        update Tick using the timer. (+0.01 sec)
         
         Chord arrangement
         0(startTime) ..< 2(endTime) C(chordName)
         2 ..< 4 G
         4 ..< 6 AM
         6 ..< 8 F
         
         >> List of tuples
         [(String, startTime, endTime)]
         
         
         Boundary check function
         getChord(currentTime) = C
         
         getChord(currentTime: Double) -> String? {
             for chordInfo in songChords {
                if chordInfo.1 <= currentTime && currentTime < chordInfo.2 {
                    return chordInfo.0
                }
             }
             return nil
         }
         
         How to check
        currentPlayingChord != current
        when timer update... getChord(currentTime)
         if getChord(currentTime) != currentChord {
            do something...
            currentChord = getChord(currentTime)
         }
        
         
        */
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
        isStop = true
        
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
