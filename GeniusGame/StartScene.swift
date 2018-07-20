//
//  StartScene.swift
//  GeniusGame
//
//  Created by campstud on 7/20/18.
//  Copyright © 2018 campstud. All rights reserved.
//

import UIKit
import SpriteKit

class StartScene: SKScene {
    
    var doodleLabel: SKLabelNode!
    var rockLabel: SKLabelNode!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // When you touch one of the labels
        guard let touch = touches.first else {
            return
        }

        for node in nodes(at: touch.location(in: self)) {
            if node == doodleLabel {
                // Present jump game
                presentJumpGame()
            } else if node == rockLabel {
                // Present rock game
                presentRockPaperScissorsGame()
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        // Load in the labels
        doodleLabel = self.childNode(withName: "//doodleLabel") as! SKLabelNode
        doodleLabel.text = "Doodle"
        doodleLabel.position = CGPoint(x: 0, y: self.size.height/4)

        rockLabel = self.childNode(withName: "//rockLabel") as! SKLabelNode
        rockLabel.text = "Rock Paper Scissors Game"
        if #available(iOS 11, *) {
            rockLabel.preferredMaxLayoutWidth = self.size.width * 0.75
        } else {
            // Fallback on earlier versions
            rockLabel.fontSize = 48.0
        }

        rockLabel.position = CGPoint(x: 0, y: -self.size.height/4)

        print(self.size)

    }
    
    func presentJumpGame() {
        if let view = self.view {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "DoodleScene") as? GameScene {
                
                
                // Set the scale mode to scale to fit the window
                scene.size = view.bounds.size
                scene.scaleMode = .aspectFill
                
                
                // Present the scene
                view.presentScene(scene, transition: SKTransition.crossFade(withDuration: 1.0))
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            
            // Create shape node to use during mouse interaction
            
        }
    }
    
    func presentRockPaperScissorsGame() {
        if let view = self.view {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                
                
                // Set the scale mode to scale to fit the window
                scene.size = view.bounds.size
                scene.scaleMode = .aspectFill
                
                
                // Present the scene
                view.presentScene(scene, transition: SKTransition.crossFade(withDuration: 1.0))
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            
            // Create shape node to use during mouse interaction
            
        }
    }

}
