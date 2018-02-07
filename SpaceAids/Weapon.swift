//
//  Weapon.swift
//  SpaceAids
//
//  Created by Kevin Chen on 1/30/18.
//  Copyright © 2018 KamiKazo. All rights reserved.
//

import Foundation
import UIKit
import GameKit

protocol weapon {
    var projectileSprites: SpriteCollection { get set }
    var deltaFramesLastFired: Int { get set }
    var ROF: CGFloat { get set }
    var damage: Int { get set }
    func fire(theta: CGFloat)
    func activate()
    func deactivate()
}


class Rifle: weapon {
    var scene:GameScene
    var projectileSprites: SpriteCollection
    var deltaFramesLastFired = 10
    var ROF:CGFloat = 7.33
    var damage:Int = 1
    var SCAN_LENGTH:CGFloat = 3000
    init(scene: GameScene){
        self.SCAN_LENGTH = sqrt(pow(scene.frame.height, 2) + pow(scene.frame.width/2, 2))
        self.scene = scene
        //init sprites
        let HS1: SKSpriteNode = SKSpriteNode(color: UIColor.green, size: CGSize(width: 5, height: 3000));
        let HS2: SKSpriteNode = SKSpriteNode(color: UIColor.cyan, size: CGSize(width: 5, height: 3000));
        let HS3: SKSpriteNode = SKSpriteNode(color: UIColor.yellow, size: CGSize(width: 5, height: 3000));
        
        var hitscanSprites = [SKSpriteNode]();
        HS1.anchorPoint = CGPoint(x: 0.5, y: 1)
        HS1.position = CGPoint(x: 0, y: 0)
        HS1.isHidden = true
        hitscanSprites.append(HS1)

        
        HS2.anchorPoint = CGPoint(x: 0.5, y: 1)
        HS2.position = CGPoint(x: 0, y: 0)
        HS2.isHidden = false
        hitscanSprites.append(HS2)
        
        HS3.anchorPoint = CGPoint(x: 0.5, y: 1)
        HS3.position = CGPoint(x: 0, y: 0)
        HS3.isHidden = true
        hitscanSprites.append(HS3)
        
        projectileSprites = SpriteCollection(collection:hitscanSprites)
    }
    
    func activate() {
        for i in 0..<projectileSprites.spriteCollection.count {
            self.scene.addChild(projectileSprites.spriteCollection[i])
        }
    }
    
    func deactivate() {
        for i in 0..<projectileSprites.spriteCollection.count {
            projectileSprites.spriteCollection[i].removeFromParent()
        }
    }

    //Hitscan Sprites are rendered backwards, starting from target back to their source
    func renderHitscan(angle: CGFloat, start: CGPoint, end: CGPoint){
        let HSSprite = self.projectileSprites.getNext()
        HSSprite?.isHidden = false
        HSSprite?.position = start
        HSSprite?.zRotation = angle
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            HSSprite?.isHidden = true
        }
    }
    
    func hitscan(angleFromYAxis:CGFloat, start:CGPoint, end:CGPoint){
        var hitNode: SKNode?;
        var hitPosition: CGPoint?;
        
        scene.physicsWorld.enumerateBodies(alongRayStart: start, end: end,
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
        
        deltaFramesLastFired = 0
    }
    
    func handleHitscanEvents(node: SKNode?, point: CGPoint?){
        if let hitNode = node as? enemy{
            hitNode.hit(point: point!, damage: self.damage)
        }
    }
    
    func fire(theta: CGFloat) {
        if(CGFloat(deltaFramesLastFired) > ROF){
            let farEndPoint = CGPoint(x: -SCAN_LENGTH*sin(theta) + scene.turret!.position.x,
                                      y: SCAN_LENGTH*cos(theta) + scene.turret!.position.y)
            self.hitscan(angleFromYAxis: theta, start: (scene.turret?.position)!, end: farEndPoint)
        }
        
    }
}


class Magnum: weapon {
    var scene:GameScene
    var projectileSprites: SpriteCollection
    var deltaFramesLastFired = 100
    var ROF:CGFloat = 60
    var damage:Int = 6
    var SCAN_LENGTH:CGFloat = 3000
    init(scene: GameScene){
        self.SCAN_LENGTH = sqrt(pow(scene.frame.height, 2) + pow(scene.frame.width/2, 2))
        self.scene = scene
        //init sprites
        let HS3: SKSpriteNode = SKSpriteNode(color: UIColor.yellow, size: CGSize(width: 10, height: 3000));
        
        var hitscanSprites = [SKSpriteNode]();
        
        HS3.anchorPoint = CGPoint(x: 0.5, y: 1)
        HS3.position = CGPoint(x: 0, y: 0)
        HS3.isHidden = true
        hitscanSprites.append(HS3)
        
        projectileSprites = SpriteCollection(collection:hitscanSprites)
    }
    
    func activate() {
        for i in 0..<projectileSprites.spriteCollection.count {
            self.scene.addChild(projectileSprites.spriteCollection[i])
        }
    }
    
    func deactivate() {
        for i in 0..<projectileSprites.spriteCollection.count {
            projectileSprites.spriteCollection[i].removeFromParent()
        }
    }
    
    //Hitscan Sprites are rendered backwards, starting from target back to their source
    func renderHitscan(angle: CGFloat, start: CGPoint, end: CGPoint){
        let HSSprite = self.projectileSprites.getNext()
        HSSprite?.isHidden = false
        HSSprite?.position = start
        HSSprite?.zRotation = angle
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            HSSprite?.isHidden = true
        }
    }
    
    func hitscan(angleFromYAxis:CGFloat, start:CGPoint, end:CGPoint){
        scene.physicsWorld.enumerateBodies(alongRayStart: start, end: end,
            using:  { (body, point, normal, stop) in
                    if(body.categoryBitMask >= BitMasksEnum.BLOCK_CONTACT_BM){
                        self.handleHitscanEvents(node: body.node, point: point)
                    }
            }
        )
    
       self.renderHitscan(angle: angleFromYAxis, start: end, end: start)
        deltaFramesLastFired = 0
    }
    
    func handleHitscanEvents(node: SKNode?, point: CGPoint?){
        if let hitNode = node as? enemy{
            hitNode.hit(point: point!, damage: self.damage)
        }
    }
    
    func fire(theta: CGFloat) {
        if(CGFloat(deltaFramesLastFired) > ROF){
            let farEndPoint = CGPoint(x: -SCAN_LENGTH*sin(theta) + scene.turret!.position.x,
                                      y: SCAN_LENGTH*cos(theta) + scene.turret!.position.y)
            self.hitscan(angleFromYAxis: theta, start: (scene.turret?.position)!, end: farEndPoint)
        }
        
    }
    
}


class Shotgun: weapon {
    var scene:GameScene
    var projectileSprites: SpriteCollection
    var deltaFramesLastFired = 100
    var ROF:CGFloat = 30
    var damage:Int = 3
    var numShots: Int = 8
    var spread: CGFloat = 0.4
    var SCAN_LENGTH:CGFloat = 3000
    init(scene: GameScene){
        self.SCAN_LENGTH = sqrt(pow(scene.frame.height, 2) + pow(scene.frame.width/2, 2))
        self.scene = scene
        //init sprites
        var hitscanSprites = [SKSpriteNode]();
        
        for _ in 0..<numShots {
            let HS: SKSpriteNode = SKSpriteNode(color: UIColor.red, size: CGSize(width: 5, height: 3000));
            
            HS.anchorPoint = CGPoint(x: 0.5, y: 1)
            HS.position = CGPoint(x: 0, y: 0)
            HS.isHidden = true
            hitscanSprites.append(HS)
        }
        
        projectileSprites = SpriteCollection(collection:hitscanSprites)
    }
    
    func activate() {
        for i in 0..<projectileSprites.spriteCollection.count {
            self.scene.addChild(projectileSprites.spriteCollection[i])
        }
    }
    
    func deactivate() {
        for i in 0..<projectileSprites.spriteCollection.count {
            projectileSprites.spriteCollection[i].removeFromParent()
        }
    }
    
    //Hitscan Sprites are rendered backwards, starting from target back to their source
    func renderHitscan(angle: CGFloat, start: CGPoint, end: CGPoint){
        let HSSprite = self.projectileSprites.getNext()
        HSSprite?.isHidden = false
        HSSprite?.position = start
        HSSprite?.zRotation = angle
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            HSSprite?.isHidden = true
        }
    }
    
    func hitscan(angleFromYAxis:CGFloat, start:CGPoint, end:CGPoint){
        var hitNode: SKNode?;
        var hitPosition: CGPoint?;
        
        scene.physicsWorld.enumerateBodies(alongRayStart: start, end: end,
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
        
        deltaFramesLastFired = 0
    }
    
    func handleHitscanEvents(node: SKNode?, point: CGPoint?){
        if let hitNode = node as? enemy{
            hitNode.hit(point: point!, damage: self.damage)
        }
    }
    
    func fire(theta: CGFloat) {
        if(CGFloat(deltaFramesLastFired) > ROF){
            let deltaTheta = spread / CGFloat(numShots - 1)
            let minTheta = theta - (spread / 2)
            for i in 0..<numShots {
                let shotTheta = minTheta + (CGFloat(i) * deltaTheta)
                
                let farEndPoint = CGPoint(x: -SCAN_LENGTH*sin(shotTheta) + scene.turret!.position.x,
                                          y: SCAN_LENGTH*cos(shotTheta) + scene.turret!.position.y)
                self.hitscan(angleFromYAxis: shotTheta, start: (scene.turret?.position)!, end: farEndPoint)
            }
            
            
//            let farEndPoint1 = CGPoint(x: -SCAN_LENGTH*sin(theta) + scene.turret!.position.x,
//                                      y: SCAN_LENGTH*cos(theta) + scene.turret!.position.y)
//            self.hitscan(angleFromYAxis: theta, start: (scene.turret?.position)!, end: farEndPoint1)
//
//            let farEndPoint2 = CGPoint(x: -SCAN_LENGTH*sin(theta+0.5) + scene.turret!.position.x,
//                                       y: SCAN_LENGTH*cos(theta+0.5) + scene.turret!.position.y)
//            self.hitscan(angleFromYAxis: theta+0.5, start: (scene.turret?.position)!, end: farEndPoint2)
//
//            let farEndPoint3 = CGPoint(x: -SCAN_LENGTH*sin(theta-0.5) + scene.turret!.position.x,
//                                       y: SCAN_LENGTH*cos(theta-0.5) + scene.turret!.position.y)
//            self.hitscan(angleFromYAxis: theta-0.5, start: (scene.turret?.position)!, end: farEndPoint3)
        }
        
    }
    
}
