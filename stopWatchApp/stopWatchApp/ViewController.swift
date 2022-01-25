//
//  ViewController.swift
//  stopWatchApp
//
//  Created by Шахноза on 25/1/22.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    // MARK: - properties
    
    private var hours: Int = 0
    private var minutes: Int = 0
    private var seconds: Int = 0
    
    private var timer: Timer? = nil
    
    // MARK: - Views and Layout properties
    
    private lazy var timerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "timer")
        imageView.tintColor = .black
        
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(50)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        return imageView
    }()
    
    private lazy var segmentedControlView: UISegmentedControl = {
        let items = ["Timer", "Stopwatch"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = .zero
        
        view.addSubview(segmentedControl)
        segmentedControl.addTarget(self, action: #selector(suitDidChange(_:)), for: .valueChanged)
        
        segmentedControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(timerImageView.snp.top).inset(100)
            
        }
        return segmentedControl
    }()
    
    private lazy var clockLabelView: UILabel = {
        let clockLabel = UILabel()
        clockLabel.text = "00:00:00"
        clockLabel.font = UIFont.systemFont(ofSize: 75)
        clockLabel.textAlignment = .center
        
        view.addSubview(clockLabel)
        
        clockLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(segmentedControlView.snp.top).inset(50)
            
        }
        return clockLabel
    }()
    
    private lazy var stopButtonView: UIButton = {
        let stopButton = UIButton(type: .system)
        stopButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 80), forImageIn: .normal)
        stopButton.tintColor = .black
        stopButton.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
        
        view.addSubview(stopButton)
        stopButton.addTarget(self, action: #selector(toggleStatusButton), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopCountingTimer), for: .touchUpInside)
        
        stopButton.snp.makeConstraints {
            $0.left.equalTo(40)
            $0.width.height.equalTo(80)
            $0.bottom.equalToSuperview().inset(200)
            
        }
        return stopButton
    }()
    
    private lazy var pauseButtonView: UIButton = {
        let pauseButton = UIButton(type: .system)
        pauseButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 80), forImageIn: .normal)
        pauseButton.tintColor = .black
        pauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        
        view.addSubview(pauseButton)
        pauseButton.addTarget(self, action: #selector(toggleStatusButton), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseCountingTimer), for: .touchUpInside)
        
        pauseButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
            $0.bottom.equalToSuperview().inset(200)
            
        }
        return pauseButton
    }()
    
    private lazy var playButtonView: UIButton = {
        let playButton = UIButton(type: .system)
        playButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 80), forImageIn: .normal)
        playButton.tintColor = .black
        playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        
        view.addSubview(playButton)
        playButton.addTarget(self, action: #selector(toggleStatusButton), for: .touchDown)
        playButton.addTarget(self, action: #selector(startCountingTimer), for: .touchUpInside)
        
        playButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(40)
            $0.width.height.equalTo(80)
            $0.bottom.equalToSuperview().inset(200)
            
        }
        return playButton
    }()
    
    private lazy var datePickerView: UIPickerView = {
        let timePicker = UIPickerView()
        
        view.addSubview(timePicker)
        
        timePicker.delegate = self
        timePicker.dataSource = self
        
        timePicker.snp.makeConstraints {
            $0.top.equalTo(clockLabelView.snp.top).inset(60)
            $0.right.left.equalToSuperview().inset(20)
            
        }
        return timePicker
    }()
    
    // list ours elements view
    private lazy var listLayoutViews = [timerImageView, segmentedControlView, clockLabelView, stopButtonView, pauseButtonView, playButtonView, datePickerView]
    
    // MARK: - lifecycle vc
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        
        // pass to every elements for show on screen
        let _ = listLayoutViews.compactMap { $0 }
        
        // first view timer therefore isHidden = true
        datePickerView.isHidden = true
        
        
    }
    
    // MARK: - Active @objc func
    
    @objc func suitDidChange(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            timerImageView.image = UIImage(systemName: "timer")
            datePickerView.isHidden = true
            
            // for replace new target
            self.playButtonView.removeTarget(self, action: .none, for: .touchDown)
            
            // add new target
            playButtonView.addTarget(self, action: #selector(startCountingTimer), for: .touchDown)
        default:
            timerImageView.image = UIImage(systemName: "stopwatch")
            datePickerView.isHidden = false
            
            // for replace new target
            self.playButtonView.removeTarget(self, action: .none, for: .touchDown)
            
            // add new target
            playButtonView.addTarget(self, action: #selector(startCountingStopwatch), for: .touchDown)
        }
    }
    
    @objc func toggleStatusButton() {
        
        if stopButtonView.isTouchInside {
            stopButtonView.setImage(UIImage(systemName: "stop.circle"), for: .normal)
            pauseButtonView.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            playButtonView.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        } else if pauseButtonView.isTouchInside {
            stopButtonView.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
            pauseButtonView.setImage(UIImage(systemName: "pause.circle"), for: .normal)
            playButtonView.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        } else if playButtonView.isTouchInside {
            stopButtonView.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
            pauseButtonView.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            playButtonView.setImage(UIImage(systemName: "play.circle"), for: .normal)
            print("1")
        } else {
            stopButtonView.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
            pauseButtonView.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            playButtonView.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        }
    }
    
    // MARK: - start Timer
    
    @objc func startCountingTimer() {
        invalidateTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
            if self.seconds == 59 {
                self.seconds = 0
                if self.minutes == 59 {
                    self.minutes = 0
                    self.hours += 1
                } else {
                    self.minutes += 1
                }
            } else {
                self.seconds += 1
            }
            self.clockLabelView.text = String(format:"%02i:%02i:%02i", self.hours, self.minutes, self.seconds)
        }
    }
    
    // MARK: - start Stopwatch
    
    @objc func startCountingStopwatch() {
        invalidateTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
            
            if self.seconds == 0 && self.minutes != 0 {
                self.minutes -= 1
                self.seconds = 59
            } else if self.minutes == 0 && self.hours != 0 {
                self.hours -= 1
                self.minutes = 59
                self.seconds = 59
            } else if self.minutes == 0 && self.hours == 0 && self.seconds == 0 {
                self.timer?.invalidate()
                self.timer = nil
            } else {
                self.seconds -= 1
            }
            
            self.clockLabelView.text = String(format:"%02i:%02i:%02i", self.hours, self.minutes, self.seconds)
        }
    }
    
    @objc func pauseCountingTimer() {
        invalidateTimer()
    }
    
    @objc func stopCountingTimer() {
        invalidateTimer()
        seconds = 0
        minutes = 0
        hours = 0
        clockLabelView.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        
    }
    // MARK: - functions
    
    // stop Timer.shedule
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}
// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // return 3 cells in picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    // return rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        // case 0 it's hours case 1d = 24 hours
        case 0:
            return 24
        // case 1,2 it's minutes, seconds 1m = 60 seconds,
        default:
            return 60
        }
    }
    // format hours, minutes, seconds in pickerView
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: "%02d", row)
    }
    
    // selected values in picker
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            hours = row
        } else if component == 1 {
            minutes = row
        } else {
            seconds = row + 1
        }
    }
}
