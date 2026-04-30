//
//  GameViewController.swift
//  Spriteoscope iOS
//
//  Created by Maury Markowitz on 2022-10-08.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    private weak var scene: SpriteoscopeScene?
    private var pauseButton: UIButton!
    private var restartButton: UIButton!
    private var infoButton: UIButton!
    private var infoContainer: UIView!
    private var infoBottomConstraint: NSLayoutConstraint!
    private let infoContainerHeight: CGFloat = 360

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = SpriteoscopeScene.newSpriteoscopeScene()
        self.scene = scene

        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true

        setupOverlayButtons()
        setupInfoPanel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    private func setupOverlayButtons() {
        infoButton = makeButton(imageName: "more-info-icon", action: #selector(infoTapped))
        restartButton = makeButton(imageName: "undo-circle-outline-icon", action: #selector(restartTapped))
        pauseButton = makeButton(imageName: "pause-button-round-icon", action: #selector(pauseTapped))

        view.addSubview(infoButton)
        view.addSubview(pauseButton)
        view.addSubview(restartButton)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            infoButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            infoButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            infoButton.widthAnchor.constraint(equalToConstant: 34),
            infoButton.heightAnchor.constraint(equalToConstant: 34),

            pauseButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            pauseButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            pauseButton.widthAnchor.constraint(equalToConstant: 34),
            pauseButton.heightAnchor.constraint(equalToConstant: 34),

            restartButton.centerYAnchor.constraint(equalTo: pauseButton.centerYAnchor),
            restartButton.trailingAnchor.constraint(equalTo: pauseButton.leadingAnchor, constant: -10),
            restartButton.widthAnchor.constraint(equalToConstant: 34),
            restartButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    private func setupInfoPanel() {
        infoContainer = UIView()
        infoContainer.translatesAutoresizingMaskIntoConstraints = false
        infoContainer.backgroundColor = .black
        infoContainer.layer.cornerRadius = 24
        infoContainer.layer.masksToBounds = true
        infoContainer.layer.shadowColor = UIColor.black.cgColor
        infoContainer.layer.shadowOpacity = 0.6
        infoContainer.layer.shadowRadius = 20
        infoContainer.layer.shadowOffset = CGSize(width: 0, height: 10)

        view.addSubview(infoContainer)

        let safeArea = view.safeAreaLayoutGuide

        infoBottomConstraint = infoContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: infoContainerHeight)

        NSLayoutConstraint.activate([
            infoContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            infoContainer.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            infoContainer.heightAnchor.constraint(equalToConstant: infoContainerHeight),
            infoBottomConstraint
        ])

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Spriteoscope v\(VERSION_STRING)"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center

        let animationView = UIImageView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.clipsToBounds = true
        animationView.layer.cornerRadius = 12
        animationView.backgroundColor = .black
        animationView.layer.borderWidth = 1
        animationView.layer.borderColor = UIColor(white: 1, alpha: 0.25).cgColor
        if let image = UIImage(named: "computer_store") {
            animationView.image = image
        }

        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = "Spriteoscope is a recreation of the original Cromemco Dazzler kaleidoscope demo."
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 15)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        closeButton.backgroundColor = .white
        closeButton.layer.cornerRadius = 14
        closeButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)

        let textScroll = UIScrollView()
        textScroll.translatesAutoresizingMaskIntoConstraints = false
        textScroll.backgroundColor = .clear
        textScroll.addSubview(messageLabel)

        infoContainer.addSubview(titleLabel)
        infoContainer.addSubview(animationView)
        infoContainer.addSubview(textScroll)
        infoContainer.addSubview(closeButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: infoContainer.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: -20),

            animationView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            animationView.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 20),
            animationView.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: -20),
            animationView.heightAnchor.constraint(equalToConstant: 170),

            textScroll.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 16),
            textScroll.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 20),
            textScroll.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: -20),
            textScroll.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -16),

            messageLabel.topAnchor.constraint(equalTo: textScroll.topAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: textScroll.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: textScroll.trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: textScroll.bottomAnchor),
            messageLabel.widthAnchor.constraint(equalTo: textScroll.widthAnchor),

            closeButton.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: -20),
            closeButton.bottomAnchor.constraint(equalTo: infoContainer.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func makeButton(imageName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        let image = UIImage(named: imageName)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = UIColor(white: 0.9, alpha: 1)
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func pauseTapped() {
        guard let scene = scene else { return }
        scene.pauseKalidescope()
        let imageName = scene.myPaused ? "play-button-round-icon" : "pause-button-round-icon"
        pauseButton.setImage(UIImage(named: imageName), for: .normal)
    }

    @objc private func restartTapped() {
        scene?.setupKalidescope()
        if let scene = scene, scene.myPaused {
            pauseButton.setImage(UIImage(named: "play-button-round-icon"), for: .normal)
        } else {
            pauseButton.setImage(UIImage(named: "pause-button-round-icon"), for: .normal)
        }
    }

    @objc private func infoTapped() {
        let hidden = infoBottomConstraint.constant != 0
        infoBottomConstraint.constant = hidden ? 0 : infoContainerHeight

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
        }
    }
}

