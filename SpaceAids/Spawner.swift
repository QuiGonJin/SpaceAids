////
////  Spawner.swift
////  SpaceAids
////
////  Created by Kevin Chen on 1/16/18.
////  Copyright © 2018 KamiKazo. All rights reserved.
////
//
//import Foundation
//import UIKit
//import GameKit
//
//enum enemyTypeEnum {
//    static let SUICIDE:Int = 1
//    static let FIGHTER:Int = 2
//    static let LILBASTERD:Int = 3
//}
//
//class enemyGroup:SKNode, enemy, enemyWatchDelegate {
//    var eventWatch: enemyWatchDelegate?
//    var countActive = 0;
//    var frameSize:CGSize?;
//    var enemySprites:SpriteCollection?;
//    var enemyGroupWatcher:enemyWatchDelegate?;
//    var hp = 0;
//    var domain = 600;
//    var type: Int = 0;
//    
//    
//    override init() {
//        super.init()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    convenience init(collection: SpriteCollection, frameSize: CGSize, delegate: enemyWatchDelegate, type: Int){
//        self.init()
//        
//        
//        self.countActive = collection.spriteCollection.count
//        self.frameSize = frameSize
//        self.enemySprites = collection
//        self.enemyGroupWatcher = delegate
//        self.type = type
//        for sprite in collection.spriteCollection {
//            self.addNodeAsEnemy(node: sprite)
//        }
//    }
//    
//    func spawnGroup(action: SKAction, spacing: TimeInterval, level: Int){
//        for i in 0..<(self.enemySprites?.spriteCollection.count)! {
//            let sprite = self.enemySprites?.spriteCollection[i];
//            var enemy = self.enemySprites?.spriteCollection[i] as! enemy;
//            
//            enemy.hp += level
//            
//            //wrap in run to make duration 0
//            let actionWrapper = SKAction.run {
//                sprite?.isHidden = false
//                sprite?.run(action)
//            }
//
//            if let enemySpecialAction = enemy.action(level: level) {
//            
//                let myAction = SKAction.sequence([
//                    SKAction.wait(forDuration: Double(i) * spacing),
//                    actionWrapper,
//                    enemySpecialAction
//                ])
//
//                sprite?.run(myAction)
//            } else {
//                let spawnAction = SKAction.sequence([
//                    SKAction.wait(forDuration: Double(i) * spacing),
//                    actionWrapper
//                    ])
//                
//                sprite?.run(spawnAction)
//            }
//        }
//    }
//    
//    func addNodeAsEnemy(node: SKSpriteNode){
//        if var enemy = node as? enemy {
//            enemy.eventWatch = self
//        }
//        self.addChild(node)
//    }
//    
//    
//    func reset(){
//        if let sprites = self.enemySprites?.spriteCollection{
//            self.removeFromParent()
//            self.removeAllChildren()
//            self.removeAllActions();
//            self.countActive = sprites.count
//            
//            for sprite in sprites {
//                if let enemy = sprite as? enemy {
//                    enemy.reset()
//                    sprite.position = CGPoint(x: 0, y: 0)
//                    self.addChild(sprite)
//                }
//            }
//        }
//    }
//    
//    func didDestroyEnemy(node: enemy) {
//        if let mNode = node as? SKNode {
//            mNode.removeFromParent();
//            countActive -= 1
//            if(countActive <= 0){
//                enemyGroupWatcher?.didDestroyEnemy(node: self)
//            }
//        };
//    }
//    
//    func action(level: Int) -> SKAction? {
//        return nil
//    }
//    
//    func hit(point: CGPoint, damage: Int) {
//        return
//    }
//    
//    func destroy() {
//        return
//    }
//    
//    func getAction(start: CGPoint, end: CGPoint, domain: CGFloat, duration: TimeInterval) -> SKAction? {
//        return nil
//    }
//}
//
//class Spawner: enemyWatchDelegate{
//    var scene:GameScene;
//    var enemyGroups:[enemyGroup] = [enemyGroup]();
//    var position:CGPoint; //same as top of scene usually
//    var domain:CGFloat;
//    var waveRunDuration: TimeInterval = 5.0;
//    
//    init(scene: GameScene, position: CGPoint, horizontalRange: CGFloat){
//        self.scene = scene;
//        self.position = position;
//        self.domain = horizontalRange;
//    }
//    
//    func addEnemyGroup(collection: SpriteCollection, type: Int){
//        let mSize = CGSize(width: (self.scene.screenSize?.width)!, height: (self.scene.screenSize?.height)!)
//        let g = enemyGroup(collection: collection, frameSize: mSize, delegate: self, type: type)
//        g.position = self.position
//        enemyGroups.append(g)
//    }
//    
//    func initEnemyGroup(type: Int, length: Int){
//        switch type {
//        case enemyTypeEnum.SUICIDE:
//            var sprites = [SKSpriteNode]();
//            for _ in 0..<length {
//                let suicideBomber = SuicideBomber(position: CGPoint(x: 0, y: 0), size: CGSize(width: 140, height: 140), delegate: nil)
//                sprites.append(suicideBomber)
//            }
//            let collection = SpriteCollection(collection: sprites)
//            self.addEnemyGroup(collection: collection, type: type)
//        case enemyTypeEnum.FIGHTER:
//            var sprites = [SKSpriteNode]();
//            for _ in 0..<length {
//                let fighter = Fighter(position: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100), delegate: nil)
//                sprites.append(fighter)
//            }
//            let collection = SpriteCollection(collection: sprites)
//            self.addEnemyGroup(collection: collection, type: type)
//        case enemyTypeEnum.LILBASTERD:
//            var sprites = [SKSpriteNode]();
//            for _ in 0..<length {
//                let basterd = LilBasterd(position: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100), delegate: nil)
//                sprites.append(basterd)
//            }
//            let collection = SpriteCollection(collection: sprites)
//            self.addEnemyGroup(collection: collection, type: type)
//        default:
//            return
//        }
//    }
//    
//    func didDestroyEnemy(node: enemy){
//        if let gNode = node as? enemyGroup {
//            gNode.removeFromParent();
//            gNode.reset();
//            enemyGroups.insert(gNode, at: 0);
//        }
//    }
//
//    func buildPath(type: Int)->CGPath?{
//        if(type == enemyTypeEnum.SUICIDE){
//            let randX = CGFloat(arc4random_uniform(UInt32(domain))) - domain/2
//            let linePath = UIBezierPath()
//            linePath.move(to: CGPoint(x: randX, y: 0))
//            linePath.addLine(to: CGPoint(x: randX, y: -position.y))
//            return linePath.cgPath
//        }
//
//        if(type == enemyTypeEnum.FIGHTER){
//            let rand = arc4random_uniform(3)
//            let smDom = domain - 100
//            
//            if(rand == 0){ //straightCurve
//                let randX = CGFloat(arc4random_uniform(UInt32(smDom))) - smDom/2
//                let bezCurve = UIBezierPath()
//                bezCurve.move(to: CGPoint(x: randX, y: 0))
//                bezCurve.addCurve(to: CGPoint(x:randX, y: -position.y),
//                                  controlPoint1: CGPoint(x: -smDom*1.5, y: -(position.y/2)),
//                                  controlPoint2: CGPoint(x: smDom*1.5, y: -(position.y/2)))
//                return bezCurve.cgPath
//            } else if (rand == 1){ //Outward straightCurve
//                var sign: CGFloat = 1.0
//                if(position.x < 0){
//                    sign = -1 * sign
//                }
//                let randX = CGFloat(arc4random_uniform(UInt32(smDom))) - smDom/2
//                let bezCurve = UIBezierPath()
//                bezCurve.move(to: CGPoint(x: randX, y: 0))
//                bezCurve.addCurve(to: CGPoint(x:randX, y: -position.y),
//                                  controlPoint1: CGPoint(x: sign * smDom*1.5, y: -(position.y/2)),
//                                  controlPoint2: CGPoint(x: -1 * sign * smDom*1.5, y: -(position.y/2)))
//                return bezCurve.cgPath
//            } else if (rand == 2) { //crossCurve
//                var sign:CGFloat = 1
//                var randX = CGFloat(arc4random_uniform(UInt32(smDom/2))) - (smDom/2)
//                if(position.x > 0){
//                    sign = sign * -1
//                }
//                randX = randX * sign
//                let endX = -randX + (sign * smDom)
//                
//                let bezCurve = UIBezierPath()
//                bezCurve.move(to: CGPoint(x: randX, y: 0))
//                bezCurve.addCurve(to: CGPoint(x: endX, y: -position.y),
//                                  controlPoint1: CGPoint(x: randX, y: -(position.y/2)),
//                                  controlPoint2: CGPoint(x: endX, y: -(position.y/2)))
//                return bezCurve.cgPath
//            }
//        }
//
//        if(type == enemyTypeEnum.LILBASTERD){
//            let smDom = domain * 0.1
//            var randX = CGFloat(arc4random_uniform(UInt32(smDom))) - smDom/2
//            if(position.x < 0){
//                randX = randX * -1 - smDom
//                let radius:CGFloat = domain - 100
//                let loopStart = CGPoint(x: randX, y: -(position.y/3));
//                let bezCurve = UIBezierPath()
//                bezCurve.move(to: CGPoint(x: randX, y: 0))
//                bezCurve.addLine(to: CGPoint(x: randX, y: loopStart.y))
//                bezCurve.addArc(withCenter: CGPoint(x: randX + radius, y: loopStart.y), radius: radius, startAngle: CGFloat.pi, endAngle:CGFloat.pi*3, clockwise: true)
//                bezCurve.addLine(to: CGPoint(x: randX, y: -position.y))
//                return bezCurve.cgPath
//            } else {
//                randX = randX + smDom
//                let radius:CGFloat = domain - 100
//                let loopStart = CGPoint(x: randX, y: -(position.y/3));
//                let bezCurve = UIBezierPath()
//                bezCurve.move(to: CGPoint(x: randX, y: 0))
//                bezCurve.addLine(to: CGPoint(x: randX, y: loopStart.y))
//                bezCurve.addArc(withCenter: CGPoint(x: randX - radius, y: loopStart.y), radius: radius, startAngle: CGFloat.pi*2, endAngle:0, clockwise: false)
//                bezCurve.addLine(to: CGPoint(x: randX, y: -position.y))
//                return bezCurve.cgPath
//            }
//        }
//        return nil
//    }
//    
//    
//    func spawnNextGroup(speed: CGFloat, level: Int){
//        guard let group = enemyGroups.popLast() else {
//            print("no groups available")
//            return
//        }
//        
//        let curve = buildPath(type: group.type)
//        
//        self.scene.addChild(group)
//        let action = SKAction.follow(curve!, asOffset: true, orientToPath: true, speed: speed)
//        
//        group.spawnGroup(action: action, spacing: Double(200/speed), level: level)
//    }
//    
//}

