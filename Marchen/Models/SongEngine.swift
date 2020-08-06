//
//  SongEngine.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/08/03.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit
import AudioKit

protocol Observer {
    func update(_ notifyValue: Bool)
}

class SongEngine {
    
    var diatonicProgression: [Diatonic]? // e.g. [I, V, VI, IV]
    var key: Key? // e.g. Key.C
    
    //MARK: - INIT METHODS
    init() {
        
        let filteredSampler = AKLowPassFilter(sampler)
        filteredSampler.cutoffFrequency = 2000 // B6 = 1975.5Hz, C7 = 2093.0
        filteredSampler.resonance = 0 // dB

        let mixer = AKMixer(filteredSampler)
        let booster = AKBooster(mixer)
        
        if AudioKit.engine.isRunning {
            invalidate()
        }
        
        AudioKit.output = booster
        try! AudioKit.start()
        
        setupSampler()
        
    }
    
    private func setupSampler() {
        let soundsFolder = Bundle.main.bundleURL.appendingPathComponent("Sounds/sfz").path
        sampler.unloadAllSamples()
        sampler.loadSFZ(path: soundsFolder, fileName: "Piano.sfz")
        sampler.masterVolume = currentVolume
        
        sampler.attackDuration = 0.01
        sampler.decayDuration = 0.1
        sampler.sustainLevel = 0.8
        sampler.releaseDuration = 0.5
    }
    
    // Variables for Observer Pattern
    private var observers: [Observer] = [Observer]()
    var isStopPublished: Bool {
        set {
            isStop = newValue
            notify()
        }
        get {
            return isStop
        }
    }
    
    // Variables for Initialize AudioKit
    private var sampler = AKSampler()
    private var midiChannelIn: MIDIChannel = 0
    private var currentVolume = 1.0
    
    // Variables about Song Information
    private var bpm = 120
    private var barPlayTime: Double {
        return Double(60) / Double(bpm) * Double(4)
    }
    private var progressionRepeats = 2
    
    private var songPlayTime: Double {
        if let progression = diatonicProgression {
            return barPlayTime * progressionRepeats * progression.count
        } else {
            return Double(0)
        }
    }
    
    private var songDiatonics: [(Diatonic, Double, Double, Int)] = []
    
    
    // Varaibles to Control the Flow of Playing
    private var currentTick: Double = 0.0
    private var currentDiatonic: Diatonic!
    
    private var tickTimer: Timer?
    
    private var currentProgress: Float {
        return Float(self.currentTick / self.songPlayTime)
    }
    private var currentChordIndex = -1
    
    private var isStop = true
    
    private var autoResetTickWhenStop = false
    
    private var isRepeat = false
    
    //MARK: - Internal Methods.
    func setBPM(as bpm: Int) {
        self.bpm = bpm
    }
    
    func getBPM() -> Int {
        return self.bpm
    }
    
    func setIsRepeat(as bool: Bool) {
        self.isRepeat = bool
    }
    
    func getIsRepeat() -> Bool {
        return self.isRepeat
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
    
    func setAutoResetTickWhenStop(as bool: Bool) {
        self.autoResetTickWhenStop = bool
    }
    
    func play() {
        if(isAvailable()) {
            updateTick()
        }
    }
    
    func stop() {
        if autoResetTickWhenStop {
            resetTick()
        } else {
            stopTick()
        }
    }
    
    func reset() {
        resetTick()
    }
    
    func invalidate() {
        if AudioKit.engine.isRunning {
            try! AudioKit.stop()
            print("STOP")
        }
    }
    
    //MARK: - Private Methods
    private func isAvailable() -> Bool {
        if key == nil || diatonicProgression == nil {
            return false
        } else {
            return true
        }
    }
    
    private func composeSong() {
        if isAvailable() {
            songDiatonics = []
            guard let progression =  diatonicProgression else { fatalError("diatonicProgression not set") }
            var startTime: Double = 0.0
            var chordIndex = 0
            for _ in 0 ..< progressionRepeats {
                for diatonic in progression {
                    let endTime = startTime + barPlayTime
                    songDiatonics.append((diatonic, startTime, endTime, chordIndex))
                    startTime = endTime
                    chordIndex += 1
                }
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
                    // Song has finished.
                    // Should notify in here.
                    self.resetTick()
                    if self.isRepeat {
                        self.updateTick()
                    }
                    return
                }
                
                let chordIndexOfCurrentTick = self.getChordIndexOfCurrentTick()
                let diatonicOfCurrentTick = self.getDiatonicOfCurrentTick()
                
                if self.isStop || chordIndexOfCurrentTick != self.currentChordIndex {
                    self.currentChordIndex = chordIndexOfCurrentTick
                    self.currentDiatonic = diatonicOfCurrentTick
                    self.isStop = false
                    
                    self.playCurrentDiatonic()
                    
                }
            }
        } else {
            print("Timer already exists.")
            resetTick()
            updateTick()
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
        
        stopPlaying()
        currentTick = 0.0
    }
    
    func playNote(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        sampler.play(noteNumber: note, velocity: velocity)
    }
    
    func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
        sampler.stop(noteNumber: note)
    }
    
    func allNotesOff() {
        for note in 0 ... 127 {
            sampler.stop(noteNumber: MIDINoteNumber(note))
        }
    }
    
    private func stopPlaying() {
        isStopPublished = true
        
        allNotesOff()
    }
    
    private func playCurrentDiatonic() {
        if isAvailable() {
            let currentChordNotes = Utils.getChordNotesToPlay(key: key!, diatonic: currentDiatonic)
            
            // Stop the playing notes before play the diatonic chord.
            allNotesOff()
            
            for note in currentChordNotes {
                playNote(note: MIDINoteNumber(note), velocity: 127, channel: midiChannelIn)
            }
        }
    }
    
}

extension SongEngine {
    // Methods for Observer pattern
    func attachObserver(_ observer: Observer) {
        observers.append(observer)
    }
    
    func notify() {
        for observer in observers {
            observer.update(isStopPublished)
        }
    }
}
