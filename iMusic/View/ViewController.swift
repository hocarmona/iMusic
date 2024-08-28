//
//  ViewController.swift
//  iMusic
//
//  Created by Hector Carmona on 8/21/24.
//

import AVFoundation
import Combine
import UIKit

class ViewController: UIViewController {
    
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
    
    let playButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Play", for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 40
        button.setTitleColor(.black, for: .normal)
        button.clipsToBounds = true
        return button
    }()
    
    let nextButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("next", for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 20
        button.setTitleColor(.black, for: .normal)
        button.clipsToBounds = true
        return button
    }()
    
    let previousButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("prev", for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 20
        button.setTitleColor(.black, for: .normal)
        button.clipsToBounds = true
        return button
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
        view.addSubview(playButton)
        view.addSubview(nextButton)
        view.addSubview(previousButton)
        view.addSubview(currentTimeLabel)
        view.addSubview(durationTimeLabel)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            playButton.heightAnchor.constraint(equalToConstant: 80),
            playButton.widthAnchor.constraint(equalToConstant: 80),
            
            nextButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 16),
            nextButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 40),
            nextButton.widthAnchor.constraint(equalToConstant: 40),
            
            previousButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -16),
            previousButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            previousButton.heightAnchor.constraint(equalToConstant: 40),
            previousButton.widthAnchor.constraint(equalToConstant: 40),
            
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            progressSlider.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -40),
            
            currentTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 16),
            currentTimeLabel.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor, constant: 4),
            
            durationTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 16),
            durationTimeLabel.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor, constant: -4)
        ])

    }
    
    private func setActions() {
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
    }
    
    private func setListeners() {
        viewModel.$isPlaying.sink { playing in
            if playing {
                self.audioPlayer?.play()
                self.startSongTime()
                self.playButton.setTitle("Pause", for: .normal)
            } else {
                self.audioPlayer?.stop()
                self.songTimer?.invalidate()
                self.playButton.setTitle("Play", for: .normal)
            }
        }.store(in: &cancellables)
        
        viewModel.$currentSongDuration.sink { duration in
            self.durationTimeLabel.text = self.viewModel.getformattedCurrentSongTimeLabel(value: Float(duration))
        }.store(in: &cancellables)
        
        viewModel.$currentSongTime.sink { currentTime in
            self.currentTimeLabel.text = self.viewModel.getformattedCurrentSongTimeLabel(value: Float(currentTime))
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
        }.store(in: &cancellables)
    }
    
    @objc private func playButtonTapped() {
        viewModel.togglePlayer()
    }
    
    @objc private func previousButtonTapped() {
        viewModel.setPreviousSong()
    }
    
    @objc private func nextButtonTapped() {
        viewModel.setNextSong()
    }
    
    @objc private func timeTriggered() {
        viewModel.updateCurrentSongPlayingTime(currentTime: audioPlayer?.currentTime)
    }
    
    @objc private func sliderFinalValue() {
        let value = progressSlider.value
        self.audioPlayer?.currentTime = Double(value)
        viewModel.updateCurrentSongPlayingTime(currentTime: audioPlayer?.currentTime)
    }
    
    @objc private func sliderContinuesChange() {
        let value = progressSlider.value
        self.currentTimeLabel.text = viewModel.getformattedCurrentSongTimeLabel(value: value)
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
        guard let url = viewModel.getSongUrl(with: index) else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            self.viewModel.setCurrentSongPlaying(song: audioPlayer)
            progressSlider.minimumValue = 0
            progressSlider.maximumValue = Float(audioPlayer?.duration ?? 1)
            durationTimeLabel.text = viewModel.getformattedCurrentSongTimeLabel(value: Float(audioPlayer?.duration ?? 0))
        } catch {
            print("error playing audio")
        }
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

