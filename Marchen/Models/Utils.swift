//
//  Utils.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/30.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import Foundation

class Utils {
    
    static func keyToStr(key: Key) -> String {
        guard let string = keyToStrDic[key] else { fatalError("No String for given key") }
        return string
    }
    
    static func strToKey(str: String) -> Key {
        guard let key = strToKeyDic[str] else { fatalError("No Key for given string") }
        return key
    }
    
    static func diatonicToStr(diatonic: Diatonic) -> String {
        guard let string = diatonicToStrDic[diatonic] else { fatalError("No String for given Diatonic") }
        return string
    }
    
    static func strToDiatonic(str: String) -> Diatonic {
        guard let diatonic = strToDiatonicDic[str] else { fatalError("No Diatonic for given string") }
        return diatonic
    }
    
    static func getChordNotesToPlay (key: Key, diatonic: Diatonic) -> [Int] {
        let c3Offset = 48
        
        return Mode.major.diatonicTriad[diatonic.rawValue].map { (offset) -> Int in
            c3Offset + offset + key.rawValue
        }
    }
    
    
    static let keyToStrDic : [Key: String] = [
        Key.C: "C",
        Key.Db: "Db",
        Key.D: "D",
        Key.Eb: "Eb",
        Key.E: "E",
        Key.F: "F",
        Key.Gb: "Gb",
        Key.G: "G",
        Key.Ab: "Ab",
        Key.A: "A",
        Key.Bb: "Bb",
        Key.B: "B"
    ]
    
    static let strToKeyDic : [String: Key] = [
        "C": Key.C,
        "Db": Key.Db,
        "D": Key.D,
        "Eb": Key.Eb,
        "E": Key.E,
        "F": Key.F,
        "Gb": Key.Gb,
        "G": Key.G,
        "Ab": Key.Ab,
        "A": Key.A,
        "Bb": Key.Bb,
        "B": Key.B
    ]
    
    static let diatonicToStrDic : [Diatonic: String] = [
        Diatonic.I: "I",
        Diatonic.II: "II",
        Diatonic.III: "III",
        Diatonic.IV: "IV",
        Diatonic.V: "V",
        Diatonic.VI: "VI",
        Diatonic.VII: "VII"
    ]
    
    static let strToDiatonicDic : [String: Diatonic] = [
        "I": Diatonic.I,
        "II": Diatonic.II,
        "III": Diatonic.III,
        "IV": Diatonic.IV,
        "V": Diatonic.V,
        "VI": Diatonic.VI,
        "VII": Diatonic.VII
    ]
}
