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

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHierarchy()
        setupLayout()
    }
    
    //MARK: - Settings
    
    private func setupHierarchy() {
        
    }
    
    private func setupLayout() {
        
    }

    //MARK: - Create functions

    @objc func statesButton() {
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 100, weight: .thin)

        if isStarted == false {
            startPauseButton.setImage(UIImage(systemName: "pause", withConfiguration: buttonConfig), for: .normal)
            isStarted = true
        } else {
            startPauseButton.setImage(UIImage(systemName: "play", withConfiguration: buttonConfig), for: .normal)
            isStarted = false
        }
    }
}

