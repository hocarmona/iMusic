//
//  ViewController.swift
//  iMusic
//
//  Created by Hector Carmona on 8/21/24.
//

import AVFoundation
import Combine
import MediaPlayer
import UIKit

class PlayerViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer?
    var cancellables: Set<AnyCancellable> = []
    var songTimer: Timer?
    var viewModel = PlayerViewModel()
    
    let playingInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Paused"
        return label
    }()
    
    let songImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "unknownSong"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.sizeToFit()
        return image
    }()
    
    var songName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = . white
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold, width: .standard)
        label.text = "Song Name"
        return label
    }()
    
    var artistName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = . white.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold, width: .standard)
        label.text = "Artist Name"
        return label
    }()
    
    let progressSlider: UISlider = {
        let progressSlider = UISlider()
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        progressSlider.tintColor = .white
        progressSlider.thumbTintColor = .white
        progressSlider.minimumTrackTintColor = .white
        progressSlider.maximumTrackTintColor = .lightGray.withAlphaComponent(0.4)
        progressSlider.value = 0.0
        progressSlider.addTarget(self, action: #selector(sliderFinalValue), for: .touchUpInside)
        progressSlider.addTarget(self, action: #selector(sliderContinuesChange), for: .valueChanged)
        return progressSlider
    }()
    
    let playButtonImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "stop-button"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.sizeToFit()
        image.tintColor = .white
        image.isUserInteractionEnabled = true
        return image
    }()
    
    let previousButtonImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "previousImage"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.sizeToFit()
        image.isUserInteractionEnabled = true
        return image
    }()
    
    let nextButtonImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "nextImage"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.sizeToFit()
        image.isUserInteractionEnabled = true
        return image
    }()
    
    var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = . white
        label.text = "0:00"
        return label
    }()
    
    var durationTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = . white
        label.text = "0:00"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUi()
        configureAudioSession()
        initiatePlayer()
    }
    
    private func initiatePlayer() {
        let initialSongIndex = viewModel.currentSongIndex
        prepareSongWithPlayer(index: initialSongIndex)
        setupNowPlayingRemoteControlInfo()
        setupRemoteTransportControls()
    }
    
    private func setUpUi() {
        view.backgroundColor = .darkGray
        addViews()
        setConstraints()
        setActions()
        setListeners()
    }
    
    private func addViews() {
        view.addSubview(progressSlider)
        view.addSubview(playButtonImage)
        view.addSubview(nextButtonImage)
        view.addSubview(previousButtonImage)
        view.addSubview(currentTimeLabel)
        view.addSubview(durationTimeLabel)
        view.addSubview(artistName)
        view.addSubview(songName)
        view.addSubview(songImage)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            playButtonImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButtonImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            playButtonImage.heightAnchor.constraint(equalToConstant: 80),
            playButtonImage.widthAnchor.constraint(equalToConstant: 80),
            
            nextButtonImage.leadingAnchor.constraint(equalTo: playButtonImage.trailingAnchor, constant: 32),
            nextButtonImage.centerYAnchor.constraint(equalTo: playButtonImage.centerYAnchor),
            nextButtonImage.heightAnchor.constraint(equalToConstant: 40),
            nextButtonImage.widthAnchor.constraint(equalToConstant: 40),

            previousButtonImage.trailingAnchor.constraint(equalTo: playButtonImage.leadingAnchor, constant: -32),
            previousButtonImage.centerYAnchor.constraint(equalTo: playButtonImage.centerYAnchor),
            previousButtonImage.heightAnchor.constraint(equalToConstant: 40),
            previousButtonImage.widthAnchor.constraint(equalToConstant: 40),
            
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            progressSlider.bottomAnchor.constraint(equalTo: playButtonImage.topAnchor, constant: -40),
            
            currentTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 16),
            currentTimeLabel.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor, constant: 4),
            
            durationTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 16),
            durationTimeLabel.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor, constant: -4),
            
            artistName.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor),
            artistName.bottomAnchor.constraint(equalTo: progressSlider.topAnchor, constant: -16),
            
            songName.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor),
            songName.bottomAnchor.constraint(equalTo: artistName.topAnchor, constant: -8),
            
            songImage.bottomAnchor.constraint(equalTo: songName.topAnchor, constant: -40),
            songImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            songImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            songImage.heightAnchor.constraint(equalToConstant: 350)
        ])

    }
    
    private func setActions() {
        setGestures()
    }
    
    private func setGestures() {
        let previousButtonGesture = UITapGestureRecognizer(target: self, action: #selector(previousButtonTapped))
        previousButtonImage.addGestureRecognizer(previousButtonGesture)
        
        let nextButtonGesture = UITapGestureRecognizer(target: self, action: #selector(nextButtonTapped))
        nextButtonImage.addGestureRecognizer(nextButtonGesture)
        
        let playButtonGesture = UITapGestureRecognizer(target: self, action: #selector(playButtonTapped))
        playButtonImage.addGestureRecognizer(playButtonGesture)
    }
    
    private func setListeners() {
        viewModel.$isPlaying.sink { playing in
            if playing {
                self.audioPlayer?.play()
                self.startSongTime()
                self.playButtonImage.image = UIImage(named: "stop-button")
            } else {
                self.audioPlayer?.stop()
                self.songTimer?.invalidate()
                self.playButtonImage.image = UIImage(named: "play-button")
            }
        }.store(in: &cancellables)
        
        viewModel.$currentSongTime.sink { currentTime in
            self.progressSlider.value = Float(currentTime)
        }.store(in: &cancellables)
         
        viewModel.$currentSongIndex.sink { indexSong in
            self.audioPlayer?.stop()
            self.prepareSongWithPlayer(index: indexSong)
            if self.viewModel.getIsPlayerPlaying() {
                self.goToBeginningAndStop()
                self.viewModel.playPlayer()
            } else {
                self.goToBeginningAndStop()
            }
            self.setupNowPlayingRemoteControlInfo()
        }.store(in: &cancellables)
        
        viewModel.$songDurationTimeString.sink { formattedTime in
            self.durationTimeLabel.text = formattedTime
        }.store(in: &cancellables)
        
        viewModel.$currentSongTimeString.sink { formattedTime in
            self.currentTimeLabel.text = formattedTime
        }.store(in: &cancellables)
        
        viewModel.$songTitle.sink { songTitle in
            self.songName.text = songTitle
        }.store(in: &cancellables)
        
        viewModel.$songArtist.sink { songArtist in
            self.artistName.text = songArtist
        }.store(in: &cancellables)
        
        viewModel.$songImageData.sink { imageData in
            if let songImageData = imageData {
                self.songImage.image = UIImage(data: songImageData)
            } else {
                self.songImage.image = UIImage(named: "unknownSong")
            }
        }.store(in: &cancellables)
    }
    
    @objc private func playButtonTapped() {
        viewModel.togglePlayer()
    }
    
    @objc internal func previousButtonTapped() {
        viewModel.setPreviousSong()
    }
    
    @objc internal func nextButtonTapped() {
        viewModel.setNextSong()
    }
    
    @objc private func timeTriggered() {
        viewModel.updateCurrentSongPlayingTime(currentTime: audioPlayer?.currentTime)
        setupNowPlayingRemoteControlInfo()
    }
    
    @objc private func sliderFinalValue() {
        let value = progressSlider.value
        self.audioPlayer?.currentTime = Double(value)
        viewModel.updateCurrentSongPlayingTime(currentTime: audioPlayer?.currentTime)
    }
    
    @objc private func sliderContinuesChange() {
        let continiousTimevalue = progressSlider.value
        self.currentTimeLabel.text = Utils.getformattedCurrentSongTimeLabel(value: continiousTimevalue)
    }
    
    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Error al configurar la sesión de audio: \(error.localizedDescription)")
        }
    }
    
    private func prepareSongWithPlayer(index: Int) {
        audioPlayer = viewModel.getAudioPlayer()
        audioPlayer?.prepareToPlay()
        self.viewModel.setCurrentSongPlaying(song: audioPlayer)
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(viewModel.getCurrentSongDuration())
        setupNowPlayingRemoteControlInfo()
    }
    
    private func startSongTime() {
        songTimer = Timer.scheduledTimer(
            timeInterval: 1, target: self, selector: #selector(timeTriggered), userInfo: nil, repeats: true
        )
    }
    
    func goToBeginningAndStop() {
        audioPlayer?.currentTime = 0
        viewModel.setSongToZeroTime()
        viewModel.updateCurrentSongPlayingTime(currentTime: audioPlayer?.currentTime)
        viewModel.stopPlayer()
    }
}

