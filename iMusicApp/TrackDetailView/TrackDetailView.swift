//
//  TrackDetailView.swift
//  iMusicApp
//
//  Created by Артём on 26.11.2022.
//

import UIKit
import SDWebImage
import AVKit

protocol TrackMovingDelegate {
    func moveBackForPreviosTrack() -> SearchViewModel.Cell?
    func moveForwardForNextTrack() -> SearchViewModel.Cell?
}

class TrackDetailView: UIView {
    //Outlets for Mini Detail View
    @IBOutlet weak var miniTrackDetailView: UIView!
    @IBOutlet weak var miniTrackImageView: UIImageView!
    @IBOutlet weak var miniTrackNameLabel: UILabel!
    @IBOutlet weak var miniPausePlayButton: UIButton!
    @IBOutlet weak var miniNextTrackButton: UIButton!
    
    //Outlets for Maximized Detail View
    @IBOutlet weak var maximizedTrackDetailView: UIStackView!
    @IBOutlet var trackImageView: UIImageView!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var trackNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var volumeSlider: UISlider!
    @IBOutlet weak var nextTrackButton: UIButton!
    @IBOutlet weak var previousTrackButton: UIButton!
    
    var delegate: TrackMovingDelegate?
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    
    var buttonAnimatingCircles = [UIButton: (backCircle: UIView, frontCircle: UIView)]()
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGestures()
        let scale: CGFloat = 0.8
        trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        trackImageView.layer.cornerRadius = 5
        
        //adding button tapping animation
        createTapButtonAnimation(for: nextTrackButton)
        createTapButtonAnimation(for: previousTrackButton)
        createTapButtonAnimation(for: playPauseButton)
        createTapButtonAnimation(for: miniPausePlayButton)
        createTapButtonAnimation(for: miniNextTrackButton)
        //adding player observers
        monitorPlayerStartTime()
        observePlayerCurrentTime()
    }
    
    //MARK: - Setups
    func setup(with viewModel: SearchViewModel.Cell) {
        miniTrackNameLabel.text = viewModel.trackName
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPausePlayButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPausePlayButton.imageEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
    
        playTrack(previewUrl: viewModel.previewUrl)
        
        let string600 = viewModel.iconUrlString?.replacingOccurrences(of: "100x100", with: "600x600")
        guard let url = URL(string: string600 ?? "") else { return }
        miniTrackImageView.sd_setImage(with: url, completed: nil)
        trackImageView.sd_setImage(with: url, completed: nil)
    }
    
    private func playTrack(previewUrl: String?) {
        guard let url = URL(string: previewUrl ?? "") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    
    //MARK: -  Gestures Setups
    private func setupGestures() {
        miniTrackDetailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        miniTrackDetailView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalSwipe)))
        
    }
    
    @objc private func handleTap() {
        tabBarDelegate?.maximizeTrackDetailController(cellViewModel: nil)
    }
    
    @objc private func handleSwipeGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
            
        case .began:
            print("began")
        case .changed:
            handlePanChanged(gesture: gesture)
        case .ended:
            handlePanEnded(gesture: gesture)
        default:
            print("default")
        }
    }
    
    private func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        let newAlpha = 1 + translation.y / 200
        self.miniTrackDetailView.alpha = newAlpha < 0 ? 0 : newAlpha
        self.maximizedTrackDetailView.alpha = -translation.y / 200
    }
    
    private func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity
            if translation.y < -200 || velocity.y < -500 {
                self.tabBarDelegate?.maximizeTrackDetailController(cellViewModel: nil)
            } else {
                self.miniTrackDetailView.alpha = 1
                self.maximizedTrackDetailView.alpha = 0
            }
        }, completion: nil)
    }
    
    @objc private func handleDismissalSwipe(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
       
        case .changed:
            let translation = gesture.translation(in: self.superview)
            maximizedTrackDetailView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        case .ended:
            let translation = gesture.translation(in: self.superview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.maximizedTrackDetailView.transform = .identity
                if translation.y > 50 {
                    self.tabBarDelegate?.minimizeTrackDetailController()
                }
            }, completion: nil)
      
         default:
            print("default")
        }
    }
    
    
    //MARK: - Time setup
    private func monitorPlayerStartTime() {
        let time = CMTime(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeTrackImageView()
        }
    }
    
    private func observePlayerCurrentTime() {
        let interval = CMTime(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTimeLabel.text = time.convertToString()
            
            let durationTime = self?.player.currentItem?.duration
            let currentDurationText = ((durationTime ?? CMTime(value: 1, timescale: 1)) - time).convertToString()
            self?.durationLabel.text = "-\(currentDurationText)"
            self?.updateCurrentTimeSlider()
        }
        
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            if self?.player.currentItem?.duration.seconds == time.seconds {
                self?.miniNextTrackButton.sendActions(for: .touchUpInside)
            }
        }
    }
    
    private func updateCurrentTimeSlider() {
        let currentTimeInSeconds = CMTimeGetSeconds(player.currentTime())
        let durationInSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime(value: 1, timescale: 1))
        let percentage = currentTimeInSeconds / durationInSeconds
        self.timeSlider.value = Float(percentage)
    }
    
    //MARK: - Animations
    private func enlargeTrackImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.trackImageView.transform = .identity
        }, completion: nil)
    }
    
    private func reduceTrackImageView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            let scale: CGFloat = 0.8
            self.trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }
    
    private func createTapButtonAnimation(for button: UIButton) {
        let circleViewClosure: (UIColor) -> UIView = { color in
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            view.backgroundColor = color
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = view.frame.height / 2
            return view
        }
        
        func createViewConstraints(view: UIView) {
            view.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
            view.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
            view.widthAnchor.constraint(equalToConstant: 1).isActive = true
            view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
        
        let backCircle = circleViewClosure(#colorLiteral(red: 0.5991063714, green: 0.5972339511, blue: 0.6107251048, alpha: 1))
        let frontCircle = circleViewClosure(.white)
        
        guard let buttonSuperView = button.superview else {return}
        buttonSuperView.insertSubview(backCircle, belowSubview: button)
        buttonSuperView.insertSubview(frontCircle, belowSubview: button)
        createViewConstraints(view: backCircle)
        createViewConstraints(view: frontCircle)

        buttonAnimatingCircles.updateValue((backCircle: backCircle, frontCircle: frontCircle), forKey: button)
        
        button.addTarget(self, action: #selector(tapButtonAnimationHandle), for: .touchUpInside)
    }
    
    @objc func tapButtonAnimationHandle(button: UIButton) {
        
        guard let backCircle = buttonAnimatingCircles[button]?.backCircle ,
              let frontCircle = buttonAnimatingCircles[button]?.frontCircle else {return}

        backCircle.transform = .identity
        frontCircle.transform = .identity
        backCircle.alpha = 1
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            backCircle.transform = CGAffineTransform(scaleX: button.frame.width, y: button.frame.width)
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                frontCircle.transform = CGAffineTransform(scaleX: button.frame.width, y: button.frame.width)
                backCircle.alpha = 0.1
            } completion: { _ in
                backCircle.transform = .identity
                frontCircle.transform = .identity
                backCircle.alpha = 1
            }
        }
    }
    
    
    //MARK: - @IBAction
    @IBAction func dragDownButton(_ sender: Any) {
        tabBarDelegate?.minimizeTrackDetailController()
    }
    
    @IBAction func handleCurrentTimeSlider(_ sender: Any) {
        let percentage = timeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    @IBAction func handleVolumeSlider(_ sender: Any) {
        player.volume = volumeSlider.value
    }
    
    @IBAction func previousTrackTapped(_ sender: Any) {
        guard let cellViewModel = delegate?.moveBackForPreviosTrack() else {return}
        setup(with: cellViewModel)
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPausePlayButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
    
    @IBAction func playPauseTapped(_ sender: Any) {
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPausePlayButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeTrackImageView()
        } else {
            player.pause()
            playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            miniPausePlayButton.setImage(UIImage(named: "play"), for: .normal)
            reduceTrackImageView()
        }
    }
    
    @IBAction func nextTrackTapped(_ sender: Any) {
        guard let cellViewModel = delegate?.moveForwardForNextTrack() else {return}
        setup(with: cellViewModel)
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPausePlayButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
}
