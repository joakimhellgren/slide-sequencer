//
//  Shaker.swift
//  touchSlide
//
//  Created by Joakim Hellgren on 2021-04-17.
//

import AudioKit
import SwiftUI

struct ShakerMetronomeData {
    var isPlaying = false
    var tempo: BPM = 420
    var timeSignatureTop: Int = 16
    var currentBeat = 0
    
    var trackCount = 1
    var trackSignature: [Int] = [16]
    var noteStatus: [[Bool]] = [[false]]
    var notes: [Int] = [64]
    var velocity: [Float] = [50]
}

class ShakerConductor: ObservableObject {
    
    let engine = AudioEngine()
    let shaker = RhodesPianoKey()
    var callbackInst = CallbackInstrument()
    let mixer = Mixer()
    var sequencer = Sequencer()
    
    @Published var data = ShakerMetronomeData() {
        didSet {
            data.isPlaying ? sequencer.play() : sequencer.stop()
            sequencer.tempo = data.tempo
        }
    }
    
    func updateSequence(note: Int, velocity: Int, position: Double, track: Int) {
        var selectedTrack = sequencer.tracks[track]
        selectedTrack.sequence.add(noteNumber: MIDINoteNumber(note), velocity: MIDIVelocity(velocity), position: Double(position), duration: 0.1)
        
        // metro
        selectedTrack = sequencer.tracks[data.trackCount]
        selectedTrack.length = Double(data.timeSignatureTop)
        selectedTrack.clear()
        for beat in 0 ..< data.timeSignatureTop {
            selectedTrack.sequence.add(noteNumber: MIDINoteNumber(beat), position: Double(beat), duration: 0.1)
        }
        
    }
    

    
    init() {
       
        let fader = Fader(shaker)
        
        fader.gain = 20.0
        
        let _ = sequencer.addTrack(for: shaker)
        
        callbackInst = CallbackInstrument(midiCallback: { (_, beat, _) in
            self.data.currentBeat = Int(beat)
            for track in 0 ..< self.data.trackSignature.count {
                let currentPos = Int(self.sequencer.tracks[track].currentPosition.rounded())
                let timeSign = self.data.trackSignature[track]
                if currentPos == timeSign {
                    self.sequencer.tracks[track].rewind()
                    print("rewinded track: \(track)")
                }
               
            }
        })
        
        let _ = sequencer.addTrack(for: callbackInst)
        updateSequence(note: 0, velocity: 100, position: 0, track: 0)
        sequencer.tracks[0].clear()
        
        mixer.addInput(fader)
        mixer.addInput(callbackInst)
        engine.output = mixer
        
        for _ in 1 ..< data.timeSignatureTop {
            for trackIndex in 0 ..< data.noteStatus.count {
                data.noteStatus[trackIndex].append(false)
            }
            data.velocity.append(50)
            data.notes.append(64)
        }
        
        for track in sequencer.tracks {
            for index in 0 ..< data.trackSignature.count {
                track.length = Double(data.trackSignature[index])
            }
        }

    }
    
    func start() {
        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
    }
    
    func stop() {
        sequencer.stop()
        engine.stop()
    }
}

struct ShakerView: View {
    @ObservedObject var conductor = ShakerConductor()
    @State var isMuted = [false]
    @State var sequences: [[NoteEventSequence]] = [[]]
    @State var stepType: StepType = .trig
    
    var body: some View {
        let trackCount = conductor.data.trackCount
        let tempo = conductor.data.tempo
        let setTempo = $conductor.data.tempo
        
        VStack {
            Text("Track").font(.title).padding()
            HStack {
                Text("trig").onTapGesture { stepType = .trig }
                Text("velocity").onTapGesture { stepType = .velocity }
            } // MARK: HSTACK END
            ForEach(0 ..< trackCount, id: \.self) { trackIndex in
                ForEach(0 ..< conductor.data.trackSignature[trackIndex], id: \.self) { index in
                    switch stepType {
                    case .trig:
                        TrigView(conductor: conductor, track: trackIndex, index: index)
                    case .velocity:
                        VelocityView(conductor: conductor, stepType: stepType, track: trackIndex, index: index)
                            .accentColor(.red)
                    }
                }
            } // MARK: FOREACH END
            HStack {
                Text(conductor.data.isPlaying ? "Stop" : "Start").onTapGesture { conductor.data.isPlaying.toggle() }
                Slider(value: setTempo, in: 60.0 ... 620.0)
                Text("\(Int(tempo))")
            } // MARK: HSTACK END
            
        } // MARK: VSTACK END
        .onAppear { self.conductor.start() }
        .onDisappear { self.conductor.stop() }
    }
}

struct Shaker_Previews: PreviewProvider {
    static var previews: some View {
        ShakerView()
    }
}

struct TrigView: View {
    @ObservedObject var conductor: ShakerConductor
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

struct VelocityView: View {
    @ObservedObject var conductor: ShakerConductor
    @State var stepType: StepType
    var track: Int
    var index: Int
    
    var body: some View {
        let currentPos = Int(round(conductor.sequencer.tracks[track].currentPosition))
        let darkGray = Color(UIColor.darkGray)
        let systemBg = Color(UIColor.secondarySystemBackground)
        let noteStatus = conductor.data.noteStatus
        let selectedTrack = conductor.sequencer.tracks[track]
        let note = Int(conductor.data.notes[track])
        
        GeometryReader { geometry in
            // TODO: - there might be a need for horizontal and vertical alignments
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(noteStatus[track][index] ? systemBg : .clear)
                    .border(currentPos == index ? darkGray : .clear)
                Rectangle()
                    .foregroundColor(noteStatus[track][index] ? .accentColor : .clear)
                    .frame(width: geometry.size.width * CGFloat(conductor.data.velocity[index] / 100))
            }
            
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged({ value in
                    if noteStatus[track][index] {
                        conductor.data.velocity[index] = min(max(0, Float(value.location.x / geometry.size.width * 100)), 100)
                        selectedTrack.sequence.removeNote(at: Double(index))
                        
                        conductor.updateSequence(note: note,
                                                 velocity: Int(conductor.data.velocity[index]),
                                                 position: Double(index), track: track)
                    }
                })
            )
        } // MARK: GEOMETRY END
    }
}

enum StepType: CaseIterable {
    case trig, velocity
}
