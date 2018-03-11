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
    var ready: Bool { get set }
    var damage: Int { get set }
    var ammo: Int { get set }
    func fire(theta: CGFloat)
    func reload()
    func activate()
    func deactivate()
}

class Turret: SKSpriteNode {
    var activeWeapon: weapon?
    var weaponIndex = 0
    var weapons:[weapon] = [weapon]()
    var myScene: GameScene?
    
    override init(texture: SKTexture!, color: SKColor, size: CGSize) {
        super.init(texture: nil, color: color, size: size)
    }
    
    convenience init(scene: GameScene, size: CGSize){
        self.init(texture: nil, color: UIColor.blue, size: size)
        self.myScene = scene
        self.name = "Turret"
        self.weapons.append(Rifle(scene: myScene!, turret: self))
        self.weapons.append(Magnum(scene: myScene!, turret: self))
        
        self.activeWeapon = self.weapons[0]
        activeWeapon?.activate()
        activeWeapon?.ready = true
    }
    
    func toggleWeapon(){
        weaponIndex += 1
        if(weaponIndex >= weapons.count){
            weaponIndex = 0
        }
        activeWeapon?.deactivate()
        activeWeapon = weapons[weaponIndex]
        activeWeapon?.activate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Rifle: weapon {
    var scene:GameScene
    var turret: SKNode
    var projectileSprites: SpriteCollection
    var deltaFramesLastFired = 10
    var ROF:CGFloat = 8.33
    var damage:Int = 1
    var ammo: Int = 0
    var magazineSize: Int = 30
    var SCAN_LENGTH:CGFloat = 3000
    var ready: Bool = false
    var readyDelay: TimeInterval = 1.0
    var reloadDelay: TimeInterval = 1.4
    init(scene: GameScene, turret: SKNode){
        self.SCAN_LENGTH = sqrt(pow(scene.frame.height, 2) + pow(scene.frame.width/2, 2))
        self.scene = scene
        self.turret = turret
        self.ammo = self.magazineSize
        //init sprites
        
        var hitscanSprites = [SKSpriteNode]();
        
        for _ in 0..<3 {
            let HS = SKSpriteNode(color: UIColor.green, size: CGSize(width: 5, height: 3000));
            
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
        
        self.ammo = self.magazineSize
        DispatchQueue.main.asyncAfter(deadline: .now() + readyDelay) {
            self.ready = true
        }
    }
    
    func deactivate() {
        for i in 0..<projectileSprites.spriteCollection.count {
            projectileSprites.spriteCollection[i].removeFromParent()
        }
        self.ready = false
    }
    
    func reload() {
        self.ready = false
        self.ammo = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + reloadDelay) {
            self.ready = true
            self.ammo = self.magazineSize
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
        if(self.ready){
            if(self.ammo > 0){
                if(CGFloat(deltaFramesLastFired) > ROF){
                    let startPos = self.turret.position
                    print(startPos)
                    let farEndPoint = CGPoint(x: -SCAN_LENGTH*sin(theta) + self.turret.position.x,
                                              y: SCAN_LENGTH*cos(theta) + self.turret.position.y)
                    self.hitscan(angleFromYAxis: theta, start: startPos, end: farEndPoint)
//                    self.ammo -= 1
                }
            } else {
                reload()
            }
        }
    }
}


class Magnum: weapon {
    var scene:GameScene
    var projectileSprites: SpriteCollection
    var deltaFramesLastFired = 100
    var ROF:CGFloat = 30
    var damage:Int = 6
    var SCAN_LENGTH:CGFloat = 3000
    var ready: Bool = false
    var readyDelay: TimeInterval = 0.4
    var reloadDelay: TimeInterval = 1.8
    var turret: SKNode
    var ammo = 0
    var magazineSize = 6
    
    init(scene: GameScene, turret: SKNode){
        self.SCAN_LENGTH = sqrt(pow(scene.frame.height, 2) + pow(scene.frame.width/2, 2))
        self.scene = scene
        self.ammo = self.magazineSize
        self.turret = turret
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
        
        self.ammo = self.magazineSize
        DispatchQueue.main.asyncAfter(deadline: .now() + readyDelay) {
            self.ready = true
        }
    }
    
    func deactivate() {
        for i in 0..<projectileSprites.spriteCollection.count {
            projectileSprites.spriteCollection[i].removeFromParent()
        }
    }
    
    func reload() {
        self.ready = false
        self.ammo = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + reloadDelay) {
            self.ready = true
            self.ammo = self.magazineSize
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
        if(self.ready){
            if(self.ammo > 0){
                if(CGFloat(deltaFramesLastFired) > ROF){
                    let startPos = self.turret.position
                    print(startPos)
                    let farEndPoint = CGPoint(x: -SCAN_LENGTH*sin(theta) + self.turret.position.x,
                                              y: SCAN_LENGTH*cos(theta) + self.turret.position.y)
                    self.hitscan(angleFromYAxis: theta, start: startPos, end: farEndPoint)
//                    self.ammo -= 1
                }
            } else {
                reload()
            }
        }
    }
}
