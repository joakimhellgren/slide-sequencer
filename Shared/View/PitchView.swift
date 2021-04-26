//
//  PitchView.swift
//  touchSlide (iOS)
//
//  Created by Joakim Hellgren on 2021-04-26.
//

import SwiftUI

struct PitchView: View {
        @ObservedObject var conductor: SeqViewModel
        @State var stepType: StepType
        var track: Int
        var index: Int
        
        var body: some View {
            let currentPos = Int(round(conductor.sequencer.tracks[track].currentPosition))
            let darkGray = Color(UIColor.darkGray)
            let systemBg = Color(UIColor.secondarySystemBackground)
            let noteStatus = conductor.data.noteStatus
            let selectedTrack = conductor.sequencer.tracks[track]
            
            
            GeometryReader { geometry in
                // TODO: - there might be a need for horizontal and vertical alignments
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(noteStatus[track][index] ? systemBg : .clear)
                        .border(currentPos == index ? darkGray : .clear)
                   
                   
                        Rectangle()
                            .foregroundColor(noteStatus[track][index] ? .accentColor : .clear)
                            .frame(width: geometry.size.width * CGFloat(conductor.data.notes[index] / 100))
                    
                }
                
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        if noteStatus[track][index] {
                           
                  
                                conductor.data.notes[index] = min(max(0, Float(value.location.x / geometry.size.width * 100)), 100)
                            
                            selectedTrack.sequence.removeNote(at: Double(index))
                            
                            conductor.updateSequence(note: Int(conductor.data.notes[index]),
                                                     velocity: Int(conductor.data.velocity[index]),
                                                     position: Double(index), track: track)
                        }
                    })
                )
            } // MARK: GEOMETRY END
        }
}

struct PitchView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
