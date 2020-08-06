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
    
    func attachObserver(_ observer: Observer) {
        observers.append(observer)
    }
    
    func notify() {
        for observer in observers {
            observer.update(isStopPublished)
        }
    }
    
    // From the Previous VC
    var diatonicProgression: [Diatonic]? // e.g. [I, V, VI, IV]
    var key: Key? // e.g. Key.C
    
    //MARK: - INIT METHODS
    init() {
        
        do {
            let C3File = try AKAudioFile(readFileName: "C3.wav")
            let Db3File = try AKAudioFile(readFileName: "Db3.wav")
            let D3File = try AKAudioFile(readFileName: "D3.wav")
            let Eb3File = try AKAudioFile(readFileName: "Eb3.wav")
            let E3File = try AKAudioFile(readFileName: "E3.wav")
            let F3File = try AKAudioFile(readFileName: "F3.wav")
            let Gb3File = try AKAudioFile(readFileName: "Gb3.wav")
            let G3File = try AKAudioFile(readFileName: "G3.wav")
            let Ab3File = try AKAudioFile(readFileName: "Ab3.wav")
            let A3File = try AKAudioFile(readFileName: "A3.wav")
            let Bb3File = try AKAudioFile(readFileName: "Bb3.wav")
            let B3File = try AKAudioFile(readFileName: "B3.wav")
            let C4File = try AKAudioFile(readFileName: "C4.wav")
            
            let C3 = AKPlayer(audioFile: C3File)
            C3.isLooping = false
            C3.buffering = .always
            let Db3 = AKPlayer(audioFile: Db3File)
            Db3.isLooping = false
            Db3.buffering = .always
            let D3 = AKPlayer(audioFile: D3File)
            D3.isLooping = false
            D3.buffering = .always
            let Eb3 = AKPlayer(audioFile: Eb3File)
            Eb3.isLooping = false
            Eb3.buffering = .always
            let E3 = AKPlayer(audioFile: E3File)
            E3.isLooping = false
            E3.buffering = .always
            let F3 = AKPlayer(audioFile: F3File)
            F3.isLooping = false
            F3.buffering = .always
            let Gb3 = AKPlayer(audioFile: Gb3File)
            Gb3.isLooping = false
            Gb3.buffering = .always
            let G3 =  AKPlayer(audioFile: G3File)
            G3.isLooping = false
            G3.buffering = .always
            let Ab3 =  AKPlayer(audioFile: Ab3File)
            Ab3.isLooping = false
            Ab3.buffering = .always
            let A3 =  AKPlayer(audioFile: A3File)
            A3.isLooping = false
            A3.buffering = .always
            let Bb3 =  AKPlayer(audioFile: Bb3File)
            Bb3.isLooping = false
            Bb3.buffering = .always
            let B3 =  AKPlayer(audioFile: B3File)
            B3.isLooping = false
            B3.buffering = .always
            let C4 =  AKPlayer(audioFile: C4File)
            C4.isLooping = false
            C4.buffering = .always
            
            notePlayerDictionary.updateValue(C3, forKey: 48)
            notePlayerDictionary.updateValue(Db3, forKey: 49)
            notePlayerDictionary.updateValue(D3, forKey: 50)
            notePlayerDictionary.updateValue(Eb3, forKey: 51)
            notePlayerDictionary.updateValue(E3, forKey: 52)
            notePlayerDictionary.updateValue(F3, forKey: 53)
            notePlayerDictionary.updateValue(Gb3, forKey: 54)
            notePlayerDictionary.updateValue(G3, forKey: 55)
            notePlayerDictionary.updateValue(Ab3, forKey: 56)
            notePlayerDictionary.updateValue(A3, forKey: 57)
            notePlayerDictionary.updateValue(Bb3, forKey: 58)
            notePlayerDictionary.updateValue(B3, forKey: 59)
            notePlayerDictionary.updateValue(C4, forKey: 60)
            
            
            let mixer = AKMixer(C3, Db3, D3, Eb3, E3, F3, Gb3, G3, Ab3, A3, Bb3, B3, C4)
            let booster = AKBooster(mixer)
            
            if AudioKit.engine.isRunning {
                invalidate()
            }
            
            AudioKit.output = booster
            try! AudioKit.start()
            
            
        } catch {
            fatalError(error.localizedDescription)
        }

    }
    
    
    private var notePlayerDictionary: [MIDINoteNumber: AKPlayer] = [:]
    private var currentAmplitude = 1.0
    private var currentRampDuration = 0.0
    
    
    // Variables about song information
    private var bpm = 120
    private var barPlayTime: Double {
        return Double(60) / Double(bpm) * Double(4)
    }
    private var progressionRepeats = 2
    
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
    
    //    private var isMute = false
    private var isStop = true
    
    private var autoResetTickWhenStop = false
    
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
    
    func setAutoResetTickWhenStop(as bool: Bool) {
        self.autoResetTickWhenStop = bool
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
    
    private func stopPlaying() {
        isStopPublished = true
        
        notePlayerDictionary.forEach { $1.stop() }

    }
    
    private func playCurrentDiatonic() {
        if isAvailable() {
            let currentChordNotes = Utils.getChordNotesToPlay(key: key!, diatonic: currentDiatonic)
            
            for note in currentChordNotes {
                let player = self.notePlayerDictionary[MIDINoteNumber(note)]
                
                player?.volume = currentAmplitude
                player?.play()
                
            }
        }
    }
    
}

//    private func playNoteSound(oscillator: AKOscillator, note: MIDINoteNumber) {
//        // start from the correct note if amplitude is zero
//        if oscillator.amplitude == 0 {
//            oscillator.rampDuration = 0
//        }
//        oscillator.frequency = note.midiNoteToFrequency()
//
//        // Still use rampDuration for volume
//        oscillator.rampDuration = currentRampDuration
//        oscillator.amplitude = currentAmplitude
//        oscillator.play()
//    }

//            notePlayerDictionary.updateValue(C3, forKey: "C3")
//            notePlayerDictionary.updateValue(Db3, forKey: "Db3")
//            notePlayerDictionary.updateValue(D3, forKey: "D3")
//            notePlayerDictionary.updateValue(Eb3, forKey: "Eb3")
//            notePlayerDictionary.updateValue(E3, forKey: "E3")
//            notePlayerDictionary.updateValue(F3, forKey: "F3")
//            notePlayerDictionary.updateValue(Gb3, forKey: "Gb3")
//            notePlayerDictionary.updateValue(G3, forKey: "G3")
//            notePlayerDictionary.updateValue(Ab3, forKey: "Ab3")
//            notePlayerDictionary.updateValue(A3, forKey: "A3")
//            notePlayerDictionary.updateValue(Bb3, forKey: "Bb3")
//            notePlayerDictionary.updateValue(B3, forKey: "B3")
//            notePlayerDictionary.updateValue(C4, forKey: "C4")
