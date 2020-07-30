//
//  Key.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/30.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import Foundation

enum Key: Int, CaseIterable {
    case C = 0
    case Db = 1
    case D = 2
    case Eb = 3
    case E = 4
    case F = 5
    case Gb = 6
    case G = 7
    case Ab = 8
    case A = 9
    case Bb = 10
    case B = 11

    static func fromString(_ string: String) -> Key {
        switch string {
        case "C": // 0
            return .C
        case "Db": // 1
            return .Db
        case "D":  // 2
            return .D
        case "Eb": // 3
            return .Eb
        case "E": // 4
            return .E
        case "F": // 5
            return .F
        case "Gb": // 6
            return .Gb
        case "G": // 7
            return .G
        case "Ab": // 8
            return .Ab
        case "A": // 9
            return .A
        case "Bb": // 10
            return .Bb
        case "B": // 11
            return .B
        default:
            return .C
        }
    }
    
    func toString() -> String {
        switch self {
        case .C: // 0
            return "C"
        case .Db: // 1
            return "Db"
        case .D:  // 2
            return "D"
        case .Eb: // 3
            return "Eb"
        case .E: // 4
            return "E"
        case .F: // 5
            return "F"
        case .Gb: // 6
            return "Gb"
        case .G: // 7
            return "G"
        case .Ab: // 8
            return "Ab"
        case .A: // 9
            return "A"
        case .Bb: // 10
            return "Bb"
        case .B: // 11
            return "B"
        }
    }
}
