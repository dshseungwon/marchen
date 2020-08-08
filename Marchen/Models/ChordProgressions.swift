//
//  ChordProgressions.swift
//  Marchen
//
//  Created by Seungwon Ju on 2020/07/30.
//  Copyright © 2020 Seungwon Ju. All rights reserved.
//

import Foundation

let chordProgressions: [[Diatonic]] = [
    [Diatonic.IV, Diatonic.V, Diatonic.VI],
    [Diatonic.VI, Diatonic.V, Diatonic.IV],
    [Diatonic.I, Diatonic.V, Diatonic.VI, Diatonic.IV],
    [Diatonic.I, Diatonic.VI, Diatonic.II, Diatonic.V],
    [Diatonic.I, Diatonic.II, Diatonic.III, Diatonic.IV],
    [Diatonic.II, Diatonic.V, Diatonic.I, Diatonic.VI],
    [Diatonic.IV, Diatonic.V, Diatonic.III, Diatonic.VI],
    [Diatonic.IV, Diatonic.V, Diatonic.VI, Diatonic.III],
    [Diatonic.IV, Diatonic.V, Diatonic.III, Diatonic.IV],
    [Diatonic.VI, Diatonic.IV, Diatonic.I, Diatonic.V],
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
 
 */
