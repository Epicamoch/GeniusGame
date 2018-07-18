//
//  GameScene.swift
//  GeniusGame
//
//  Created by campstud on 7/16/18.
//  Copyright © 2018 campstud. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class DoodleScene: SKScene, SKPhysicsContactDelegate {
    
    var motionManager : CMMotionManager!
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    // Sprites
    var doodle : SKSpriteNode!
    var samplePlatform : SKSpriteNode!
    var background : SKSpriteNode!
    var background2 : SKSpriteNode!
    var platforms : [SKSpriteNode] = []
    var maxPlatforms = 15
    
    // Bits
    static let flyingBit : UInt32 = 0x1 << 0
    static let doodleBit : UInt32 = 0x1 << 1
    static let platformBit : UInt32 = 0x1 << 2
    static let collidableBit : UInt32 = 0x1 << 3
    static let nonCollidableBit : UInt32 = 0x1 << 4
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        // Create motion manager
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        motionManager.accelerometerUpdateInterval = 0.05

        doodle = self.childNode(withName: "//doodle") as! SKSpriteNode
        doodle.physicsBody?.categoryBitMask = DoodleScene.doodleBit
        doodle.physicsBody?.contactTestBitMask = DoodleScene.platformBit
        doodle.physicsBody?.collisionBitMask = DoodleScene.collidableBit

        samplePlatform = self.childNode(withName: "//platform") as! SKSpriteNode
        samplePlatform.name = "Platform"
        samplePlatform.physicsBody?.categoryBitMask = DoodleScene.platformBit
        samplePlatform.physicsBody?.collisionBitMask = DoodleScene.collidableBit

        // Retrieve background from SKScene
        let 
    
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        initalizePlatforms()
        
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("Contact")
        
        // TODO: We want to boost Doodle up
        if contact.bodyA.node!.name == "doodle" {
            // body B is the platform
            if contact.bodyB.node!.position.y < doodle.position.y {
                doodle.physicsBody?.velocity = CGVector(dx: 0, dy: 1000)
            }
        } else {
            // body A is the platform
            if contact.bodyA.node!.position.y < doodle.position.y {
                doodle.physicsBody?.velocity = CGVector(dx: 0, dy: 1000)
            }
        }
        
    }
    
    func initalizePlatforms() {
        for i in platforms.count..<maxPlatforms {
            let platform = samplePlatform.copy() as! SKSpriteNode
            platform.anchorPoint = CGPoint(x: 0, y: 0)
            let xPosition = randomFloat() * (CGFloat(self.size.width - platform.size.width))
            let yPosition = self.size.height/CGFloat(maxPlatforms) * CGFloat(i)
            platform.position = CGPoint(x: xPosition, y: yPosition)
            self.addChild(platform)
            self.platforms.append(platform)
        }
    }
    
    func autogeneratePlatforms() {
        if platforms.count < maxPlatforms {
            for i in platforms.count..<maxPlatforms {
                let platform = samplePlatform.copy() as! SKSpriteNode
                platform.anchorPoint = CGPoint(x: 0, y: 0)
                let xPosition = randomFloat() * (CGFloat(self.size.width - platform.size.width))
                let yPosition = self.size.height
                platform.position = CGPoint(x: xPosition, y: yPosition)
                self.addChild(platform)
                self.platforms.append(platform)
            }
        }
    }
    
    func randomFloat() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if let accelerometerData = motionManager.accelerometerData {
            //self.physicsWorld.gravity.dx = CGFloat(accelerometerData.acceleration.x * 10)
            //print(accelerometerData.acceleration)
            if accelerometerData.acceleration.x < 0 {
                //print("Left  " + String(Float(250 * accelerometerData.acceleration.x)))
                doodle.physicsBody?.velocity.dx = CGFloat(800 * accelerometerData.acceleration.x)
            } else {
                //print("Right  " + String(Float(250 * accelerometerData.acceleration.x)))
                doodle.physicsBody?.velocity.dx = CGFloat(800 * accelerometerData.acceleration.x)

            }
            
        }

        
        // Called before each frame is rendered
        if doodle.physicsBody!.velocity.dy < CGFloat(0) {
            // Enable collision
            doodle.physicsBody?.contactTestBitMask = DoodleScene.platformBit
            doodle.physicsBody?.collisionBitMask = DoodleScene.collidableBit
        } else {
            // Disable collision
            doodle.physicsBody?.contactTestBitMask = DoodleScene.nonCollidableBit
            doodle.physicsBody?.collisionBitMask = DoodleScene.nonCollidableBit
        }
        
        // Move everything down
        if doodle.position.y > self.size.height/2 {
            let dy = doodle.position.y - self.size.height/2
            for child in self.children {
                child.position.y -= dy
            }
        }
        
        for i in 0..<self.platforms.count {
            let platform = self.platforms[i]
            if platform.position.y < -20 {
                platform.removeFromParent()
                platforms.remove(at: i)
                autogeneratePlatforms()

            }
        }
        
        //If
        
        // If the doodle is past the screen, move it back onto the screen
        if (doodle.position.x + doodle.size.width < 0) {
            print("Teleport to the right side")
            doodle.position.x = self.size.width - doodle.size.width/2
        } else if (doodle.position.x >= self.size.width + doodle.size.width/2) {
            print("Teleport to the left side")
            doodle.position.x = -doodle.size.width/2
        }
        
        // Restart scene
        if (doodle.position.y < 0) {
            restartScene()
        }
    }
    
    func restartScene() {
        if let scene = SKScene(fileNamed: "DoodleScene") {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            self.view?.presentScene(scene)
        }
        
        self.view?.ignoresSiblingOrder = true
        self.view?.showsFPS = true
        self.view?.showsNodeCount = true
    }
}
