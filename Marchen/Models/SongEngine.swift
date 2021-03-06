//
//  SongEngine.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/08/03.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import UIKit
import AudioKit

protocol SongHasFinished {
    func update(_ notifyValue: Bool)
}

protocol ChordKeyObserver {
    func update(currentChordKeys: Set<MIDINoteNumber>)
    func updateNextChordKeys(nextChordKeys: Set<MIDINoteNumber>)
}

protocol RecordedSongHasFinished {
    func update(_ notifyValue: Bool)
}

class SongEngine {
    
    var _diatonicProgression: [Diatonic]?
    
    var diatonicProgression: [Diatonic]? { // e.g. [I, V, VI, IV]
        get {
            return _diatonicProgression
        }
        set(newValue) {
            if let diatonicArray = newValue {
                // Apply repeatsOfAChord
                var dp: [Diatonic] = []
                
                for diatonic in diatonicArray {
                    for _ in 0 ..< repeatsOfAChord {
                        dp.append(diatonic)
                    }
                }
                
                _diatonicProgression = dp
            }
        }
    }
    
    var key: Key? // e.g. Key.C
    
    //MARK: - INIT METHODS
    init(songName: String) {
        do {
            if AKManager.engine.isRunning {
                invalidate()
            }
            
            let filteredSampler = AKLowPassFilter(sampler)
            filteredSampler.cutoffFrequency = 2000 // B6 = 1975.5Hz, C7 = 2093.0
            filteredSampler.resonance = 0 // dB
            
            // Use .caf extension as default.
            // If you want to change the extension, Use AKAudioFile(forWriting:)
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat64, sampleRate: 44100, channels: 2, interleaved: true)!
            let audioFile = try AKAudioFile(writeIn: .documents, name: songName, settings: format.settings)
            
            player = try AKAudioPlayer(file: audioFile)
            let mixer = AKMixer(filteredSampler, player)
            let booster = AKBooster(mixer)
            
            recorder = try AKNodeRecorder(node: mixer, file: audioFile)
            
            AKManager.output = booster
            try AKManager.start()
            setupSampler()
        } catch {
            print("Error while initializing SongEngine: \(error)")
        }
    }
    
    convenience init() {
        self.init(songName: "tmpRecords")
    }
    
    // Variables for Observer Pattern
    private var songObservers: [SongHasFinished] = [SongHasFinished]()
    var isStopPublished: Bool {
        set {
            isStop = newValue
            notifySongHasFinished()
        }
        get {
            return isStop
        }
    }
    
    private var chordKeyObservers: [ChordKeyObserver] = [ChordKeyObserver]()
    
    private var recordedSongObservers: [RecordedSongHasFinished] = [RecordedSongHasFinished]()
    
    // Variables for Initialize AudioKit
    private var sampler = AKSampler(masterVolume: 1.0)
    private var currentSamplerSound = 0
    private var midiChannelIn: MIDIChannel = 0
    private var currentVolume = 1.0
    private var recorder: AKNodeRecorder?
    private var player: AKAudioPlayer?
    
    // Variables about Song Information
    private var bpm = 120
    private var barPlayTime: Double {
        Double(60) / Double(bpm) * Double(4)
    }
    
    /*
     repeatsOfAChord
     1 -> A B C D
     2 -> AA BB CC DD
     chordsInABar
     1 -> A B C D
     2 -> AB CD
     */
    private var repeatsOfAChord = 1
    
    private var chordsInABar = 1
    private var chordPlayTime: Double {
        barPlayTime / Double(chordsInABar)
    }
    private var progressionRepeats = 1
    
    private var songPlayTime: Double {
        if let progression = _diatonicProgression {
            return chordPlayTime * Double(progressionRepeats) * Double(progression.count)
        } else {
            return Double(0)
        }
    }
    
    // DATA STURCTURE FOR COMPOSED SONG
    // $.0: Diatonic -> Diatonic
    // $.1: Double -> Start time
    // $.2: Double -> End time
    // $.3: Int -> Index
    private var songDiatonics: [(Diatonic, Double, Double, Int)] = []
    
    // DATA STRUCTURE FOR SCORE (RECORDED)
    private var songMelodies: [(MIDINoteNumber, Double, Double, Int)] = []
    private var melodyNoteStartTimeDictionary: [MIDINoteNumber: Double] = [:]
    
    // Varaibles to Control the Flow of Playing
    private var currentTick: Double = 0.0
    private var currentDiatonic: Diatonic!
    
    private var tickTimer: Timer?
    private var recordingTickTimer: Timer?
    
    private var currentProgress: Float {
        return Float(self.currentTick / self.songPlayTime)
    }
    private var currentChordIndex = -1
    
    private var isStop = true
    
    private var autoResetTickWhenStop = false
    
    private var isRepeat = false
    
    private var isRecording = false
    private var recordingTick: Double = 0.0
    
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
    
    func setRepeatsOfAChord(as number: Int) {
        self.repeatsOfAChord = number
    }
    
    func getRepeatsOfAChord() -> Int {
        return repeatsOfAChord
    }
    
    func setChordsInABar(as number: Int) {
        self.chordsInABar = number
    }
    
    func getChordsInABar() -> Int {
        return chordsInABar
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
    
    func resetRecording() {
        if let rec = recorder {
            do {
                if rec.recordedDuration > 0.0 {
                    try self.recorder?.reset()
                }
            } catch {
                AKLog("Couldn't reset the recorder")
            }
        }
    }
    
    func startRecording() {
        do {
            try recorder?.record()
            isRecording = true
            updateRecordingTick()
            // Recording started, make a new score
            // Current tick + note -> register
            // 1. currentTick = self.currentTick
            // 2. note = start when play function is called, end when stop funcion is called.
            // 3. Register = newScore Datastucture
            
            // A note cannot be pressed before user stop pressing the note.
            // Not note-wise, but time-wise.
        } catch {
            AKLog("Couldn't record")
        }
    }
    
    func stopRecording() {
        recorder?.stop()
        isRecording = false
        resetRecordingTick()
    }
    
    func playRecording() {
        // Stop Recording if was recording.
        stopRecording()
        
        if let plyr = player {
            do {
                try plyr.reloadFile()
            } catch {
                AKLog("Couldn't reload file.")
            }
            if plyr.audioFile.duration > 0.0 {
                plyr.completionHandler = notifyRecordedSongHasFinished
                plyr.play()
            } else {
                print("AudioFile is empty")
            }
        } else {
            print("Nothing has recorded yet")
        }
    }
    
    func saveRecording(fileName: String, callBack: @escaping (URL?) -> ()) {
        recorder?.audioFile?.exportAsynchronously(name: fileName, baseDir: .documents, exportFormat: .caf) { (audioFile, error) in
            callBack(audioFile?.url)
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
        if AKManager.engine.isRunning {
            try! AKManager.stop()
        }
    }
    
    // Called when play melody
    func play(note: MIDINoteNumber, velocity: MIDIVelocity = 127) {
        sampler.play(noteNumber: note, velocity: velocity)
        
        // 1) When play function is called
        // 2) Insert into note-startTime dictionary
        if isRecording {
            melodyNoteStartTimeDictionary.updateValue(recordingTick, forKey: note)
        }
    }
    
    // Called when stop melody
    func stop(note: MIDINoteNumber) {
        sampler.stop(noteNumber: note)
        
        // 3) When stop function is called
        
        // 4) Pop startTime form the dictionary using the key of note
        // 5) Insert into melodies: [(note, Double < popped startTime, Double < currentTick, Int)]
        if isRecording {
            let startTimeOfTheNote = melodyNoteStartTimeDictionary[note]
            guard let startTime = startTimeOfTheNote else { fatalError("Error while getting start time of the note from dictionary") }
            songMelodies.append((note, startTime, recordingTick, songMelodies.count))
            melodyNoteStartTimeDictionary.removeValue(forKey: note)
        }
    }
    
    func changeSamplerSound() {
        currentSamplerSound += 1
        currentSamplerSound %= 5
        loadSamples(byIndex: currentSamplerSound)
    }
    
    func playIChordForNext() {
        // Make songDiatonic of next as I
        // for chord repeats. (not Now)
        let chordIndexOfCurrentTick = self.getChordIndexOfCurrentTick()
        
        // SET NEXT DIATONIC
        var nextDiatonic: Diatonic?
        
        /// check whether is is the last diatonic of the song
        if chordIndexOfCurrentTick + 1 < self.songDiatonics.count {
            self.songDiatonics[chordIndexOfCurrentTick + 1].0 = Diatonic.I
            nextDiatonic = self.songDiatonics[chordIndexOfCurrentTick + 1].0
        } else {
            self.songDiatonics[0].0 = Diatonic.I
            nextDiatonic = self.songDiatonics[0].0
        }
        
        // Notify next chord to play, which is I
        if let nextTickDiatonic = nextDiatonic {
            let nextChordNotes = Utils.getChordNotesToPlay(key: self.key!, diatonic: nextTickDiatonic)
            
            // GET NEXT DIATONIC AND MAKE A SET
            var nextChordKeys = Set<MIDINoteNumber>()
            
            for note in nextChordNotes {
                nextChordKeys.insert(MIDINoteNumber(note))
            }
            
            self.showNextChordKeys(nextChordKeys: nextChordKeys)
        }
    }
    
    //MARK: - Private Methods
    private func setupSampler() {
        loadSamples(byIndex: currentSamplerSound)
        sampler.masterVolume = currentVolume
        
        sampler.attackDuration = 0
        sampler.decayDuration = 0
        sampler.sustainLevel = 1
        sampler.releaseDuration = 2
        
//        Previous Sampler Settings
//        sampler.attackDuration = 0.01
//        sampler.decayDuration = 0.1
//        sampler.sustainLevel = 0.8
//        sampler.releaseDuration = 0.5
    }
    
    private func loadSamples(byIndex: Int) {
        if byIndex < 0 || byIndex > 4 { return }
        
        sampler.stopAllVoices()
        sampler.unloadAllSamples()
        
        let soundsFolder = Bundle.main.bundleURL.appendingPathComponent("Sounds/sfz").path
        let sfzFiles = ["Piano.sfz", "TX Brass.sfz", "TX LoTine81z.sfz", "TX Metalimba.sfz", "TX Pluck Bass.sfz"]
        sampler.loadSFZ(path: soundsFolder, fileName: sfzFiles[byIndex])
    }
    
    private func isAvailable() -> Bool {
        if key == nil || _diatonicProgression == nil {
            return false
        } else {
            return true
        }
    }
    
    private func composeSong() {
        if isAvailable() {
            songDiatonics = []
            guard let progression =  _diatonicProgression else { fatalError("diatonicProgression not set") }
            
            var startTime: Double = 0.0
            var chordIndex = 0
            for _ in 0 ..< progressionRepeats {
                for diatonic in progression {
                    let endTime = startTime + chordPlayTime
                    songDiatonics.append((diatonic, startTime, endTime, chordIndex))
                    startTime = endTime
                    chordIndex += 1
                }
            }
            currentDiatonic = progression[0]
        }
    }
    
    private func getChordIndexOfCurrentTick() -> Int {
        for diatonicInfo in songDiatonics {
            if diatonicInfo.1 <= currentTick && currentTick < diatonicInfo.2 {
                return diatonicInfo.3
            }
        }
        return -1
    }
    
    private func checkWhetherToNotifyNextChord(chordIndex: Int) -> Bool {
        if chordIndex != -1 {
            let division = Double(3) / Double(4)
            let offSet = chordPlayTime * division
            let notifyTime = songDiatonics[chordIndex].1 + offSet
            
            let roundedNotifyTime = round(notifyTime * Double(10)) / Double(10)
            let roundedTick = round(currentTick * Double(10)) / Double(10)
            
            //            print(roundedTick, roundedNotifyTime)
            if roundedTick == roundedNotifyTime {
                return true
            }
        }
        return false
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
                let diatonicOfCurrentTick = self.songDiatonics[chordIndexOfCurrentTick].0
                
                if self.isStop || chordIndexOfCurrentTick != self.currentChordIndex {
                    self.currentChordIndex = chordIndexOfCurrentTick
                    self.currentDiatonic = diatonicOfCurrentTick
                    self.isStop = false
                    
                    self.playCurrentDiatonic()
                }
                
                if self.checkWhetherToNotifyNextChord(chordIndex: chordIndexOfCurrentTick) {
                    // SET NEXT DIATONIC
                    var nextDiatonic: Diatonic?
                    /// check whetehr is is the last diatonic of the song
                    if chordIndexOfCurrentTick + 1 < self.songDiatonics.count {
                        nextDiatonic = self.songDiatonics[chordIndexOfCurrentTick + 1].0
                    } else {
                        nextDiatonic = self.songDiatonics[0].0
                    }
                    
                    if let nextTickDiatonic = nextDiatonic {
                        let nextChordNotes = Utils.getChordNotesToPlay(key: self.key!, diatonic: nextTickDiatonic)
                        
                        // GET NEXT DIATONIC AND MAKE A SET
                        var nextChordKeys = Set<MIDINoteNumber>()
                        
                        for note in nextChordNotes {
                            nextChordKeys.insert(MIDINoteNumber(note))
                        }
                        
                        self.showNextChordKeys(nextChordKeys: nextChordKeys)
                    }
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
    
    // Called when play diatonic (chord)
    private func playNote(note: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        sampler.play(noteNumber: note, velocity: velocity)
    }
    
    // Called when stop diatonic (chord)
    private func stopNote(note: MIDINoteNumber, channel: MIDIChannel) {
        sampler.stop(noteNumber: note)
    }
    
    private func allNotesOff() {
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
            
            var chordKeys = Set<MIDINoteNumber>()
            
            for note in currentChordNotes {
                chordKeys.insert(MIDINoteNumber(note))
                playNote(note: MIDINoteNumber(note), velocity: 127, channel: midiChannelIn)
            }
            
            // NOTIFY
            notifyChordKeys(with: chordKeys)
        }
    }
    
    private func updateRecordingTick() {
           if recordingTickTimer == nil {
               recordingTickTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timerObj) in
                   self.recordingTick += 0.01
               }
           } else {
               print("Timer already exists.")
           }
       }
    
    private func stopRecordingTick() {
        recordingTickTimer?.invalidate()
        recordingTickTimer = nil
    }
    
    private func resetRecordingTick() {
        recordingTickTimer?.invalidate()
        recordingTickTimer = nil
        
        recordingTick = 0.0
    }
}

//MARK: - Observer Pattern Methods
extension SongEngine {
    // Methods for Observer pattern
    func attachSongObserver(_ observer: SongHasFinished) {
        songObservers.append(observer)
    }
    
    func attachChordKeyObserver(_ observer: ChordKeyObserver) {
        chordKeyObservers.append(observer)
    }
    
    func attachRecordedSongObserver(_ observer: RecordedSongHasFinished) {
        recordedSongObservers.append(observer)
    }
    
    func notifySongHasFinished() {
        for observer in songObservers {
            observer.update(isStopPublished)
        }
    }
    
    func notifyChordKeys(with chordKeySet: Set<MIDINoteNumber>) {
        for observer in chordKeyObservers {
            observer.update(currentChordKeys: chordKeySet)
        }
    }
    
    func showNextChordKeys(nextChordKeys: Set<MIDINoteNumber>) {
        for observer in chordKeyObservers {
            observer.updateNextChordKeys(nextChordKeys: nextChordKeys)
        }
    }
    
    func notifyRecordedSongHasFinished() {
        for observer in recordedSongObservers {
            observer.update(true)
        }
    }
}
