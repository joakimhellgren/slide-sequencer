//
//  SeqData.swift
//  touchSlide (iOS)
//
//  Created by Joakim Hellgren on 2021-04-26.
//

import AudioKit

struct SeqData {
    var isPlaying = false
    var tempo: BPM = 420
    var timeSignatureTop: Int = 16
    var currentBeat = 0
    var trackCount = 1
    var trackSignature: [Int] = [16]
    var noteStatus: [[Bool]] = [[false]]
    var notes: [Float] = [50]
    var velocity: [Float] = [50]
}
