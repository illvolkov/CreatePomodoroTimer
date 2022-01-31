//
//  ViewController.swift
//  CreatePomodoroTimer
//
//  Created by Ilya Volkov on 24.01.2022.
//

import UIKit

class ViewController: UIViewController {
    
    //Флаг для конфигурации режима работы
    var isWorkTime = true
    //Флаг для конфигурации кнопки
    var isStarted = false
    
    //MARK: - Elements

    private lazy var startPauseButton: UIButton = {
        let button = UIButton(type: .system)
        
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 100, weight: .thin)
        button.setImage(UIImage(systemName: "play", withConfiguration: buttonConfig), for: .normal)
        button.tintColor = UIColor(red: 241/255.0, green: 137/255.0, blue: 126/255.0, alpha: 1)
        button.addTarget(self, action: #selector(statesButton), for: .touchUpInside)

        return button
    }()
    
    private lazy var timerLabel: UILabel = {
        let timerLabel = UILabel()
        
        timerLabel.font = .systemFont(ofSize: 100, weight: .light)
        timerLabel.text = "25:00"
        timerLabel.textColor = UIColor(red: 241/255.0, green: 137/255.0, blue: 126/255.0, alpha: 1)
        return timerLabel
    }()

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHierarchy()
        setupLayout()
    }
    
    //MARK: - Settings
    
    private func setupHierarchy() {
        view.addSubview(startPauseButton)
        view.addSubview(timerLabel)
    }
    
    private func setupLayout() {
        startPauseButton.translatesAutoresizingMaskIntoConstraints = false
        startPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startPauseButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20).isActive = true
        startPauseButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        startPauseButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 245).isActive = true
        timerLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 90).isActive = true
    }

    //MARK: - Create functions
    
    var timer = Timer()
    var totalSecond = 1500

    @objc func statesButton() {
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 100, weight: .thin)
        
        if isStarted == false {
            startPauseButton.setImage(UIImage(systemName: "pause", withConfiguration: buttonConfig), for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            isStarted = true
        } else {
            startPauseButton.setImage(UIImage(systemName: "play", withConfiguration: buttonConfig), for: .normal)
            timer.invalidate()
            isStarted = false
        }
    }
    
    @objc func timerAction() {
        totalSecond = totalSecond - 1
        convertingTime()
        if totalSecond == 0 {
            timer.invalidate()
        }
    }
    
    private func convertingTime() {
        var minutes: Int
        var seconds: Int
        minutes = (totalSecond % 3600) / 60
        seconds = (totalSecond % 3600) % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
}

