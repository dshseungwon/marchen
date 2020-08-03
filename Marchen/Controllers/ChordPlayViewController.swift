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
    
    
    @IBOutlet weak var progressView: UIProgressView!
    
    
    // From the Previous VC
    var selectedChordProgression: [Diatonic]? {  // e.g. [I, V, VI, IV]
        didSet {
            composeSong()
        }
    }
    
    var selectedKey: Key? // e.g. Key.C
    
    
    // To initialize Oscillator
    let waveform = AKTable(AKTableType.triangle)
    var oscillatorArray: [AKOscillator] = []
    var currentAmplitude = 1.0
    var currentRampDuration = 0.0
    
    
    // Variables about song information
    var bpm = 120
    var barPlayTime: Double {
        return Double(60) / Double(bpm) * Double(4)
    }
    var progressionRepeats = 1
    
    var songPlayTime: Double {
        return barPlayTime * progressionRepeats * 4
    }
    
    var songDiatonics: [(Diatonic, Double, Double, Int)] = []
    
    // To control playing flow
    var currentTick: Double = 0.0
    var currentDiatonic: Diatonic!
    
    var tickTimer: Timer?
    
    var currentProgress: Float {
        return Float(self.currentTick / self.songPlayTime)
    }
    var currentChordIndex = -1
    
    var isMute = false
    var isStop = true
    
    
    func composeSong() {
        var startTime: Double = 0.0
        // Force-unwrap is actually safe.
        let chordProgression = selectedChordProgression!
        
        var chordIndex = 0
        
        for diatonic in chordProgression {
            let endTime = startTime+barPlayTime
            songDiatonics.append((diatonic, startTime, endTime, chordIndex))
            startTime = endTime
            chordIndex += 1
        }
        
        currentDiatonic = chordProgression[0]
    }
    
    
    func getDiatonicOfCurrentTick() -> Diatonic? {
        for diatonicInfo in songDiatonics {
            if diatonicInfo.1 <= currentTick && currentTick < diatonicInfo.2 {
                return diatonicInfo.0
            }
        }
        return nil
    }
    
    func getChordIndexOfCurrentTick() -> Int {
        for diatonicInfo in songDiatonics {
            if diatonicInfo.1 <= currentTick && currentTick < diatonicInfo.2 {
                return diatonicInfo.3
            }
        }
        return -1
    }

    
    func updateTick() {
        if tickTimer == nil {
            tickTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timerObj) in
                self.currentTick += 0.01
                
                self.progressView.setProgress(self.currentProgress, animated: true)
                
                if self.currentTick >= self.songPlayTime {
                    self.resetTick()
                    return
                }
                
                let chordIndexOfCurrentTick = self.getChordIndexOfCurrentTick()
                let diatonicOfCurrentTick = self.getDiatonicOfCurrentTick()
                
                if self.isStop || chordIndexOfCurrentTick != self.currentChordIndex {
                    self.currentChordIndex = chordIndexOfCurrentTick
                    self.currentDiatonic = diatonicOfCurrentTick
                    self.isStop = false
                    
                    if !self.isMute {
                        self.playCurrentDiatonic()
                    }
                }
            }
        } else {
            print("Timer already exists.")
        }
    }
    
    func stopTick() {
        tickTimer?.invalidate()
        tickTimer = nil
        
        stopPlaying()
    }
    
    func resetTick() {
        tickTimer?.invalidate()
        tickTimer = nil
        
        currentTick = 0.0
        progressView.setProgress(currentProgress, animated: false)
        stopPlaying()
    }
    
    func stopPlaying() {
        isStop = true
        
        for osc in oscillatorArray {
            osc.stop()
        }
    }
    
    func playCurrentDiatonic() {
        guard let key = selectedKey else { fatalError("Error initializing Key") }
        
        let currentChordNotes = Utils.getChordNotesToPlay(key: key, diatonic: currentDiatonic)
        
        for (idx, note) in currentChordNotes.enumerated() {
            self.playNoteSound(oscillator: self.oscillatorArray[idx], note: MIDINoteNumber(note))
        }
        
    }
    
    @IBAction func playButtonClicked(_ sender: UIButton) {
        updateTick()
    }
    
    @IBAction func stopButtonClicked(_ sender: UIButton) {
        stopTick()
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


//        let estimatedPlayTime = barPlaySec * chordProgression.count
  //        playingIndex = 0
  //        isStop = false
  
  
  //        if (self.playingIndex < chordProgression.count) {
  //            let currentDiatonic = chordProgression[playingIndex]
  //            let currentChord = Utils.getChordNotesToPlay(key: key, diatonic: currentDiatonic)
  //
  //            self.playTriadChord(chord: currentChord)
  //
  //            if (self.playingIndex >= chordProgression.count) {
  //                self.playingIndex = 0
  //                self.isStop = true
  //                return
  //            }
  //
  //            Timer.scheduledTimer(withTimeInterval: barPlaySec, repeats: true) { (timerObj) in
  //                // Should notified that isStop value changed and call timerObj.invalidate.
  //                if (self.isStop) {
  //                    timerObj.invalidate()
  //                }
  //
  //                let currentDiatonic = chordProgression[self.playingIndex]
  //                let currentChord = Utils.getChordNotesToPlay(key: key, diatonic: currentDiatonic)
  //                self.playTriadChord(chord: currentChord)
  //
  //                if (self.playingIndex >= chordProgression.count) {
  //                    timerObj.invalidate()
  //                    Timer.scheduledTimer(withTimeInterval: barPlaySec, repeats: false) { (timer) in
  //                        for osc in self.oscillatorArray {
  //                            osc.amplitude = 0
  //                        }
  //                        self.playingIndex = 0
  //                        self.isStop = true
  //                    }
  //                }
  //            }
  //        }
  
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
