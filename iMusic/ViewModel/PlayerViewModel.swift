//
//  PlayerViewModel.swift
//  iMusic
//
//  Created by Hector Carmona on 8/25/24.
//

import AVFoundation
import Foundation

class PlayerViewModel {
    
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentSongDuration: TimeInterval = 0
    @Published var currentSongTime: TimeInterval = 0
    private var songs: [Song] = []
    private var songsRepository = SongsRepository()
    @Published var currentSongIndex: Int = 0
    
    init() {
        self.songs = songsRepository.fetchAllSongs()
    }
    
    func getSongUrl(with index: Int) -> URL? {
        guard let path = Bundle.main.path(forResource: songs[index].name, ofType: "mp3") else { return nil}
        return URL(fileURLWithPath: path)
    }
    
    func getIsPlayerPlaying() -> Bool {
        return isPlaying
    }
    
    func togglePlayer() {
        isPlaying.toggle()
    }
    
    func playPlayer() {
        isPlaying = true
    }
    
    func stopPlayer() {
        isPlaying = false
    }
    
    func setCurrentSongPlaying(song: AVAudioPlayer?) {
        self.audioPlayer = song
    }
    
    func setSongToZeroTime() {
        self.currentSongTime = 0
    }
    
    func updateCurrentSongPlayingTime(currentTime: TimeInterval?) {
        if let currentTime,
           isPlaying {
            self.currentSongTime = currentTime
        }
    }
    
    func getCurrentSongDuration() -> TimeInterval {
        return audioPlayer?.duration ?? 0
    }
    
    func setNextSong() {
        let maxSongsIndex = self.songs.count - 1
        if currentSongIndex + 1 > maxSongsIndex {
            self.currentSongIndex = 0
        } else {
            self.currentSongIndex += 1
        }
    }
    
    func setPreviousSong() {
        if currentSongIndex <= 0 {
            currentSongIndex = 0
        } else {
            currentSongIndex -= 1
        }
    }
    
    func getformattedCurrentSongTimeLabel(value: Float) -> String {
        if value < 60 {
            if value < 10 {
                return "0:0\(Int(value.rounded(.toNearestOrAwayFromZero)))"
            } else {
                return "0:\(Int(value.rounded(.toNearestOrAwayFromZero)))"
            }
        } else {
            let minutes = value.rounded() / 60
            let seconds =  value.truncatingRemainder(dividingBy: 60).rounded()
            if seconds < 10 {
                return "\((Int(minutes.rounded(.down)))):0\(Int(seconds.rounded(.toNearestOrAwayFromZero)))"
            } else {
                return "\((Int(minutes.rounded(.down)))):\(Int(seconds.rounded(.toNearestOrAwayFromZero)))"
            }
        }
    }
}
