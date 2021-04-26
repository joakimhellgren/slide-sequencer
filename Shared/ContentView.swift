//
//  ContentView.swift
//  Shared
//
//  Created by Joakim Hellgren on 2021-04-16.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            SeqView()
                .navigationTitle("Channel 1")
        } // Navigation View
        .overlay(
            ZStack {
                // Loading screen
                
            } // ZStack
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
