//
//  LossScene.swift
//  GeniusGame
//
//  Created by campstud on 7/19/18.
//  Copyright © 2018 campstud. All rights reserved.
//

import SpriteKit


class LossScene: SKScene {
    var gameOver : SKLabelNode!
    var tryAgain : SKLabelNode!
    var scoreLabel : SKLabelNode!
    var score : Int!
    
    override func didMove(to view: SKView) {
        
        // Get the game over label
        gameOver = self.childNode(withName: "//gameOver") as! SKLabelNode
        gameOver.position.x = self.size.width/2
        
        // Get the try again label
        tryAgain = self.childNode(withName: "//tryAgain") as! SKLabelNode
        tryAgain.position.x = self.size.width/2
        
        scoreLabel = self.childNode(withName: "//score") as! SKLabelNode
        scoreLabel.position.x = self.size.width/2
        scoreLabel.text = String(score)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        for node in nodes(at: touch.location(in: self)) {
            if node == tryAgain {
                // Try again
                restartGame()
            }
        }
    }
    
    func restartGame() {
        if let scene = SKScene(fileNamed: "DoodleScene") {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            self.view?.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
        }
        
        self.view?.ignoresSiblingOrder = true
        self.view?.showsFPS = true
        self.view?.showsNodeCount = true
    }
}

