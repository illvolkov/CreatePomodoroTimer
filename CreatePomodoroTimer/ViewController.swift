//
//  ViewController.swift
//  CreatePomodoroTimer
//
//  Created by Ilya Volkov on 24.01.2022.
//

import UIKit

class ViewController: UIViewController, CAAnimationDelegate {
    
    //Флаг для конфигурации режима работы
    private var isWorkTime = true
    //Флаг для конфигурации кнопки
    private var isStarted = false
    
    private var isAnimationStarted = false
    
    //MARK: - Elements

    private lazy var startPauseButton: UIButton = {
        let button = UIButton(type: .system)
        
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 100, weight: .thin)
        button.setImage(UIImage(systemName: "play", withConfiguration: buttonConfig), for: .normal)
        button.tintColor = UIColor(rgb: 0xF18B7F)
        button.addTarget(self, action: #selector(statesButton), for: .touchUpInside)

        return button
    }()
    
    private lazy var timerLabel: UILabel = {
        let timerLabel = UILabel()
        
        timerLabel.font = .systemFont(ofSize: 80, weight: .light)
        timerLabel.text = "25:00"
        timerLabel.textColor = UIColor(rgb: 0xF18B7F)
        return timerLabel
    }()
    
    private lazy var foreProgressLayer = circleProgressLayer()
    
    private lazy var backProgressLayer = circleProgressLayer()
    
    private lazy var circleIndicator: CAShapeLayer = {
        var circleIndicator = CAShapeLayer()

        let circleCenter = CGPoint(x: view.bounds.midX, y: view.bounds.midY - 78)
        circleIndicator.path = CGPath(ellipseIn: CGRect(x: -18, y: -185, width: 30, height: 30), transform: nil)
        circleIndicator.position = circleCenter
        circleIndicator.fillColor = UIColor.white.cgColor
        circleIndicator.strokeColor = UIColor(rgb: 0xF18B7F).cgColor
        circleIndicator.lineWidth = 2.3
        
        
        return circleIndicator
    }()
    
    let animationProgressBar = CABasicAnimation(keyPath: "strokeEnd")
    
    let animationCircle = CABasicAnimation(keyPath: "transform.rotation")

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
        startPauseButton.translatesAutoresizingMaskIntoConstraints = false
        startPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -5).isActive = true
        startPauseButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 20).isActive = true
        startPauseButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        startPauseButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 245).isActive = true
        timerLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 110).isActive = true
    }

    //MARK: - Create functions
    
    private var timer = Timer()
    private var totalSecond = 1500 {
        didSet {
            print(totalSecond)
        }
    }

    @objc private func statesButton() {
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 100, weight: .thin)
        
        if isStarted == false {
            startPauseButton.setImage(UIImage(systemName: "pause", withConfiguration: buttonConfig), for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
            startResumeAnimation()
            isStarted = true
        } else {
            startPauseButton.setImage(UIImage(systemName: "play", withConfiguration: buttonConfig), for: .normal)
            timer.invalidate()
            pauseAnimation(for: foreProgressLayer)
            pauseAnimation(for: circleIndicator)
            isStarted = false
        }
    }
    
    @objc private func timerAction() {
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 100, weight: .thin)
        totalSecond = totalSecond - 1
        convertingTime()
        if totalSecond == 0 && isWorkTime == true {
            totalSecond = 300
            animationProgressBar.duration = CFTimeInterval(totalSecond)
            backProgressLayer.strokeColor = UIColor(rgb: 0x66C2A3).cgColor
            timerLabel.textColor = UIColor(rgb: 0x66C2A3)
            startPauseButton.tintColor = UIColor(rgb: 0x66C2A3)
            circleIndicator.strokeColor = UIColor(rgb: 0x66C2A3).cgColor
            timerLabel.text = "05:00"
            startPauseButton.setImage(UIImage(systemName: "play", withConfiguration: buttonConfig), for: .normal)
            isStarted = false
            isWorkTime = false
            timer.invalidate()
        } else if totalSecond == 0 && isWorkTime == false{
            totalSecond = 1500
            animationProgressBar.duration = CFTimeInterval(totalSecond)
            backProgressLayer.strokeColor = UIColor(rgb: 0xF18B7F).cgColor
            timerLabel.text = "25:00"
            startPauseButton.setImage(UIImage(systemName: "play", withConfiguration: buttonConfig), for: .normal)
            timerLabel.textColor = UIColor(rgb: 0xF18B7F)
            startPauseButton.tintColor = UIColor(rgb: 0xF18B7F)
            circleIndicator.strokeColor = UIColor(rgb: 0xF18B7F).cgColor
            isWorkTime = true
            isStarted = false
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
    
    private func circleProgressLayer() -> CAShapeLayer {
        let circleProgressLayer = CAShapeLayer()
        
        let endAngle = (-CGFloat.pi / 2)
        let startAngle = 2 * CGFloat.pi + endAngle
        
        circleProgressLayer.path = UIBezierPath(arcCenter: CGPoint(x: 213, y: 385), radius: 170, startAngle: startAngle, endAngle: endAngle, clockwise: false).cgPath
        circleProgressLayer.strokeColor = UIColor(rgb: 0xF18B7F).cgColor
        circleProgressLayer.fillColor = UIColor.clear.cgColor
        circleProgressLayer.lineWidth = 6
        
        return circleProgressLayer
    }
    
    private func startAnimation() {
        resetAnimation()
        foreProgressLayer.strokeEnd = 0.0
        animationProgressBar.keyPath = "strokeEnd"
        animationProgressBar.fromValue = 0
        animationProgressBar.toValue = 1
        animationProgressBar.duration = CFTimeInterval(totalSecond)
        animationProgressBar.delegate = self
        animationProgressBar.isRemovedOnCompletion = false
        animationProgressBar.isAdditive = true
        animationProgressBar.fillMode = CAMediaTimingFillMode.forwards
        foreProgressLayer.strokeColor = UIColor.lightGray.cgColor
        foreProgressLayer.add(animationProgressBar, forKey: "strokeEnd")
        animateCircle()
        isAnimationStarted = true
    }
    
    private func startResumeAnimation() {
        if isAnimationStarted == false {
            startAnimation()
            animateCircle()
        } else {
            resumeAnimation(for: circleIndicator)
            resumeAnimation(for: foreProgressLayer)
        }
    }
    
    private func pauseAnimation(for circle: CAShapeLayer) {
        let pauseTime = circle.convertTime(CACurrentMediaTime(), from: nil)
        circle.speed = 0
        circle.timeOffset = pauseTime
    }
    
    private func resumeAnimation(for circle: CAShapeLayer) {
        let pauseTime = circle.timeOffset
        circle.speed = 1
        circle.timeOffset = 0.0
        circle.beginTime = 0.0
        let timeSincePaused = circle.convertTime(CACurrentMediaTime(), from: nil) - pauseTime
        circle.beginTime = timeSincePaused
    }
    
    private func resetAnimation() {
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        foreProgressLayer.strokeEnd = 0.0
        isAnimationStarted = false
    }
    
    private func stopAnimation() {
        foreProgressLayer.speed = 1
        foreProgressLayer.timeOffset = 0
        foreProgressLayer.beginTime = 0
        foreProgressLayer.strokeEnd = 0
        foreProgressLayer.removeAllAnimations()
        isAnimationStarted = false
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopAnimation()
    }
    
    private func animateCircle() {
        animationCircle.fromValue = 0
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
