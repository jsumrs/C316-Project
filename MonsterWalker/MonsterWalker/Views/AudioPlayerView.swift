//
//  AudioPlayerView.swift
//  MonsterWalker
//
//  Created by James Midtdal  on 2026-04-10.
//

import SwiftUI

struct AudioPlayerView: View {
    private var audio = AudioPlayerModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Audio Test").font(.title)

            Button("Toggle Music") {
                if audio.musicIsPlaying {
                    audio.stopMusic()
                } else {
                    audio.startMusic()
                }
            }

            Button("Level Up Sound") {
                print("button pressed")
                audio.playSound(.levelUp) }
            Button("Feed Sound") { audio.playSound(.feed) }
            Button("Pet Sound") { audio.playSound(.pet) }
        }
        .padding()
    }
}

#Preview { AudioPlayerView() }
