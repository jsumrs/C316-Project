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
    case pet
    case feed
    case TROGGDOOORR
    
    var fileName: String {
        switch self {
        case .pet:
            //petsound would be the name of the mp3
            return "petsound"
        case .feed:
            return "feedsound"
        case .TROGGDOOORR:
            return "troggdoor"
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
    
    init(){
        if let backgroundMusicPath = Bundle.main.path(forResource: "background", ofType: "mp3"){
            do{
                self.musicPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: backgroundMusicPath))
            }
            catch{
                
            }
        }
        self.soundEffectPlayer = AVAudioPlayer()
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
}
