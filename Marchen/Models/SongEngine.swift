//
//  SongEngine.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/08/03.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit
import AudioKit

class SongEngine {
    
    // From the Previous VC
    var diatonicProgression: [Diatonic]? // e.g. [I, V, VI, IV]
    var key: Key? // e.g. Key.C
    
    //MARK: - INIT METHODS
    init() {
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
    
    
    // To initialize Oscillator
    private let waveform = AKTable(AKTableType.triangle)
    private var oscillatorArray: [AKOscillator] = []
    private var currentAmplitude = 1.0
    private var currentRampDuration = 0.0
    
    
    // Variables about song information
    private var bpm = 120
    private var barPlayTime: Double {
        return Double(60) / Double(bpm) * Double(4)
    }
    private var progressionRepeats = 1
    
    private var songPlayTime: Double {  // Assume that the Chord Progression ONLY consists of 4 chords.
        return barPlayTime * progressionRepeats * 4
    }
    
    private var songDiatonics: [(Diatonic, Double, Double, Int)] = []
    
    
    // To control playing flow
    private var currentTick: Double = 0.0
    private var currentDiatonic: Diatonic!
    
    private var tickTimer: Timer?
    
    private var currentProgress: Float {
        return Float(self.currentTick / self.songPlayTime)
    }
    private var currentChordIndex = -1
    
    private var isMute = false
    private var isStop = true
    
    
    //MARK: - Internal Methods.
    func setBPM(as bpm: Int) {
        self.bpm = bpm
    }
    
    func getBPM() -> Int {
        return bpm
    }
    
    func setProgressionRepeats(as times: Int) {
        self.progressionRepeats = times
    }
    
    func getProgressionRepeats() -> Int {
        return progressionRepeats
    }
    
    func setKeyAndDiatonicProgression(key: Key, diatonicProgression: [Diatonic]) {
        self.key = key
        self.diatonicProgression = diatonicProgression
        composeSong()
    }
    
// Needs further implementation.
//    func mute() {
//        isMute = true
//    }
    
    func play() {
        if(isAvailable()) {
            updateTick()
        }
    }
    
    func stop() {
        stopTick()
    }
    
    func invalidate() {
        try! AudioKit.stop()
    }
    
    private func isAvailable() -> Bool {
        if key == nil || diatonicProgression == nil {
            return false
        } else {
            return true
        }
    }
    
    private func composeSong() {
        if isAvailable() {
            guard let progression =  diatonicProgression else { fatalError("diatonicProgression not set") }
            var startTime: Double = 0.0
            var chordIndex = 0
            for diatonic in progression {
                let endTime = startTime+barPlayTime
                songDiatonics.append((diatonic, startTime, endTime, chordIndex))
                startTime = endTime
                chordIndex += 1
            }
            
            currentDiatonic = progression[0]
        }
    }
    
    
    private func getDiatonicOfCurrentTick() -> Diatonic? {
        for diatonicInfo in songDiatonics {
            if diatonicInfo.1 <= currentTick && currentTick < diatonicInfo.2 {
                return diatonicInfo.0
            }
        }
        return nil
    }
    
    private func getChordIndexOfCurrentTick() -> Int {
        for diatonicInfo in songDiatonics {
            if diatonicInfo.1 <= currentTick && currentTick < diatonicInfo.2 {
                return diatonicInfo.3
            }
        }
        return -1
    }
    
    
    private func updateTick() {
        if tickTimer == nil {
            tickTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timerObj) in
                self.currentTick += 0.01
                
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
    
    private func stopTick() {
        tickTimer?.invalidate()
        tickTimer = nil
        
        stopPlaying()
    }
    
    private func resetTick() {
        tickTimer?.invalidate()
        tickTimer = nil
        
        currentTick = 0.0
        stopPlaying()
    }
    
    private func stopPlaying() {
        isStop = true
        
        for osc in oscillatorArray {
            osc.stop()
        }
    }
    
    private func playCurrentDiatonic() {
        if isAvailable() {
            let currentChordNotes = Utils.getChordNotesToPlay(key: key!, diatonic: currentDiatonic)
            
            for (idx, note) in currentChordNotes.enumerated() {
                self.playNoteSound(oscillator: self.oscillatorArray[idx], note: MIDINoteNumber(note))
            }
        }
    }
    
    private func playNoteSound(oscillator: AKOscillator, note: MIDINoteNumber) {
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
    
}
