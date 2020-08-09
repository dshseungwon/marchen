//
//  ChordProgressions.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/30.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import Foundation
import RealmSwift

/*
Realm DB >> load [[Int]] >> load [[Diatonic]]
 
 Usage: [[Diatonic]]

Relam DB << save [[Int]] << save [[Diatonic]]
*/

class ChordProgressionModel: Object {
    
    var chordProgressionArray = List<ChordProgression>()
    
    static func DiatonicArrayToIntArray(_ diatonicArray: [[Diatonic]]) -> List<ChordProgression> {
        let chordProgressionList = List<ChordProgression>()
        
        for diatonicProgression in diatonicArray {
            let chordProgression = ChordProgression()
            
            for diatonic in diatonicProgression {
                chordProgression.chordProgression.append(diatonic)
            }
            
            chordProgressionList.append(chordProgression)
        }
        
        return chordProgressionList
    }
    
    static func RLMIntArrayToDiatonicArray(_ intArray: List<ChordProgression>) -> [[Diatonic]] {
        return intArray.map { (intProgression) -> [Diatonic] in
            return intProgression.chordProgression
        }
    }
    
    func loadDiatonicProgression() -> [[Diatonic]] {
        return ChordProgressionModel.RLMIntArrayToDiatonicArray(chordProgressionArray)
    }
    
    func saveDiatonicProgression(diatonicArray: [[Diatonic]])  {
        self.chordProgressionArray = ChordProgressionModel.DiatonicArrayToIntArray(diatonicArray)
    }
    
}

class ChordProgression: Object {
    dynamic var chordProgression: [Diatonic] = []
    @objc dynamic var intChordProgression: [Int] = []
}


let defaultChordProgressions: [[Diatonic]] = [
    [Diatonic.I, Diatonic.III, Diatonic.IV, Diatonic.IV],
    [Diatonic.I, Diatonic.V, Diatonic.VI, Diatonic.IV],
    [Diatonic.I, Diatonic.VI, Diatonic.II, Diatonic.V],
    [Diatonic.I, Diatonic.II, Diatonic.III, Diatonic.IV],
    
    [Diatonic.II, Diatonic.V, Diatonic.I, Diatonic.VI],
    [Diatonic.II, Diatonic.V, Diatonic.VII, Diatonic.VI],
    
    [Diatonic.IV, Diatonic.V, Diatonic.III, Diatonic.VI],
    [Diatonic.IV, Diatonic.V, Diatonic.VI, Diatonic.III],
    [Diatonic.IV, Diatonic.V, Diatonic.III, Diatonic.IV],
    
    [Diatonic.VI, Diatonic.IV, Diatonic.I, Diatonic.V],
    [Diatonic.VI, Diatonic.IV, Diatonic.V, Diatonic.I],
    [Diatonic.VI, Diatonic.V, Diatonic.II, Diatonic.V],
    [Diatonic.VI, Diatonic.V, Diatonic.VI, Diatonic.V, Diatonic.VI, Diatonic.IV, Diatonic.I, Diatonic.V,Diatonic.VI, Diatonic.V, Diatonic.VI, Diatonic.V],
    
    [Diatonic.IV,Diatonic.III,Diatonic.VI,Diatonic.V,Diatonic.IV,Diatonic.III,Diatonic.VI,Diatonic.I],
]

/*
 Diatonic Chord Progression:
 
 1) I - V - VI - IV
 2) I - VI - II - V
 3) II - V - I - VI
 4) IV - V - III - VI
 5) I - II - III - IV
 6) IV - V - VI - III
 
 7) VI - IV - I - V
 8) IV - V - VI
 
 Ref) https://m.post.naver.com/viewer/postView.nhn?volumeNo=26918722&memberNo=16273960
 Ref) https://youtu.be/mskdm7kaqEQ
 */
