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
    //hitscan
    var deltaFrames = 0
    var ROF:Int = 6 //frames : scan
    var SCAN_LENGTH:CGFloat = 3000
    var damage = 1
    
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
    
    //Bullet Sprites... so cancer
//    var hitscanSprite: SKSpriteNode?
    var hitscanCollection:SpriteCollection?
    var renderHS: Bool = false;
    var HSIndex: Int = 0;
    
    var cam: SKCameraNode?

    override init(size: CGSize) {
        super.init(size: CGSize(width: size.width, height: size.height))
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0);
        self.physicsWorld.contactDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        //default crap
        self.lastUpdateTime = 0
        screenSize = getVisibleScreen(sceneWidth: self.frame.width, sceneHeight: self.frame.height, viewWidth: UIScreen.main.bounds.width, viewHeight: UIScreen.main.bounds.height)
        
        self.SCAN_LENGTH = sqrt(pow(self.frame.height, 2) + pow(self.frame.width/2, 2))
        
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
        leftSpawner?.initEnemyGroup(type: enemyTypeEnum.SUICIDE, length: 5)
        leftSpawner?.initEnemyGroup(type: enemyTypeEnum.LILBASTERD, length: 5)

        rightSpawner?.initEnemyGroup(type: enemyTypeEnum.SUICIDE, length: 5)
        rightSpawner?.initEnemyGroup(type: enemyTypeEnum.LILBASTERD, length: 5)
        rightSpawner?.initEnemyGroup(type: enemyTypeEnum.FIGHTER, length: 5)

        //turret
        turret = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 200, height: 200));
        turret?.position = CGPoint(x: 0, y: 100)
        UIOverlay.addChild(turret!)

        let HS1: SKSpriteNode = SKSpriteNode(color: UIColor.green, size: CGSize(width: 5, height: 3000));
        let HS2: SKSpriteNode = SKSpriteNode(color: UIColor.cyan, size: CGSize(width: 5, height: 3000));
        let HS3: SKSpriteNode = SKSpriteNode(color: UIColor.yellow, size: CGSize(width: 5, height: 3000));
        
        var hitscanSprites = [SKSpriteNode]();
        HS1.anchorPoint = CGPoint(x: 0.5, y: 1)
        HS1.position = CGPoint(x: 0, y: 0)
        HS1.isHidden = true
        hitscanSprites.append(HS1)
        self.addChild(hitscanSprites[0])
        
        HS2.anchorPoint = CGPoint(x: 0.5, y: 1)
        HS2.position = CGPoint(x: 0, y: 0)
        HS2.isHidden = false
        hitscanSprites.append(HS2)
        self.addChild(hitscanSprites[1])
        
        HS3.anchorPoint = CGPoint(x: 0.5, y: 1)
        HS3.position = CGPoint(x: 0, y: 0)
        HS3.isHidden = true
        hitscanSprites.append(HS3)
        self.addChild(hitscanSprites[2])
        hitscanCollection = SpriteCollection(collection:hitscanSprites)
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
           
            let farEndPoint = CGPoint(x: -SCAN_LENGTH*sin(theta) + turret!.position.x, y: SCAN_LENGTH*cos(theta) + turret!.position.y)
            self.turret?.zRotation = theta
            
            if(deltaFrames > ROF){
                self.hitscan(angleFromYAxis: theta, start: (self.turret?.position)!, end: farEndPoint)
            }
        }
    }
    
    func hitscan(angleFromYAxis:CGFloat, start:CGPoint, end:CGPoint){
        var hitNode: SKNode?;
        var hitPosition: CGPoint?;
        
        self.physicsWorld.enumerateBodies(alongRayStart: start, end: end,
              using: { (body, point, normal, stop) in
                if(body.categoryBitMask >= BitMasksEnum.BLOCK_CONTACT_BM){
                    hitNode = body.node
                    hitPosition = point
                    stop.pointee = true
                }
            }
        )
        if let _ = hitNode {
            self.renderHitscan(angle: angleFromYAxis, start: hitPosition!, end: start)
            self.handleHitscanEvents(node: hitNode, point: hitPosition)
        } else {
            self.renderHitscan(angle: angleFromYAxis, start: end, end: start)
        }

        self.deltaFrames = 0
    }
    
    func handleHitscanEvents(node: SKNode?, point: CGPoint?){
        if let hitNode = node as? enemy{         
            hitNode.hit(point: point!, damage: self.damage)
        }
    }

    //Hitscan Sprites are rendered backwards, starting from target back to their source
    func renderHitscan(angle: CGFloat, start: CGPoint, end: CGPoint){
        let HSSprite = hitscanCollection?.getNext()
        HSSprite?.isHidden = false
        HSSprite?.position = start
        HSSprite?.zRotation = angle
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            HSSprite?.isHidden = true
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
            leftSpawner?.spawnNextGroup(duration: 6.0)
//            rightSpawner?.spawnNextGroup(duration: 6.0)
            self.lastSpawned = currentTime
        }
        
        if(touchNode?.isHidden == false){
            fire()
        }
        
        
    }
    
    override func didFinishUpdate() {
        deltaFrames+=1
    }
}


