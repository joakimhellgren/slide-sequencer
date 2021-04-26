//
//  SeqViewModel.swift
//  touchSlide (iOS)
//
//  Created by Joakim Hellgren on 2021-04-26.
//

import Foundation
import AudioKit

class SeqViewModel: ObservableObject {
    
    let engine = AudioEngine()
    let shaker = RhodesPianoKey()
    var callbackInst = CallbackInstrument()
    let mixer = Mixer()
    var sequencer = Sequencer()
    
    @Published var data = SeqData() {
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
            data.notes.append(50)
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
