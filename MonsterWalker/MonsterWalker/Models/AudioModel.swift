//
//  AudioModel.swift
//  MonsterWalker
//
//  Created by James Midtdal  on 2026-04-01.
//

import Foundation
import AVFoundation
import Combine

enum SoundEffect {
    case levelUp
    case feed
    case pet
    
    var fileName: String {
        switch self {
        case .levelUp:
            //petsound would be the name of the mp3
            return "levelUpSound"
        case .feed:
            return "feedSound"
        case .pet:
            return "trogdor"
        }
    }
    
    var url: URL? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "mp3") else {
            return nil
        }
        return URL(fileURLWithPath: path)
    }
}

class AudioPlayerModel: ObservableObject {
    var musicPlayer: AVAudioPlayer?
    var soundEffectPlayer: AVAudioPlayer?
    
    @Published var musicIsPlaying = false
    
    init() {
        if let path = Bundle.main.path(forResource: "backgroundMusic", ofType: "mp3") {
            do {
                self.musicPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            } catch {
                print("Error loading background music: \(error)")
            }
        }
    }
    
    func playSound(_ effect: SoundEffect) {
        guard let url = effect.url else {
            print("Could not find sound file for \(effect)")
            return
        }
        
        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            soundEffectPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    
    func startMusic() {
        guard let player = musicPlayer else {
            print("musicPlayer is nil")
            return
        }
        player.numberOfLoops = -1
        if !player.play() {
            print("play() returned false")
        }
        musicIsPlaying = true
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer?.currentTime = 0
        musicIsPlaying = false
    }
}
