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
    func action()->SKAction?
}

protocol enemyWatchDelegate {
    func didDestroyEnemy(node: enemy)
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    //Default crap
    var lastUpdateTime : TimeInterval = 0
    let displaySize: CGRect = UIScreen.main.bounds
    var screenSize: CGRect?

    var UIOverlay: SKNode = SKNode();
    var turret : SKSpriteNode?
    var touchNode : SKSpriteNode?
    var testNode = SKSpriteNode(color: UIColor.white, size: CGSize(width: 50, height: 50));
    
    
    //enemies
    var rightSpawner: Spawner?
    var leftSpawner: Spawner?
    var lastSpawned: TimeInterval = 10.0
    var spawnDelay: TimeInterval = 4.0
    
    //Weapon
    var currentWeapon: weapon?
    
    var cam: SKCameraNode?

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
        
        
        //Controls
        self.touchNode = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 50, height: 50))
        self.touchNode?.name = "touchNode"
        self.touchNode?.isHidden = true
        self.touchNode?.position = CGPoint(x: 0, y: 0)
        self.UIOverlay.addChild((self.touchNode)!)
        
        //dummy
        self.addChild(testNode)
        self.testNode.zPosition = 10
        self.testNode.position = CGPoint(x: 0, y: 200)

        let w = (screenSize?.width)!
        let h = (screenSize?.height)!
        
        leftSpawner = Spawner(scene: self, position: CGPoint(x: -(w/4), y: h+100), horizontalRange: w/2 - 100)
        rightSpawner = Spawner(scene: self, position: CGPoint(x: (w/4), y: h+100), horizontalRange: w/2 - 100)

        leftSpawner?.initEnemyGroup(type: enemyTypeEnum.FIGHTER, length: 5)
        leftSpawner?.initEnemyGroup(type: enemyTypeEnum.FIGHTER, length: 5)
        leftSpawner?.initEnemyGroup(type: enemyTypeEnum.SUICIDE, length: 5)
        leftSpawner?.initEnemyGroup(type: enemyTypeEnum.LILBASTERD, length: 5)

        rightSpawner?.initEnemyGroup(type: enemyTypeEnum.SUICIDE, length: 5)
        rightSpawner?.initEnemyGroup(type: enemyTypeEnum.LILBASTERD, length: 5)
        rightSpawner?.initEnemyGroup(type: enemyTypeEnum.FIGHTER, length: 5)

        //turret
        turret = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 200, height: 200));
        turret?.position = CGPoint(x: 0, y: 100)
        UIOverlay.addChild(turret!)
        
//        self.currentWeapon = Rifle(scene: self)
//        currentWeapon?.activate()

//        self.currentWeapon = Magnum(scene: self)
//        currentWeapon?.activate()

        self.currentWeapon = Shotgun(scene: self)
        currentWeapon?.activate()
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

            self.currentWeapon?.fire(theta: theta)
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        if let enemy =  contact.bodyA.node as? enemy {
            enemy.destroy()
        } else if let enemy = contact.bodyB.node as? enemy{
            enemy.destroy()
        }
    }
    
    //update funcs
    override func update(_ currentTime: TimeInterval) {
        self.lastUpdateTime = currentTime
        let dt = currentTime - lastSpawned
        if(dt > spawnDelay){
            leftSpawner?.spawnNextGroup(speed: 700)
//            rightSpawner?.spawnNextGroup(duration: 6.0)
            self.lastSpawned = currentTime
        }
        
        if(touchNode?.isHidden == false){
            fire()
        }
        
        
    }
    
    override func didFinishUpdate() {
        self.currentWeapon?.deltaFramesLastFired+=1
    }
}


