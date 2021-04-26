//
//  StepView.swift
//  touchSlide (iOS)
//
//  Created by Joakim Hellgren on 2021-04-26.
//

import SwiftUI

struct StepView: View {
    @ObservedObject var conductor: SeqViewModel
    var track: Int
    var index: Int
    
    var body: some View {
        let currentPos = Int(round(conductor.sequencer.tracks[track].currentPosition))
        let darkGray = Color(UIColor.darkGray)
        let systemBg = Color(UIColor.secondarySystemBackground)
        let noteStatus = conductor.data.noteStatus
        let selectedTrack = conductor.sequencer.tracks[track]
        let note = Int(conductor.data.notes[track])
        let vel = Int(conductor.data.velocity[index])
        let pos = Double(index)
        
        ZStack {
            Rectangle()
                .foregroundColor(noteStatus[track][index] ? darkGray : systemBg)
                .border(currentPos == index ? darkGray : .clear)
                .gesture(TapGesture().onEnded {
                    noteStatus[track][index]
                        ? selectedTrack.sequence.removeNote(at: Double(index))
                        : conductor.updateSequence(note: note, velocity: vel, position: pos, track: track)
                    conductor.data.noteStatus[track][index].toggle()
                })
        } // MARK: ZSTACK END
    }
}
