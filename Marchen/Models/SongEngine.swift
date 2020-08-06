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
    
    // From the Previous VC
    var diatonicProgression: [Diatonic]? // e.g. [I, V, VI, IV]
    var key: Key? // e.g. Key.C
    
    //MARK: - INIT METHODS
    init() {
        
            let mixer = AKMixer(sampler)
            let booster = AKBooster(mixer)
            
            if AudioKit.engine.isRunning {
                invalidate()
            }
            
            AudioKit.output = booster
            try! AudioKit.start()
        
            let soundsFolder = Bundle.main.bundleURL.appendingPathComponent("Sounds/sfz").path
            sampler.unloadAllSamples()
            sampler.loadSFZ(path: soundsFolder, fileName: "Piano.sfz")
        sampler.masterVolume = currentVolume
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
    
    private var songPlayTime: Double {  // Assume that the Chord Progression ONLY consists of 4 chords.
        return barPlayTime * progressionRepeats * 4
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

//            let C3File = try AKAudioFile(readFileName: "C3.wav")
//            let Db3File = try AKAudioFile(readFileName: "Db3.wav")
//            let D3File = try AKAudioFile(readFileName: "D3.wav")
//            let Eb3File = try AKAudioFile(readFileName: "Eb3.wav")
//            let E3File = try AKAudioFile(readFileName: "E3.wav")
//            let F3File = try AKAudioFile(readFileName: "F3.wav")
//            let Gb3File = try AKAudioFile(readFileName: "Gb3.wav")
//            let G3File = try AKAudioFile(readFileName: "G3.wav")
//            let Ab3File = try AKAudioFile(readFileName: "Ab3.wav")
//            let A3File = try AKAudioFile(readFileName: "A3.wav")
//            let Bb3File = try AKAudioFile(readFileName: "Bb3.wav")
//            let B3File = try AKAudioFile(readFileName: "B3.wav")
//            let C4File = try AKAudioFile(readFileName: "C4.wav")
//
//            let Db4File = try AKAudioFile(readFileName: "Db4.wav")
//            let D4File = try AKAudioFile(readFileName: "D4.wav")
//            let Eb4File = try AKAudioFile(readFileName: "Eb4.wav")
//            let E4File = try AKAudioFile(readFileName: "E4.wav")
//            let F4File = try AKAudioFile(readFileName: "F4.wav")
//            let Gb4File = try AKAudioFile(readFileName: "Gb4.wav")
//            let G4File = try AKAudioFile(readFileName: "G4.wav")
//            let Ab4File = try AKAudioFile(readFileName: "Ab4.wav")
//            let A4File = try AKAudioFile(readFileName: "A4.wav")
//            let Bb4File = try AKAudioFile(readFileName: "Bb4.wav")
//            let B4File = try AKAudioFile(readFileName: "B4.wav")
//            let C5File = try AKAudioFile(readFileName: "C5.wav")
            
//            let C3 = AKPlayer(audioFile: C3File)
//            C3.isLooping = false
//            C3.buffering = .always
//            let Db3 = AKPlayer(audioFile: Db3File)
//            Db3.isLooping = false
//            Db3.buffering = .always
//            let D3 = AKPlayer(audioFile: D3File)
//            D3.isLooping = false
//            D3.buffering = .always
//            let Eb3 = AKPlayer(audioFile: Eb3File)
//            Eb3.isLooping = false
//            Eb3.buffering = .always
//            let E3 = AKPlayer(audioFile: E3File)
//            E3.isLooping = false
//            E3.buffering = .always
//            let F3 = AKPlayer(audioFile: F3File)
//            F3.isLooping = false
//            F3.buffering = .always
//            let Gb3 = AKPlayer(audioFile: Gb3File)
//            Gb3.isLooping = false
//            Gb3.buffering = .always
//            let G3 =  AKPlayer(audioFile: G3File)
//            G3.isLooping = false
//            G3.buffering = .always
//            let Ab3 =  AKPlayer(audioFile: Ab3File)
//            Ab3.isLooping = false
//            Ab3.buffering = .always
//            let A3 =  AKPlayer(audioFile: A3File)
//            A3.isLooping = false
//            A3.buffering = .always
//            let Bb3 =  AKPlayer(audioFile: Bb3File)
//            Bb3.isLooping = false
//            Bb3.buffering = .always
//            let B3 =  AKPlayer(audioFile: B3File)
//            B3.isLooping = false
//            B3.buffering = .always
//            let C4 =  AKPlayer(audioFile: C4File)
//            C4.isLooping = false
//            C4.buffering = .always
//
//            let Db4 = AKPlayer(audioFile: Db4File)
//            Db4.isLooping = false
//            Db4.buffering = .always
//            let D4 = AKPlayer(audioFile: D4File)
//            D4.isLooping = false
//            D4.buffering = .always
//            let Eb4 = AKPlayer(audioFile: Eb4File)
//            Eb4.isLooping = false
//            Eb4.buffering = .always
//            let E4 = AKPlayer(audioFile: E4File)
//            E4.isLooping = false
//            E4.buffering = .always
//            let F4 = AKPlayer(audioFile: F4File)
//            F4.isLooping = false
//            F4.buffering = .always
//            let Gb4 = AKPlayer(audioFile: Gb4File)
//            Gb4.isLooping = false
//            Gb4.buffering = .always
//            let G4 =  AKPlayer(audioFile: G4File)
//            G4.isLooping = false
//            G4.buffering = .always
//            let Ab4 =  AKPlayer(audioFile: Ab4File)
//            Ab4.isLooping = false
//            Ab4.buffering = .always
//            let A4 =  AKPlayer(audioFile: A4File)
//            A4.isLooping = false
//            A4.buffering = .always
//            let Bb4 =  AKPlayer(audioFile: Bb4File)
//            Bb4.isLooping = false
//            Bb4.buffering = .always
//            let B4 =  AKPlayer(audioFile: B4File)
//            B4.isLooping = false
//            B4.buffering = .always
//            let C5 =  AKPlayer(audioFile: C5File)
//            C5.isLooping = false
//            C5.buffering = .always
            
//            notePlayerDictionary.updateValue(C3, forKey: 48)
//            notePlayerDictionary.updateValue(Db3, forKey: 49)
//            notePlayerDictionary.updateValue(D3, forKey: 50)
//            notePlayerDictionary.updateValue(Eb3, forKey: 51)
//            notePlayerDictionary.updateValue(E3, forKey: 52)
//            notePlayerDictionary.updateValue(F3, forKey: 53)
//            notePlayerDictionary.updateValue(Gb3, forKey: 54)
//            notePlayerDictionary.updateValue(G3, forKey: 55)
//            notePlayerDictionary.updateValue(Ab3, forKey: 56)
//            notePlayerDictionary.updateValue(A3, forKey: 57)
//            notePlayerDictionary.updateValue(Bb3, forKey: 58)
//            notePlayerDictionary.updateValue(B3, forKey: 59)
//            notePlayerDictionary.updateValue(C4, forKey: 60)
//
//            notePlayerDictionary.updateValue(Db4, forKey: 61)
//            notePlayerDictionary.updateValue(D4, forKey: 62)
//            notePlayerDictionary.updateValue(Eb4, forKey: 63)
//            notePlayerDictionary.updateValue(E4, forKey: 64)
//            notePlayerDictionary.updateValue(F4, forKey: 65)
//            notePlayerDictionary.updateValue(Gb4, forKey: 66)
//            notePlayerDictionary.updateValue(G4, forKey: 67)
//            notePlayerDictionary.updateValue(Ab4, forKey: 68)
//            notePlayerDictionary.updateValue(A4, forKey: 69)
//            notePlayerDictionary.updateValue(Bb4, forKey: 70)
//            notePlayerDictionary.updateValue(B4, forKey: 71)
//            notePlayerDictionary.updateValue(C5, forKey: 72)
            
