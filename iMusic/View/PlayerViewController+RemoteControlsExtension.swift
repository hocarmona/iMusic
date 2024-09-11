//
//  PlayerViewController+Extension.swift
//  iMusic
//
//  Created by Hector Carmona on 9/11/24.
//

import Foundation
import MediaPlayer

extension PlayerViewController {
    func setupNowPlayingInfo(song: Song) {
        var nowPlayingInfo = [String: Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = "titleee"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "artistttt"
        
        if let image = UIImage(named: "unknownSong") {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer?.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer?.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = audioPlayer?.isPlaying == true ? 1.0 : 0.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
    }
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [unowned self] event in
            if audioPlayer?.isPlaying == false {
                audioPlayer?.play()
                updateNowPlaying(isPlaying: true)
                self.viewModel.playPlayer()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if audioPlayer?.isPlaying == true {
                audioPlayer?.pause()
                updateNowPlaying(isPlaying: false)
                self.viewModel.stopPlayer()
                return .success
            }
            return .commandFailed
        }

        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            nextButtonTapped()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            previousButtonTapped()
            return .success
        }
    }

    func updateNowPlaying(isPlaying: Bool) {
        if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
}
