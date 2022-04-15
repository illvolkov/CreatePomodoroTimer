//
//  ViewController.swift
//  CreatePomodoroTimer
//
//  Created by Ilya Volkov on 24.01.2022.
//

import UIKit

class ViewController: UIViewController, CAAnimationDelegate {
    
    //MARK: - Flags
    //Флаг для конфигурации режима работы
    private var isWorkTime = true
    //Флаг для конфигурации кнопки
    private var isStarted = false
    //Флаг для конфигурации анимации
    private var isAnimationStarted = false
    
    //MARK: - Elements

    //Создание кнопки Старт/Пауза
    private lazy var startPauseButton: UIButton = {
        let button = UIButton(type: .system)
        
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: Sizes.buttonIconSize, weight: .thin)
        button.setImage(UIImage(systemName: Icon.start, withConfiguration: buttonConfig), for: .normal)
        button.tintColor = Colors.workRedColor
        button.addTarget(self, action: #selector(statesButton), for: .touchUpInside)

        return button
    }()
    
    //Создание лейбла с таймером
    private lazy var timerLabel: UILabel = {
        let timerLabel = UILabel()
        
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: Sizes.labelSize, weight: .light)
        timerLabel.text = Strings.workTime25
        timerLabel.textColor = Colors.workRedColor
        timerLabel.adjustsFontSizeToFitWidth = true
        return timerLabel
    }()
    
    //Создание таймера
    private var timer = Timer()
    private var totalSecond = Time.workTime {
        didSet {
            print(totalSecond)
        }
    }
    
    //Создание главного прогресс бара на переднем плане
    private lazy var foreProgressLayer = circleProgressLayer()
    
    //Создание прогресс бара на фоне
    private lazy var backProgressLayer = circleProgressLayer()
    
    //Создание круглого индикатора прогресса
    private lazy var circleIndicator: CAShapeLayer = {
        var circleIndicator = CAShapeLayer()
        //Расположение индикатора
        let circleCenter = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 - Offsets.pointRotationY85)
        //Установка точки вокруг которой будет вращаться индикатор
        circleIndicator.path = CGPath(ellipseIn: CGRect(x: Offsets.indicatorPathX,
                                                        y: -(view.frame.width / 2.29),
                                                        width: Sizes.indicatorSize30,
                                                        height: Sizes.indicatorSize30),
                                                        transform: nil)
        circleIndicator.position = circleCenter
        circleIndicator.fillColor = UIColor.white.cgColor
        circleIndicator.strokeColor = Colors.workRedColor.cgColor
        circleIndicator.lineWidth = Sizes.lineWidthIndicator
        
        
        return circleIndicator
    }()
    
    //Создание анимации для прогресс бара
    let animationProgressBar = CABasicAnimation(keyPath: Strings.strokeEndKeyPath)
    
    //Создание анимации для круглого индикатора прогресса
    let animationCircle = CABasicAnimation(keyPath: Strings.transformRotationKeyPath)

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
        
        view.layer.addSublayer(backProgressLayer)
        view.layer.addSublayer(foreProgressLayer)
        view.layer.addSublayer(circleIndicator)
    }
    
    private func setupLayout() {
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor,
                                            constant: Offsets.timerLabelCenterX).isActive = true
        timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor,
                                            constant: Offsets.timerLabelCenterY).isActive = true
        timerLabel.widthAnchor.constraint(equalTo: view.widthAnchor,
                                          multiplier: Offsets.timerLabelMultiplierWidth).isActive = true
        timerLabel.heightAnchor.constraint(equalTo: view.widthAnchor,
                                           multiplier: Offsets.timerLabelMultiplierHeight).isActive = true
        
        startPauseButton.translatesAutoresizingMaskIntoConstraints = false
        startPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor,
                                                  constant: Offsets.startPauseButtonCenterX).isActive = true
        startPauseButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor,
                                              constant: Offsets.startPauseButtonTop).isActive = true
        startPauseButton.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                multiplier: Offsets.startPauseButtonMultiplierWidth).isActive = true
        startPauseButton.heightAnchor.constraint(equalTo: startPauseButton.widthAnchor).isActive = true
    }

    //MARK: - Create functions
    
    //Установка режимов кнопки Старт/Пауза
    @objc private func statesButton() {
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: Sizes.buttonIconSize, weight: .thin)
        
        if isStarted == false {
            startPauseButton.setImage(UIImage(systemName: Icon.pause, withConfiguration: buttonConfig), for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(timerAction),
                                         userInfo: nil,
                                         repeats: true)
            startResumeAnimation()
            isStarted = true
        } else {
            startPauseButton.setImage(UIImage(systemName: Icon.start, withConfiguration: buttonConfig), for: .normal)
            timer.invalidate()
            pauseAnimation(for: foreProgressLayer)
            pauseAnimation(for: circleIndicator)
            isStarted = false
        }
    }
    
    //Установка режимов работы приложения исходя из таймера
    @objc private func timerAction() {
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: Sizes.buttonIconSize, weight: .thin)
        totalSecond = totalSecond - 1
        convertingTime()
        
        if totalSecond == 0 && isWorkTime == true {  //Режим отдыха
            totalSecond = Time.breakTime
            animationProgressBar.duration = CFTimeInterval(totalSecond)
            changeColor(Colors.breakGreenColor)
            timerLabel.text = Strings.breakTime5
            startPauseButton.setImage(UIImage(systemName: Icon.start, withConfiguration: buttonConfig), for: .normal)
            isStarted = false
            isWorkTime = false
            timer.invalidate()
        } else if totalSecond == 0 && isWorkTime == false{  //Режим работы
            totalSecond = Time.workTime
            animationProgressBar.duration = CFTimeInterval(totalSecond)
            changeColor(Colors.workRedColor)
            timerLabel.text = Strings.workTime25
            startPauseButton.setImage(UIImage(systemName: Icon.start, withConfiguration: buttonConfig), for: .normal)
            isWorkTime = true
            isStarted = false
            timer.invalidate()
        }
    }
    
    //Перевод секунд в минуты и остаток секунд
    private func convertingTime() {
        var minutes: Int
        var seconds: Int
        minutes = (totalSecond % 3600) / 60
        seconds = (totalSecond % 3600) % 60
        timerLabel.text = String(format: Strings.formatTimer, minutes, seconds)
    }
    
    //Метод для создания прогресс бара
    private func circleProgressLayer() -> CAShapeLayer {
        let circleProgressLayer = CAShapeLayer()
        
        let endAngle = (-CGFloat.pi / 2)
        let startAngle = 2 * CGFloat.pi + endAngle
        
        circleProgressLayer.path = UIBezierPath(arcCenter: CGPoint(x: view.frame.width / 2,
                                                                   y: view.frame.height / 2 - Offsets.pointRotationY85),
                                                radius: .minimum(view.frame.width / 2.5, view.frame.height / 2.5),
                                                startAngle: startAngle,
                                                endAngle: endAngle,
                                                clockwise: false).cgPath
        circleProgressLayer.strokeColor = Colors.workRedColor.cgColor
        circleProgressLayer.fillColor = UIColor.clear.cgColor
        circleProgressLayer.lineWidth = Sizes.lineWidthProgressLayer
        
        return circleProgressLayer
    }
    
    //Метод изменения цвета при смене режима
    private func changeColor(_ color: UIColor) {
        backProgressLayer.strokeColor = color.cgColor
        timerLabel.textColor = color
        startPauseButton.tintColor = color
        circleIndicator.strokeColor = color.cgColor
    }
    
    //MARK: - Animation
    
    //Настройки для старта анимации
    private func startAnimation() {
        resetAnimation()
        foreProgressLayer.strokeEnd = Animation.strokeEnd0
        animationProgressBar.keyPath = Strings.strokeEndKeyPath
        animationProgressBar.fromValue = Animation.fromValue0
        animationProgressBar.toValue = Animation.progressBarToValue
        animationProgressBar.duration = CFTimeInterval(totalSecond)
        animationProgressBar.delegate = self
        animationProgressBar.isRemovedOnCompletion = false
        animationProgressBar.isAdditive = true
        animationProgressBar.fillMode = CAMediaTimingFillMode.forwards
        foreProgressLayer.strokeColor = UIColor.lightGray.cgColor
        foreProgressLayer.add(animationProgressBar, forKey: Strings.strokeEndKeyPath)
        animateCircleIndicator()
        isAnimationStarted = true
    }
    
    //Конфигурация режимов работы анимации
    private func startResumeAnimation() {
        if isAnimationStarted == false {
            startAnimation()
            animateCircleIndicator()
        } else {
            resumeAnimation(for: circleIndicator)
            resumeAnimation(for: foreProgressLayer)
        }
    }
    
    //Настройки для паузы анимации
    private func pauseAnimation(for circle: CAShapeLayer) {
        let pauseTime = circle.convertTime(CACurrentMediaTime(), from: nil)
        circle.speed = Animation.progressBarPauseSpeed
        circle.timeOffset = pauseTime
    }
    
    //Настройки для продолжения анимации
    private func resumeAnimation(for circle: CAShapeLayer) {
        let pauseTime = circle.timeOffset
        circle.speed = Animation.progressBarSpeed1
        circle.timeOffset = Animation.timeOffset0
        circle.beginTime = Animation.beginTime0
        let timeSincePaused = circle.convertTime(CACurrentMediaTime(), from: nil) - pauseTime
        circle.beginTime = timeSincePaused
    }
    
    //Настройки для перезагрузки анимации
    private func resetAnimation() {
        foreProgressLayer.speed = Animation.progressBarSpeed1
        foreProgressLayer.timeOffset = Animation.timeOffset0
        foreProgressLayer.beginTime = Animation.beginTime0
        foreProgressLayer.strokeEnd = Animation.strokeEnd0
        isAnimationStarted = false
    }
    
    //Настройки для остановки анимации
    private func stopAnimation() {
        foreProgressLayer.speed = Animation.progressBarSpeed1
        foreProgressLayer.timeOffset = Animation.timeOffset0
        foreProgressLayer.beginTime = Animation.beginTime0
        foreProgressLayer.strokeEnd = Animation.strokeEnd0
        foreProgressLayer.removeAllAnimations()
        isAnimationStarted = false
    }
    
    //Передача настроек для остановки делегату
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopAnimation()
    }
    
    //Настройки для анимации индикатора
    private func animateCircleIndicator() {
        animationCircle.fromValue = Animation.fromValue0
        animationCircle.toValue = -CGFloat.pi * 2
        animationCircle.duration = CFTimeInterval(totalSecond)
        animationCircle.isCumulative = true
        circleIndicator.add(animationCircle, forKey: nil)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && red <= 255, "Invalid green component")
        assert(blue >= 0 && red <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(red: (rgb >> 16) & 0xFF,
                  green: (rgb >> 8) & 0xFF,
                  blue: rgb & 0xFF)
    }
}

//MARK: - Constants

extension ViewController {
    enum Sizes {
        static let buttonIconSize: CGFloat = 100
        static let labelSize: CGFloat = 80
        static let indicatorSize30: CGFloat = 30
        static let lineWidthIndicator: CGFloat = 2.3
        static let lineWidthProgressLayer: CGFloat = 6
    }
    
    enum Time {
        static let workTime: Int = 1500
        static let breakTime: Int = 300
    }
    
    enum Offsets {
        static let indicatorPathX: CGFloat = -18
        static let pointRotationY85: CGFloat = 85
        static let timerLabelCenterX: CGFloat = -2
        static let timerLabelCenterY: CGFloat = -115
        static let timerLabelMultiplierWidth: CGFloat = 0.5
        static let timerLabelMultiplierHeight: CGFloat = 0.25
        static let startPauseButtonCenterX: CGFloat = -2
        static let startPauseButtonTop: CGFloat = 30
        static let startPauseButtonMultiplierWidth: CGFloat = 0.13
    }
    
    enum Animation {
        static let strokeEnd0: CGFloat = 0.0
        static let fromValue0: CGFloat = 0
        static let progressBarToValue: CGFloat = 1
        static let progressBarPauseSpeed: Float = 0.0
        static let progressBarSpeed1: Float = 1.0
        static let timeOffset0: CGFloat = 0.0
        static let beginTime0: CGFloat = 0.0
    }
    
    enum Icon {
        static let start: String = "play"
        static let pause: String = "pause"
    }
    
    enum Strings {
        static let workTime25: String = "25:00"
        static let breakTime5: String = "05:00"
        static let strokeEndKeyPath: String = "strokeEnd"
        static let transformRotationKeyPath: String = "transform.rotation"
        static let formatTimer: String = "%02d:%02d"
    }
    
    enum Colors {
        static let workRedColor = UIColor(rgb: 0xF18B7F)
        static let breakGreenColor = UIColor(rgb: 0x66C2A3)
    }
}
