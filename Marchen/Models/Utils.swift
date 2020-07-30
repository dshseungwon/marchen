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
}
