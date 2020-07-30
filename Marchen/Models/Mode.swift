//
//  Mode.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/30.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import Foundation

let majorTriad      = [0, 4, 7]
let minorTriad      = [0, 3, 7]
let diminishedTriad = [0, 3, 6]

enum Mode {
    case major, minor
    
    var noteOffsets: [Int] {
        switch self {
        case .major:
            return [0, 2, 4, 5, 7, 9, 11]
        case .minor:
            return [0, 2, 3, 5, 7, 8, 10]
        }
    }
    
    
    var triad: [[Int]] {
        switch self {
        case .major:
            return [majorTriad, minorTriad, minorTriad, majorTriad, majorTriad, minorTriad, diminishedTriad]
        case .minor:
            return [minorTriad, diminishedTriad, majorTriad, minorTriad, minorTriad, majorTriad, majorTriad]
        }
    }
    
    var diatonicTriad: [[Int]] {
        switch self {
        case .major:
            var idx = 0
            return Mode.major.triad.map({ (triad) -> [Int] in
                var mutableTriad = triad
                mutableTriad = mutableTriad.map { (offset) -> Int in
                    var mutableOffset = offset
                    mutableOffset += Mode.major.noteOffsets[idx]
                    return mutableOffset
                }
                idx += 1
                return mutableTriad
            })
        case .minor:
            var idx = 0
            return Mode.minor.triad.map({ (triad) -> [Int] in
                var mutableTriad = triad
                mutableTriad = mutableTriad.map { (offset) -> Int in
                    var mutableOffset = offset
                    mutableOffset += Mode.minor.noteOffsets[idx]
                    return mutableOffset
                }
                idx += 1
                return mutableTriad
                
            })
        }
    }
}
