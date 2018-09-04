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
    var highScoreLabel : SKLabelNode = SKLabelNode();
    var healthLabel: SKLabelNode = SKLabelNode();
    var touchNode : SKNode?
    var pauseNode : SKSpriteNode?
    var restartNode: SKSpriteNode?
    var homeNode: SKSpriteNode?
    var bgmSoundNode: SKNode?
    var backgroundNode: SKSpriteNode?

    //max 2 fingers, 1 for target 1 for some other UI
    var targetTouch: String? = nil;
    var selectorTouch: String? = nil;
    
    //Particles
    var ParticleOverlay: SKNode = SKNode();
    var projectileEmitters: NodeCollection?;
    var explosionEmitters: NodeCollection?;
    var criticalEmitters : NodeCollection?;
    
    
    //player
    var health: Int = 5
    var currHighScore: Int = 0
    var level: Int = 1
    var score: Int = 0
    var cam: SKCameraNode?
    var chargeCounter = 0;
    
    //enemies
    var spawner: EnemyGenerator?
    var lastSpawned: TimeInterval = 0
    var spawnDelay: TimeInterval = 0
    var checkSpawn: Bool = true

    
    override init(size: CGSize) {
        super.init(size: CGSize(width: size.width, height: size.height))
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0);
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = UIColor.black;
        mainScene = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        screenSize = Util.getVisibleScreen(sceneWidth: self.frame.width, sceneHeight: self.frame.height, viewWidth: UIScreen.main.bounds.width, viewHeight: UIScreen.main.bounds.height)
        currHighScore = UserDefaults.standard.integer(forKey: "SpaceAidsHighScore") as Int;
        
        //Camera
        //Move camera such that anchor is center bottom screen
        self.cam = SKCameraNode()
        self.camera = cam
        self.addChild(self.cam!)
        self.camera?.position = CGPoint(x: 0, y: (screenSize?.height)!/2)
        
        //background
        backgroundNode = SKSpriteNode(texture: Assets.Background);
        backgroundNode?.anchorPoint = CGPoint(x: 0.5, y: 0);
        backgroundNode?.position = CGPoint(x: 0, y: 0);
        backgroundNode?.zPosition = -1
        self.addChild(backgroundNode!);
        
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
        
        let bottomBar = SKSpriteNode(texture: Assets.BottomBarSprite, color: UIColor.gray, size: CGSize(width: (self.screenSize?.width)!, height: 200))
        bottomBar.position = CGPoint(x: 0, y: 100)
        bottomBar.physicsBody = SKPhysicsBody(rectangleOf: bottomBar.size)
        bottomBar.physicsBody?.affectedByGravity = false
        bottomBar.physicsBody?.isDynamic = true
        bottomBar.physicsBody?.collisionBitMask = 0
        bottomBar.physicsBody?.categoryBitMask = 0
        bottomBar.physicsBody?.contactTestBitMask = BitMasksEnum.ALL_BLOCK_CATEGORY_BM
        self.UIOverlay.addChild(bottomBar)
        
        let turret = Turret(scene: self, size: CGSize(width: 200, height: 200))
        turret.position = CGPoint(x: 0, y: 150)
        UIOverlay.addChild(turret)
        turrets.append(turret)
        
        //emitters
        var eEmitters = [SKEmitterWrapper]();
        for _ in 0..<4 {
            let myEmit = SKEmitterWrapper(emitter: SKEmitterNode(fileNamed:"Explosion.sks")!)
            myEmit.Emitter?.advanceSimulationTime(1)
            eEmitters.append(myEmit)
            ParticleOverlay.addChild(myEmit)
        }
        explosionEmitters = NodeCollection(collection: eEmitters);
        
        
        var hitEmitters = [SKEmitterWrapper]();
        for _ in 0..<4 {
            let myEmit = SKEmitterWrapper(emitter: SKEmitterNode(fileNamed: "HitParticle.sks")!)
            myEmit.Emitter?.advanceSimulationTime(1)
            hitEmitters.append(myEmit)
            ParticleOverlay.addChild(myEmit)
        }
        projectileEmitters = NodeCollection(collection: hitEmitters);
        
        
        var cEmitters = [SKEmitterWrapper]();
        for _ in 0..<2 {
            let myEmit = SKEmitterWrapper(emitter: SKEmitterNode(fileNamed: "CritParticle.sks")!)
            myEmit.Emitter?.advanceSimulationTime(1)
            cEmitters.append(myEmit)
            ParticleOverlay.addChild(myEmit)
        }
        criticalEmitters = NodeCollection(collection: cEmitters);
        
        
        //spawner
        let lvlName:String = "level_" + String(level);
        self.spawner = EnemyGenerator(position: CGPoint(x: -w/2, y: h), horizontalRange: w);
        self.spawner?.loadLevel(lvlName);
        self.spawner?.initPaths();
        self.addChild(spawner!);
        
        //labels
        scoreLabel.text = String(self.score)
        scoreLabel.fontName = "HelveticaNeue"
        scoreLabel.fontSize = 72
        scoreLabel.position = CGPoint(x: 0, y: h - 200)
        scoreLabel.name = "scorelabel"
        UIOverlay.addChild(scoreLabel)
        
        highScoreLabel.text = "High Score: \n" + String(self.currHighScore)
        highScoreLabel.fontName = "HelveticaNeue"
        highScoreLabel.fontSize = 72
        highScoreLabel.position = CGPoint(x: 0, y: h - (h/2))
        highScoreLabel.name = "highScorelabel"
        highScoreLabel.isHidden = true;
        UIOverlay.addChild(highScoreLabel)
        
        healthLabel.text = String(health)
        healthLabel.fontSize = 60
        healthLabel.fontName = "HelveticaNeue"
        healthLabel.position = CGPoint(x: 0, y: 50)
        healthLabel.name = "healthLabel"
        healthLabel.zPosition = 5
        UIOverlay.addChild(healthLabel)
        
        pauseNode = SKSpriteNode(texture: Assets.PauseIconSprite);
        pauseNode?.name = "pauseNode"
        pauseNode?.position = CGPoint(x: -w/2 + 100, y: h - 100)
        UIOverlay.addChild((pauseNode)!)
        
        restartNode = SKSpriteNode(texture: Assets.RestartIconSprite);
        restartNode?.name = "restartNode"
        restartNode?.position = CGPoint(x: -w/2 + 100, y: h - 220)
        restartNode?.isHidden = true;
        UIOverlay.addChild((restartNode)!)
        
        homeNode = SKSpriteNode(texture: Assets.HomeIconSprite);
        homeNode?.name = "homeNode"
        homeNode?.position = CGPoint(x: -w/2 + 100, y: h - 340)
        homeNode?.isHidden = true;
        UIOverlay.addChild((homeNode)!)

        
        //Controls
        self.touchNode = SKNode()
        self.touchNode?.name = "touchNode"
        self.touchNode?.position = CGPoint(x: 0, y: 0)
        self.UIOverlay.addChild((self.touchNode)!)

        self.addChild(SoundMaster.bgmPlayer);
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
    func handlePause(){
        self.isPaused = true;
        restartNode?.isHidden = false;
        homeNode?.isHidden = false;
        highScoreLabel.isHidden = false;
    }
    
    func handleUnpause(){
        self.isPaused = false;
        restartNode?.isHidden = true;
        homeNode?.isHidden = true;
        highScoreLabel.isHidden = true;
    }
    
    func targetTouchDidStart(touch: UITouch){
        if(targetTouch == nil){
            let point = touch.location(in: UIOverlay);
            targetTouch = String(format: "%p", touch);
            touchNode?.position = point;
            var percent = (point.x / (screenSize?.width)! / 2) * point.x / 2;
            if(point.x > 0){
                percent = percent * -1;
            }
            parallaxMoveTo(x: percent);
        }
    }
    
    func selectorTouchDidStart(touch: UITouch){
        if(selectorTouch == nil){
            let point = touch.location(in: UIOverlay);
            let touchedNode = UIOverlay.atPoint(point);
            selectorTouch = String(format: "%p", touch);
            if(touchedNode.name == "Turret"){
                let temp = touchedNode as! Turret
                temp.activateSupercharge();
            } else if(touchedNode.name == "Slide"){
                let temp = touchedNode.parent as! Turret
                temp.activateSupercharge();
            }
        }
    }
    
    func touchStartHandler(touch: UITouch) {
        let point = touch.location(in: UIOverlay)
        let touchedNode = UIOverlay.atPoint(point)
        
        if(self.isPaused){
            if(touchedNode.name == "restartNode"){
                self.removeAllChildren();
                self.removeAllActions();
                mainScene = nil;
                let scene = GameScene(size: CGSize(width: 1250, height: 2800));
                scene.scaleMode = .aspectFill
                if let view = self.view{
                    view.presentScene(scene)
                    view.ignoresSiblingOrder = true
                    view.showsFPS = false
                    view.showsPhysics = false
                    view.showsNodeCount = false
                }
            } else if(touchedNode.name == "homeNode"){
                self.removeAllChildren();
                let scene = MainMenu();
                if let view = self.view {
                    view.presentScene(scene)
                }
            } else if (self.health > 0){
                handleUnpause();
                return;
            }
        }
        
        if(touchedNode.name == "pauseNode"){
            handlePause();
            return;
        }
        
        if(point.y > 200){
            targetTouchDidStart(touch: touch);
        } else {
            selectorTouchDidStart(touch: touch);
        }
    }
    
    func touchMoveHandler(touch: UITouch) {
        if(targetTouch != nil && (String(format: "%p", touch) == targetTouch)){
            let point = touch.location(in: UIOverlay)
            touchNode?.position = point
            parallax(point: point)
        }
    }
    
    func parallax(point: CGPoint){
        if((backgroundNode?.hasActions) != nil){
            backgroundNode?.removeAllActions();
        }
        var percent = (point.x / (screenSize?.width)! / 2) * point.x / 2;
        if(point.x > 0){
            percent = percent * -1;
        }
        
        backgroundNode?.position.x = percent;
    }
    
    func parallaxMoveTo(x: CGFloat){
        if((backgroundNode?.hasActions) != nil){
            backgroundNode?.removeAllActions();
        }
        let action = SKAction.moveTo(x: x, duration: 0.2);
        
        backgroundNode?.run(action);
    }
    
    func touchReleaseHandler(touch: UITouch){
        let name = String(format: "%p", touch);
        if(selectorTouch != nil && (name == selectorTouch)){
            selectorTouch = nil;
        } else
        if(targetTouch != nil && (name == targetTouch)){
            targetTouch = nil;
            parallaxMoveTo(x: 0);
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
                tur.fire(theta: theta)
            }
        }
    }
    
    //Particles
    
    func createTextParticle(text: String, position: CGPoint?, color: UIColor = UIColor.yellow, duration: Double = 0.5, fontSize: CGFloat = 60){
        let label = SKLabelNode(text: text);
        label.fontSize = fontSize;
        label.fontName = "HelveticaNeue";
        label.fontColor = color;
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
            didTakeDmg(enemy.suicide(), contact: contact.contactPoint)
        } else if let enemy = contact.bodyB.node as? enemy{
            didTakeDmg(enemy.suicide(), contact: contact.contactPoint)
        }
    }
    
    func didTakeDmg(_ dmg: Int, contact: CGPoint){
        if let wrap = explosionEmitters?.getNext() {
            let wrapEmit = wrap as! SKEmitterWrapper;
            wrapEmit.position = contact;
            wrapEmit.Emitter?.resetSimulation();
            self.run(SoundMaster.getDamagedSound());
        }
        self.health = self.health - dmg;
        self.healthLabel.text = String(self.health)
        if(self.health <= 0){
            gameOver();
        }
    }
    
    func enemyDestroyed(node: SKNode, points: Int){
        self.score += points;
        self.chargeCounter += points;
        if(self.chargeCounter >= 5000){
            for tur in turrets {
                tur.supercharge();
            }
            self.chargeCounter = 0;
            createTextParticle(text: "Supercharge Ready", position: CGPoint(x: 0, y: screenSize!.height - 600), color: UIColor.yellow);
        }
        self.scoreLabel.text = String(score);
        
        let f = spawner?.convert(node.position, to: ParticleOverlay);
        if let wrap = explosionEmitters?.getNext() {
            let wrapEmit = wrap as! SKEmitterWrapper;
            wrapEmit.position = f!;
            wrapEmit.Emitter?.resetSimulation();
            if(node.name == "SuicideBomber") {
                wrapEmit.run(SoundMaster.explosionHeavySound);
            } else {
                wrapEmit.run(SoundMaster.explosionLightSound);
            }
        }
        
        createTextParticle(text: String(points), position: f)
    }
    
    func powerUp(type: Int){
        var typeString:String = "";
        var color = UIColor.red;
        if(type == 0){
            typeString = "Speed"
            color = UIColor.blue;
        } else if (type == 1){
            typeString = "Damage"
            color = UIColor.red;
            for tur in turrets {
                tur.upgradeDmg();
            }
        } else if (type == 2){
            typeString = "Health"
            color = UIColor.green;
        } else if (type == 3){
            typeString = "Supercharge"
            for tur in turrets {
                tur.supercharge();
            }
            color = UIColor.yellow;
        } else if (type == 10){
            typeString = "Double Turret"

            turrets[0].position = CGPoint(x: -200, y: 100);

            let turret2 = Turret(scene: self, size: CGSize(width: 200, height: 200))
            turret2.position = CGPoint(x: 200, y: 100)
            UIOverlay.addChild(turret2)
            turrets.append(turret2)
            
            //offset shots
            let timeBetweenShots = turrets[1].weapons[0].ROF / 60;
            let myDelay = timeBetweenShots/2;
            turrets[1].weapons[0].readyDelay = Double(myDelay)
            turrets[1].weapons[1].readyDelay = Double(myDelay)
            
        } else if (type == 11){
            typeString = "Triple Turret"
            
            turrets[0].position = CGPoint(x: -300, y: 100);
            turrets[1].position = CGPoint(x: 300, y: 100);
            
            let turret2 = Turret(scene: self, size: CGSize(width: 200, height: 200))
            turret2.position = CGPoint(x: 0, y: 100)
            UIOverlay.addChild(turret2)
            turrets.append(turret2)
            
            let timeBetweenShots = turrets[1].weapons[0].ROF / 60;
            let myDelay = timeBetweenShots/3;
            turrets[1].weapons[0].readyDelay = Double(myDelay)
            turrets[1].weapons[1].readyDelay = Double(myDelay)
            
            turrets[2].weapons[0].readyDelay = Double(myDelay*2)
            turrets[2].weapons[1].readyDelay = Double(myDelay*2)
            
        }
        createTextParticle(text: "+"+typeString, position: CGPoint(x: 0, y: screenSize!.height - 600), color: color);
    }
    
    func gameOver(){
        createTextParticle(text: "GAME OVER", position: CGPoint(x: 0, y: screenSize!.height - 600), color: UIColor.red, duration: 5.0);
        self.isPaused = true;
        self.restartNode?.isHidden = false;
        self.homeNode?.isHidden = false;
//        self.bgmNode?.isHidden = false;
        
        let defaults = UserDefaults.standard;
        let hs = defaults.integer(forKey: "SpaceAidsHighScore") as Int;
    
        if(score > hs){
            defaults.set(score, forKey: "SpaceAidsHighScore")
            highScoreLabel.text = "New High Score!"
            highScoreLabel.isHidden = false;
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
                
                if(level == 5){
                    self.powerUp(type: 10)
                }
                if(level == 8){
                    self.powerUp(type: 11)
                }
                if(level == 9){
                    createTextParticle(text: "Good luck", position: CGPoint(x: 0, y: screenSize!.height - 600), duration: 3.0, fontSize: 90)
                }
                if(level == 13){
                    createTextParticle(text: "Your enemies grow stronger", position: CGPoint(x: 0, y: screenSize!.height - 600), duration: 3.0, fontSize: 90)
                    self.spawner?.bogus1();
                }
                if(level == 20){
                    createTextParticle(text: "Your enemies grow stronger", position: CGPoint(x: 0, y: screenSize!.height - 600), duration: 3.0, fontSize: 90)
                    self.spawner?.bogus2();
                }
                if(level == 25){
                    createTextParticle(text: "Omae wa mou shindeiru", position: CGPoint(x: 0, y: screenSize!.height - 600), duration: 3.0, fontSize: 90)
                    self.spawner?.bogus3();
                }
                let didLoad = spawner!.loadLevel("level_"+String(level));
                if(didLoad){
                    createTextParticle(text: "LEVEL "+String(level), position: nil, duration: 3.0, fontSize: 90)
                    self.lastSpawned = currentTime;
                    self.spawnDelay = 3.5;
                    
                    checkSpawn = true;
                } else {
                    createTextParticle(text: "VICTORY", position: nil, duration: 3.0, fontSize: 90)
                }
            }
        }
        
        if(targetTouch != nil){
            fire()
        }
        
    }
    
    override func didFinishUpdate() {
        for tur in turrets {
            tur.activeWeapon?.deltaFramesLastFired+=1
        }
    }
}


