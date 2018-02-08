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
    func action(level: Int)->SKAction?
}

protocol enemyWatchDelegate {
    func didDestroyEnemy(node: enemy)
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    //Default
    var lastUpdateTime : TimeInterval = 0
    let displaySize: CGRect = UIScreen.main.bounds
    var screenSize: CGRect?

    var UIOverlay: SKNode = SKNode();
    var turret : Turret?
    var toggleWeaponButton: SKSpriteNode?
    var scoreLabel: SKLabelNode?
    var touchNode : SKSpriteNode?
    
    //player
    var health: Int = 100
    var level: Int = 1
    var score: Int = 0
    var upgradeScore: Int = 0
    var lastLevelUp: TimeInterval = 0
    var currentWeapon: weapon?
    var rifle: weapon?
    var magnum: weapon?
    var weaponIndex = 0;
    var cam: SKCameraNode?
    
    //enemies
    var rightSpawner: Spawner?
    var leftSpawner: Spawner?
    var lastSpawned: TimeInterval = 10.0
    var spawnDelay: TimeInterval = 7.0
    var spawnSide: Int = 0
    var spawnSpeed: CGFloat = 300

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
        screenSize = getVisibleScreen(sceneWidth: self.frame.width, sceneHeight: self.frame.height, viewWidth: UIScreen.main.bounds.width, viewHeight: UIScreen.main.bounds.height)
        
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
        self.UIOverlay.zPosition = 10
        self.addChild(UIOverlay)
        
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
//        turret = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 200, height: 200));
        turret = Turret(scene: self, size: CGSize(width: 200, height: 200))
        turret?.position = CGPoint(x: 200, y: 100)
        UIOverlay.addChild(turret!)
        
        //toggle weapon
        toggleWeaponButton = SKSpriteNode(color: UIColor.green, size: CGSize(width: 200, height: 200));
        toggleWeaponButton?.position = CGPoint(x: (w / 2) - 100, y: 100)
        toggleWeaponButton?.name = "toggleWeaponButton"
        UIOverlay.addChild(toggleWeaponButton!)
        
        //score label
        scoreLabel = SKLabelNode()
        scoreLabel?.text = String(self.score)
        scoreLabel?.fontSize = 72
        scoreLabel?.position = CGPoint(x: 0, y: h - 200)
        scoreLabel?.name = "scorelabel"
        UIOverlay.addChild(scoreLabel!)
        
        
        //Controls
        self.touchNode = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 50, height: 50))
        self.touchNode?.name = "touchNode"
        self.touchNode?.isHidden = true
        self.touchNode?.position = CGPoint(x: 0, y: 0)
        self.UIOverlay.addChild((self.touchNode)!)
        
        
        leftSpawner = Spawner(scene: self, position: CGPoint(x: -(w/4), y: h+100), horizontalRange: w/2 - 100)
        rightSpawner = Spawner(scene: self, position: CGPoint(x: (w/4), y: h+100), horizontalRange: w/2 - 100)

        
        leftSpawner?.initEnemyGroup(type: enemyTypeEnum.SUICIDE, length: 1)
        leftSpawner?.initEnemyGroup(type: enemyTypeEnum.LILBASTERD, length: 5)
        leftSpawner?.initEnemyGroup(type: enemyTypeEnum.FIGHTER, length: 3)

        rightSpawner?.initEnemyGroup(type: enemyTypeEnum.SUICIDE, length: 1)
        rightSpawner?.initEnemyGroup(type: enemyTypeEnum.LILBASTERD, length: 5)
        rightSpawner?.initEnemyGroup(type: enemyTypeEnum.FIGHTER, length: 3)

        self.rifle = Rifle(scene: self, turret: self.turret!)
        self.magnum = Magnum(scene: self)
        
        self.currentWeapon = self.rifle
        currentWeapon?.activate()
        currentWeapon?.ready = true
    }

    
    func getVisibleScreen( sceneWidth: CGFloat, sceneHeight: CGFloat, viewWidth: CGFloat, viewHeight: CGFloat) -> CGRect {
        var sceneWidth = sceneWidth
        var sceneHeight = sceneHeight
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        let deviceAspectRatio = viewWidth/viewHeight
        let sceneAspectRatio = sceneWidth/sceneHeight
        
        if deviceAspectRatio < sceneAspectRatio {
            let newSceneWidth: CGFloat = (sceneWidth * viewHeight) / sceneHeight
            let sceneWidthDifference: CGFloat = (newSceneWidth - viewWidth)/2
            let diffPercentageWidth: CGFloat = sceneWidthDifference / (newSceneWidth)
            
            x = diffPercentageWidth * sceneWidth
            sceneWidth = sceneWidth - (diffPercentageWidth * 2 * sceneWidth)
        } else {
            let newSceneHeight: CGFloat = (sceneHeight * viewWidth) / sceneWidth
            let sceneHeightDifference: CGFloat = (newSceneHeight - viewHeight)/2
            let diffPercentageHeight: CGFloat = fabs(sceneHeightDifference / (newSceneHeight))
            
            y = diffPercentageHeight * sceneHeight
            sceneHeight = sceneHeight - (diffPercentageHeight * 2 * sceneHeight)
        }
        
        let visibleScreenOffset = CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(sceneWidth), height: CGFloat(sceneHeight))
        return visibleScreenOffset
    }
    
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
            if(touchedNode.name == "toggleWeaponButton"){
                toggleWeapon()
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
    
    func SDistanceBetweenPoints(first: CGPoint, second: CGPoint)->CGFloat{
        return CGFloat(hypotf(Float(second.x - first.x), Float(second.y - first.y)));
    }
    
    func toggleWeapon(){
        self.weaponIndex += 1
        if(self.weaponIndex > 1){
            self.weaponIndex = 0
        }
        //rifle
        if(self.weaponIndex == 0){
            self.currentWeapon?.deactivate()
            self.currentWeapon = self.rifle
            currentWeapon?.activate()
        } else
        //magnum
        if(self.weaponIndex == 1){
            self.currentWeapon?.deactivate()
            self.currentWeapon = self.magnum
            currentWeapon?.activate()
        }
    }
    
    func fire(){
        if let touch = self.touchNode {
            var theta:CGFloat = 0;
            theta = atan( ( touch.position.x - turret!.position.x ) / (touch.position.y - turret!.position.y ) ) * -1
                if(touch.position.y <= self.turret!.position.y){
                    theta = CGFloat.pi/2;
                    if(touch.position.x > 0){
                        theta = theta * -1
                    }
                }
           
            self.turret?.zRotation = theta
//            self.currentWeapon?.fire(theta: theta)
            self.turret?.activeWeapon?.fire(theta: theta)
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        if let enemy =  contact.bodyA.node as? enemy {
            enemy.destroy()
        } else if let enemy = contact.bodyB.node as? enemy{
            enemy.destroy()
        }
    }
    
    func enemyDestroyed(node: SKNode, points: Int){
        score += points;
        upgradeScore += points;
        if(upgradeScore > 3000){
            upgradeScore = 0
            upgradeWeapon()
        }
        self.scoreLabel?.text = String(score);
    }
    
    func upgradeWeapon(){
        let pick = arc4random_uniform(2)
        let type = arc4random_uniform(5)
        if(pick == 0){
            return
        } else {
            return
        }
        
    }
    
    func levelUp(){
        level += 1;
        print("level up")
        if(level%5 == 0){
            print("spawn moar")
            //allow max of 7 enemygroups
            if (leftSpawner!.enemyGroups.count > 7){
                leftSpawner?.enemyGroups.popLast()
                rightSpawner?.enemyGroups.popLast()
            }
            let t = arc4random_uniform(3) + 1
            if(t == enemyTypeEnum.SUICIDE){
                let adds = Int(level/3)
                leftSpawner?.initEnemyGroup(type: enemyTypeEnum.SUICIDE, length: 1 + adds)
            } else if (t == enemyTypeEnum.FIGHTER){
                let adds = Int(level/5)
                leftSpawner?.initEnemyGroup(type: enemyTypeEnum.FIGHTER, length: 3 + adds)
            } else if (t == enemyTypeEnum.LILBASTERD){
                let adds = Int(level/5)
                leftSpawner?.initEnemyGroup(type: enemyTypeEnum.LILBASTERD, length: 5 + adds)
            }
            
        } else if (level%2 == 0) {
            print("delaydown")
            spawnDelay -= 0.1
        } else {
            print("speedup")
            spawnSpeed += 10;
        }
        
    }

    //update funcs
    override func update(_ currentTime: TimeInterval) {
        self.lastUpdateTime = currentTime
        let dt = currentTime - lastSpawned
        
        //spawn
        if(dt > spawnDelay){
            if(spawnSide == 0){
                spawnSide = 1
                leftSpawner?.spawnNextGroup(speed: spawnSpeed, level: level)
            } else {
                spawnSide = 0
                rightSpawner?.spawnNextGroup(speed: spawnSpeed, level: level)
            }
            self.lastSpawned = currentTime
        }
        
        if(touchNode?.isHidden == false){
            fire()
        }
        
        let dtLevel = currentTime - lastLevelUp
        if(dt > 8.0){
            levelUp()
            self.lastLevelUp = currentTime
        }
        
    }
    
    override func didFinishUpdate() {
//        self.currentWeapon?.deltaFramesLastFired+=1
        self.turret?.activeWeapon?.deltaFramesLastFired+=1
    }
}


