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

/*TODO LIST
 -------------1. Score and leaderboard
 2. Ability to change character image (Multiple player images)
 -------------3. Background slide working
 -------------4. Game over screen
 -------------5. Different platforms
        - Breakable platforms
        - Moveable platforms
 -------------6. Increasing difficulty
 7. Powerups???
 -------------8. Swap directions
 9. Good looking menu
 
 
 */

class DoodleScene: SKScene, SKPhysicsContactDelegate {
    
    var motionManager : CMMotionManager!
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var PLATFORM_SPEED : CGFloat = 500
    let MAX_PLATFORM_SPEED : CGFloat = 4000
    let PLATFORM_CHANCE : CGFloat = 0.5
    
    // Sprites
    var doodle : SKSpriteNode!
    var samplePlatform : SKSpriteNode!
    var sampleMovingPlatform : SKSpriteNode!

    var background1 : SKSpriteNode!
    var background2 : SKSpriteNode!
    var platforms : Set<SKSpriteNode> = []
    var maxPlatforms = 20
    let minPlatforms = 4
    var maxHeightNode : SKSpriteNode?
    var scoreLabel : SKLabelNode!
    var score = 0
    
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

        createAssets()
        
        // Load music
        self.run(SKAction.repeatForever(SKAction.playSoundFileNamed("FinalBossTheme.mp3", waitForCompletion: true)))
        
        initalizePlatforms()
        
    }
    
    func createAssets() {
        doodle = self.childNode(withName: "//doodle") as! SKSpriteNode
        let shrunkSize = CGSize(width: doodle.size.width*0.9, height: doodle.size.height*0.9)
        doodle.physicsBody = SKPhysicsBody(rectangleOf: shrunkSize, center: CGPoint(x: 0, y: 0))
        doodle.physicsBody?.isDynamic = true
        doodle.physicsBody?.allowsRotation = false
        doodle.physicsBody?.affectedByGravity = true
        doodle.physicsBody?.categoryBitMask = DoodleScene.doodleBit
        doodle.physicsBody?.contactTestBitMask = DoodleScene.platformBit
        doodle.physicsBody?.collisionBitMask = DoodleScene.collidableBit
        
        samplePlatform = self.childNode(withName: "//platform") as! SKSpriteNode
        samplePlatform.name = "Platform"
        let shrunkPlatformSize = CGSize(width: samplePlatform.size.width*0.8, height: samplePlatform.size.height*0.8)
        samplePlatform.physicsBody = SKPhysicsBody(rectangleOf: shrunkPlatformSize, center: CGPoint(x: self.samplePlatform.size.width/2, y: 0))
        samplePlatform.physicsBody?.isDynamic = false
        samplePlatform.physicsBody?.allowsRotation = false
        samplePlatform.physicsBody?.affectedByGravity = false
        samplePlatform.physicsBody?.categoryBitMask = DoodleScene.platformBit
        samplePlatform.physicsBody?.collisionBitMask = DoodleScene.collidableBit
        
        sampleMovingPlatform = self.childNode(withName: "//movingPlatform") as! SKSpriteNode
        sampleMovingPlatform.name = "MovingPlatform"
        sampleMovingPlatform.physicsBody = SKPhysicsBody(rectangleOf: shrunkPlatformSize, center: CGPoint(x: self.samplePlatform.size.width/2, y: 0))
        sampleMovingPlatform.physicsBody?.isDynamic = true
        sampleMovingPlatform.physicsBody?.allowsRotation = false
        sampleMovingPlatform.physicsBody?.affectedByGravity = false
        sampleMovingPlatform.physicsBody?.categoryBitMask = DoodleScene.platformBit
        sampleMovingPlatform.physicsBody?.collisionBitMask = DoodleScene.collidableBit
        
        // Load in score label
        scoreLabel = self.childNode(withName: "//score") as! SKLabelNode
        scoreLabel.text = String(score)
        
        // Retrieve background from SKScene
        background1 = self.childNode(withName: "//background1") as! SKSpriteNode
        background2 = self.childNode(withName: "//background2") as! SKSpriteNode
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        // TODO: We want to boost Doodle up
        if contact.bodyA.node!.name == "doodle" {
            // body B is the platform
            if contact.bodyB.node!.position.y < doodle.position.y {
                doodle.physicsBody?.velocity = CGVector(dx: 0, dy: 1350)
            }
        } else {
            // body A is the platform
            if contact.bodyA.node!.position.y < doodle.position.y {
                doodle.physicsBody?.velocity = CGVector(dx: 0, dy: 1350)
            }
        }

    }
    
    func initalizePlatforms() {
        for i in platforms.count..<maxPlatforms {

            let xPosition = randomFloat() * (CGFloat(self.size.width - samplePlatform.size.width))
            let yPosition = self.size.height/CGFloat(maxPlatforms) * CGFloat(i)
            let point = CGPoint(x: xPosition, y: yPosition)
            createPlatform(ofType: "Normal", atPoint: point)
        }
    }
    
    func autogeneratePlatforms() {
        if platforms.count < maxPlatforms {
            for i in platforms.count..<maxPlatforms {
                let xPosition = randomFloat() * (CGFloat(self.size.width - samplePlatform.size.width))
                let maxHeight = maxHeightNode?.position.y != nil ? maxHeightNode!.position.y : self.size.height
                let maxDistance = self.size.height/3.5
                let yPosition = max(maxHeight + min(maxDistance, self.size.height / CGFloat(maxPlatforms)), self.size.height)
                
                let point = CGPoint(x: xPosition, y: yPosition)
                if (randomFloat() <= PLATFORM_CHANCE) {
                    createPlatform(ofType: "Moving", atPoint: point)
                } else {
                    createPlatform(ofType: "Normal", atPoint: point)
                }
            }
        }
    }
    
    func createPlatform(ofType type: String, atPoint point: CGPoint) {
        var platform : SKSpriteNode!
        
        if type == "Normal" {
            platform = samplePlatform.copy() as! SKSpriteNode
        } else if type == "Moving" {
            platform = sampleMovingPlatform.copy() as! SKSpriteNode
            if randomFloat() <= 0.5 {
                
            
                platform.physicsBody?.velocity.dx = getPlatformSpeed()
            } else {
                platform.physicsBody?.velocity.dx = -getPlatformSpeed()
            }
            print("Platform Speed: " + String(Float(getPlatformSpeed())))
        }
        platform.anchorPoint = CGPoint(x: 0, y: 0)
        platform.position = point
        
        if let height = maxHeightNode?.position.y {
            if platform.position.y > height  {
                maxHeightNode = platform
            }
        } else {
            maxHeightNode = platform
        }
        
        self.addChild(platform)
        self.platforms.insert(platform)
    }
    
    func randomFloat() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        // Update score
        if doodle.position.y > self.size.height/2 {
            score += Int(doodle.position.y - self.size.height/2)
            scoreLabel.text = String(score)
        }
        
        if let accelerometerData = motionManager.accelerometerData {
            //self.physicsWorld.gravity.dx = CGFloat(accelerometerData.acceleration.x * 10)
            //print(accelerometerData.acceleration)
            if accelerometerData.acceleration.x < 0 {
                //print("Left  " + String(Float(250 * accelerometerData.acceleration.x)))
                doodle.physicsBody?.velocity.dx = CGFloat(2000 * accelerometerData.acceleration.x)
                if (abs(accelerometerData.acceleration.x) > 0.125) {
                    doodle.xScale = 0.5
                }
            } else {
                //print("Right  " + String(Float(250 * accelerometerData.acceleration.x)))
                doodle.physicsBody?.velocity.dx = CGFloat(2000 * accelerometerData.acceleration.x)
                if (abs(accelerometerData.acceleration.x) > 0.125) {
                    doodle.xScale = -0.5
                }
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
                if child != scoreLabel {
                    child.position.y -= dy
                }
            }
        }
        
        // Check platform positions
        for platform in self.platforms {
            if platform.position.y < -20 {
                platform.removeFromParent()
                platforms.remove(platform)
                autogeneratePlatforms()
            } else {
                // If the platform is moving and is going off screen
                if (platform.position.x <= 0) {
                    platform.physicsBody?.velocity.dx = getPlatformSpeed()
                } else if (platform.position.x >= self.size.width - platform.size.width){
                    platform.physicsBody?.velocity.dx = -getPlatformSpeed()

                }
            }
            
            
        }
        
        // Perform background check
        if (performBackgroundCheck()) {
            maxPlatforms = max(maxPlatforms - 1, minPlatforms)
            print("Max #Platforms: " + String(maxPlatforms))
        }

        
        // If the doodle is past the screen, move it back onto the screen
        if (doodle.position.x + doodle.size.width/2 < 0) {
            print("Teleport to the right side")
            doodle.position.x = self.size.width
        } else if (doodle.position.x > self.size.width + doodle.size.width/2) {
            print("Teleport to the left side")
            doodle.position.x = -doodle.size.width/2
        }
        
        // Game Over
        if (doodle.position.y < 0) {
            gameOver()
        }
    }
    
    func getPlatformSpeed() -> CGFloat {
        return min(PLATFORM_SPEED * CGFloat(score)/CGFloat(10000), MAX_PLATFORM_SPEED)
    }
    
    func performBackgroundCheck() -> Bool{
        if self.background1.position.y + self.background1.size.height < 0 {
            self.background1.position.y = self.background2.position.y + self.background2.size.height
            return true
        }
        
        if self.background2.position.y + self.background2.size.height < 0 {
            self.background2.position.y = self.background1.position.y + self.background1.size.height
            return true
        }
        return false
    }
    
    func gameOver() {
        if let scene = SKScene(fileNamed: "LossScene") as? LossScene {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            scene.score = score
            
            // Present the scene
            self.view?.presentScene(scene, transition: SKTransition.doorsCloseHorizontal(withDuration: 1.0))
        }
        
        self.view?.ignoresSiblingOrder = true
        self.view?.showsFPS = true
        self.view?.showsNodeCount = true
    }
}
