//
//  SeqView.swift
//  touchSlide (iOS)
//
//  Created by Joakim Hellgren on 2021-04-26.
//

import SwiftUI

enum StepType: CaseIterable {
    case trig, velocity, pitch
}

struct SeqView: View {
    @ObservedObject var conductor = SeqViewModel()
    @State var isMuted = [false]
    @State var stepType: StepType = .trig
    
    var body: some View {
        let trackCount = conductor.data.trackCount
        let tempo = conductor.data.tempo
        let setTempo = $conductor.data.tempo
        
        VStack {
            HStack {
                Text("trig").onTapGesture { stepType = .trig }
                Text("velocity").onTapGesture { stepType = .velocity }
                Text("pitch").onTapGesture { stepType = .pitch }
            } // MARK: HStack
            ForEach(0 ..< trackCount, id: \.self) { trackIndex in
                ForEach(0 ..< conductor.data.trackSignature[trackIndex], id: \.self) { index in
                    switch stepType {
                    case .trig:
                        StepView(conductor: conductor, track: trackIndex, index: index)
                    case .velocity:
                        VeloView(conductor: conductor, stepType: stepType, track: trackIndex, index: index)
                            .accentColor(.red)
                    case .pitch:
                        PitchView(conductor: conductor, stepType: stepType, track: trackIndex, index: index)
                            .accentColor(.green)
                    }
                } // MARK: - ForEach
            } // MARK: ForEach
            HStack {
                Text(conductor.data.isPlaying ? "Stop" : "Start").onTapGesture { conductor.data.isPlaying.toggle() }
                Slider(value: setTempo, in: 60.0 ... 620.0)
                Text("\(Int(tempo))")
            } // MARK: HStack
        } // MARK: VStack
        .onAppear { self.conductor.start() }
        .onDisappear { self.conductor.stop() }
    }
}

struct SeqView_Previews: PreviewProvider {
    static var previews: some View {
        SeqView()
    }
}
