//
//  GameScene.swift
//  SolarVoyager
//
//  Created by Kevin Chen on 12/4/17.
//  Copyright © 2017 KamiKazo. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

var mainScene: GameScene?;

enum BitMasksEnum {
    static let BLOCK_CONTACT_BM:UInt32 = 1
    static let HIT_CONTACT_BM:UInt32 = 2
    static let CRIT_CONTACT_BM:UInt32 = 4
    static let ALL_BLOCK_CATEGORY_BM:UInt32 = 0xFFFFFFFF
}

protocol enemy {
    var hp: Int { get set }
    var eventWatch: enemyWatchDelegate? { get set }
    func hit(point: CGPoint, damage: Int)
    func destroy()
    func reset()
    func action(level: Int)
    func suicide()->Int
}

protocol enemyWatchDelegate {
    func didDestroyEnemy(node: enemy, param: String?)
}

protocol gameEventDelegate {
    func didPowerUp(type: Int);
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    //scene
    var lastUpdateTime : TimeInterval = 0
    let displaySize: CGRect = UIScreen.main.bounds
    var screenSize: CGRect?

    //UI
    var UIOverlay: SKNode = SKNode();
    var turrets : [Turret] = [Turret]();
    var turret : Turret?
    var toggleWeaponButton: SKSpriteNode?
    var scoreLabel: SKLabelNode = SKLabelNode();
    var healthLabel: SKLabelNode = SKLabelNode();
    var touchNode : SKSpriteNode?
    
    //Particles
    var ParticleOverlay: SKNode = SKNode();
    
    //player
    var health: Int = 100
    var maxHealth: Int = 150
    var level: Int = 1
    var score: Int = 0
    var cam: SKCameraNode?
    
    //enemies
    var spawner: EnemyGenerator?
    var lastSpawned: TimeInterval = 0
    var spawnDelay: TimeInterval = 0
    var checkSpawn: Bool = true

    override init(size: CGSize) {
        super.init(size: CGSize(width: size.width, height: size.height))
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0);
        self.physicsWorld.contactDelegate = self
        mainScene = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        //default crap
        self.lastUpdateTime = 0
        screenSize = Util.getVisibleScreen(sceneWidth: self.frame.width, sceneHeight: self.frame.height, viewWidth: UIScreen.main.bounds.width, viewHeight: UIScreen.main.bounds.height)
        
        //Camera
        //Move camera such that anchor is center bottom screen
        self.cam = SKCameraNode()
        self.camera = cam
        self.addChild(self.cam!)
        self.camera?.position = CGPoint(x: 0, y: (screenSize?.height)!/2)
        
        //UIOverlay
        let w = (screenSize?.width)!
        let h = (screenSize?.height)!
        self.UIOverlay.position = CGPoint(x: 0, y: 0)
        self.UIOverlay.zPosition = 3
        self.addChild(UIOverlay)
        
        //ParticalOverlay
        self.ParticleOverlay.position = CGPoint(x: 0, y: 0)
        self.ParticleOverlay.zPosition = 2
        self.addChild(ParticleOverlay)
        
        let bottomBar = SKSpriteNode(texture: nil, color: UIColor.gray, size: CGSize(width: (self.screenSize?.width)!, height: 200))
        bottomBar.position = CGPoint(x: 0, y: 100)
        bottomBar.physicsBody = SKPhysicsBody(rectangleOf: bottomBar.size)
        bottomBar.physicsBody?.affectedByGravity = false
        bottomBar.physicsBody?.isDynamic = true
        bottomBar.physicsBody?.collisionBitMask = 0
        bottomBar.physicsBody?.categoryBitMask = 0
        bottomBar.physicsBody?.contactTestBitMask = BitMasksEnum.ALL_BLOCK_CATEGORY_BM
        self.UIOverlay.addChild(bottomBar)
        
        //turret
//        turret = Turret(scene: self, size: CGSize(width: 200, height: 200))
//        turret?.position = CGPoint(x: 200, y: 100)
//        UIOverlay.addChild(turret!)
//        turrets.append(turret!)
//
//        let turret2 = Turret(scene: self, size: CGSize(width: 200, height: 200))
//        turret2.position = CGPoint(x: -200, y: 100)
//        UIOverlay.addChild(turret2)
//        turrets.append(turret2)
        
        let turret3 = Turret(scene: self, size: CGSize(width: 200, height: 200))
        turret3.position = CGPoint(x: 0, y: 100)
        UIOverlay.addChild(turret3)
        turrets.append(turret3)
        
        //spawner
        let lvlName:String = "level_" + String(level);
        self.spawner = EnemyGenerator(position: CGPoint(x: -w/2, y: h), horizontalRange: w);
        self.spawner?.loadLevel(lvlName);
        self.spawner?.initPaths();
        self.addChild(spawner!);
        
        //toggle weapon
        toggleWeaponButton = SKSpriteNode(color: UIColor.green, size: CGSize(width: 200, height: 200));
        toggleWeaponButton?.position = CGPoint(x: (w / 2) - 100, y: 100)
        toggleWeaponButton?.name = "toggleWeaponButton"
        UIOverlay.addChild(toggleWeaponButton!)
        
        //labels
        scoreLabel = SKLabelNode()
        scoreLabel.text = String(self.score)
        scoreLabel.fontName = "HelveticaNeue"
        scoreLabel.fontSize = 72
        scoreLabel.position = CGPoint(x: 0, y: h - 200)
        scoreLabel.name = "scorelabel"
        UIOverlay.addChild(scoreLabel)
        
        healthLabel = SKLabelNode()
        healthLabel.text = String(health)
        healthLabel.fontSize = 60
        healthLabel.fontName = "HelveticaNeue"
        healthLabel.position = CGPoint(x: 0, y: 50)
        healthLabel.name = "healthLabel"
        UIOverlay.addChild(healthLabel)
        
        //Controls
        self.touchNode = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 50, height: 50))
        self.touchNode?.name = "touchNode"
        self.touchNode?.isHidden = true
        self.touchNode?.position = CGPoint(x: 0, y: 0)
        self.UIOverlay.addChild((self.touchNode)!)
    
        
    }
    
    //TOUCH COMANDS
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches{
            touchStartHandler(touch: touch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        for touch in touches {
            touchMoveHandler(touch: touch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            touchReleaseHandler(touch: touch)
        }
    }
    
    
    //TOUCH HANDLERS
    func touchStartHandler(touch: UITouch) {
        let point = touch.location(in: UIOverlay)
        if(point.y > 200){
            if(touchNode?.isHidden == true){
                touchNode?.isHidden = false;
                touchNode?.position = point
            }
        } else {
            let touchedNode = UIOverlay.atPoint(point)
            if(touchedNode.name == "Turret"){
                let tur = touchedNode as! Turret
                tur.toggleWeapon();
            }
        }
    }
    
    func touchMoveHandler(touch: UITouch) {
        if(touchNode?.isHidden == false){
            let point = touch.location(in: UIOverlay)
            touchNode?.position = point
        }
    }
    
    func touchReleaseHandler(touch: UITouch){
        if(touchNode?.isHidden == false){
            touchNode?.isHidden = true;
        }
    }
    
    func fire(){
        if let touch = self.touchNode {
            for tur in turrets {
                var theta:CGFloat = 0;
                theta = atan( ( touch.position.x - tur.position.x ) / (touch.position.y - tur.position.y ) ) * -1
                    if(touch.position.y <= tur.position.y){
                        theta = CGFloat.pi/2;
                        if(touch.position.x > 0){
                            theta = theta * -1
                        }
                    }
    
                tur.zRotation = theta
                tur.activeWeapon?.fire(theta: theta)
            }
        }
    }
    
    //Particles
    
    func createTextParticle(text: String, position: CGPoint?, duration: Double = 0.5, fontSize: CGFloat = 60){
        let label = SKLabelNode(text: text);
        label.fontSize = fontSize;
        label.fontName = "HelveticaNeue";
        label.fontColor = UIColor.yellow;
        if let pos = position {
            label.position = pos;
        } else {
            label.position = CGPoint(x: 0, y: screenSize!.height - 400)
        }

        self.ParticleOverlay.addChild(label);
        
        ParticleOverlay.run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.run({
                label.removeFromParent();
            })
        ]));
    }
    
    
    //DELEGATES
    func didBegin(_ contact: SKPhysicsContact) {
        if let enemy =  contact.bodyA.node as? enemy {
            didTakeDmg(enemy.suicide())
        } else if let enemy = contact.bodyB.node as? enemy{
            didTakeDmg(enemy.suicide())
        }
    }
    
    func didTakeDmg(_ dmg: Int){
        self.health = self.health - dmg;
        self.healthLabel.text = String(self.health)
    }
    
    func enemyDestroyed(node: SKNode, points: Int){
        self.score += points;
        self.scoreLabel.text = String(score);
        
        //lifesteal
        let bonus: Int = points / 10;
        if(bonus + health < maxHealth){
            health += bonus;
        } else {
            health = maxHealth
        }
        self.healthLabel.text = String(health);
        
        let p = node.position;
        let posIn = node.parent?.convert(node.position, to: ParticleOverlay);
//        print(posIn);
//        createTextParticle(text: "+"+String(points), position: posIn)
    }
    
    func powerUp(type: Int){
        if(type == 0){
            for tur in turrets {
                tur.upgradeRoF();
            }
        } else if (type == 1){
            for tur in turrets {
                tur.upgradeDmg();
            }
        }
        
    }
    
    //update funcs
    override func update(_ currentTime: TimeInterval) {
        self.lastUpdateTime = currentTime
        let dtSpawn = currentTime - lastSpawned
        
        //spawn
        if(checkSpawn && dtSpawn >= spawnDelay){
            checkSpawn = false;
            self.lastSpawned = currentTime
            
            let nextDelay = spawner!.spawnWave();
            
            if(nextDelay > 0.0){
                self.spawnDelay = nextDelay;
                checkSpawn = true;
            } else { //end of level, go to next
                level += 1;
                let didLoad = spawner!.loadLevel("level_"+String(level));
                if(didLoad){
                    
                    createTextParticle(text: "LEVEL "+String(level), position: nil, duration: 3.0, fontSize: 90)
//                    let label = SKLabelNode(text: "LEVEL " + String(level));
//                    label.fontSize = 90;
//                    label.fontColor = UIColor.yellow;
//                    label.position = CGPoint(x: 0, y: screenSize!.height - 400)
//                    self.UIOverlay.addChild(label);
//
//                    self.run(SKAction.sequence([
//                        SKAction.wait(forDuration: 3.0),
//                        SKAction.run({
//                            label.removeFromParent();
//                        })
//                    ]));
                    
                    self.lastSpawned = currentTime;
                    self.spawnDelay = 3.5;
                    checkSpawn = true;
                } else {
                    let label = SKLabelNode(text: "Victory!");
                    label.fontSize = 90;
                    label.fontColor = UIColor.yellow;
                    label.position = CGPoint(x: 0, y: screenSize!.height - 400)
                    self.UIOverlay.addChild(label);
                }
            }
        }
        
        if(touchNode?.isHidden == false){
            fire()
        }
        
    }
    
    override func didFinishUpdate() {
        for tur in turrets {
            tur.activeWeapon?.deltaFramesLastFired+=1
        }
    }
}


