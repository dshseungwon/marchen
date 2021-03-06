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

let majorPrefix = ""
let minorPrefix = "m"
let diminishedPrefix = "dim"

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

    
    var triadPrefix: [String] {
        switch self {
        case .major:
            return [majorPrefix, minorPrefix, minorPrefix, majorPrefix, majorPrefix, minorPrefix, diminishedPrefix]
        case .minor:
            return [minorPrefix, diminishedPrefix, majorPrefix, minorPrefix, minorPrefix, majorPrefix, majorPrefix]
        }
    }
    
    
    var diatonicTriad: [[Int]] {
        switch self {
        case .major:
            return Mode.major.triad.enumerated().map({ (idx, triad) -> [Int] in
                return triad.map {
                    return $0 + Mode.major.noteOffsets[idx]
                }
            })
        case .minor:
            return Mode.minor.triad.enumerated().map({ (idx, triad) -> [Int] in
                return triad.map {
                    return $0 + Mode.minor.noteOffsets[idx]
                }
            })
        }
    }
}
