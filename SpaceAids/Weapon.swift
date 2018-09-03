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
    var readyDelay: TimeInterval { get set }
    func fire(theta: CGFloat)
    func reload()
    func activate()
    func deactivate()
    func upgradeDmg()
    func upgradeRoF()
    func reset()
}

class Turret: SKSpriteNode {
    var activeWeapon: weapon?
    var weaponIndex = 0
    var weapons:[weapon] = [weapon]()
    var myScene: GameScene?
    var charge = false;
    var chargeNotActive = true;
    var muzzleSprites: SpriteCollection?;
    var slide: SKSpriteNode?;
    var superchargeEmitter: SKEmitterNode?
    
    override init(texture: SKTexture!, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(scene: GameScene, size: CGSize){
        self.init(texture: Assets.TurretSprite, size: size);

        slide = SKSpriteNode(texture: Assets.SlideSprite, size: size);
        slide?.position = CGPoint(x: 0, y: 0);
        slide?.zPosition = 1;
        slide?.name = "Slide";
        self.addChild(slide!);
        
        self.myScene = scene
        self.name = "Turret"
        self.weapons.append(Rifle(scene: myScene!, turret: self))
        self.weapons.append(Magnum(scene: myScene!, turret: self))
        
        
        var mSprites = [SKSpriteNode]();
        for i in 0..<Assets.muzzleSprites.count {
            let HS = SKSpriteNode(texture : Assets.muzzleSprites[i]);

            HS.zPosition = 2;
            HS.anchorPoint = CGPoint(x: 0.5, y: 0)
            HS.position = self.position;
            HS.isHidden = true;
            
            mSprites.append(HS)
        }
        muzzleSprites = SpriteCollection(collection:mSprites);
        for i in 0..<muzzleSprites!.spriteCollection.count {
            self.addChild(muzzleSprites!.spriteCollection[i])
        }
        
        superchargeEmitter = SKEmitterNode(fileNamed: "Supercharge.sks")
        superchargeEmitter?.isHidden = !self.charge;
        self.addChild(superchargeEmitter!)
        
        self.activeWeapon = self.weapons[0]
        activeWeapon?.activate()
        activeWeapon?.ready = true
    }
    
    func blowback(frames: Int){
        let duration:Double = Double(frames) / (60.0);
        let linePath0 = UIBezierPath()
        linePath0.move(to: CGPoint(x: 0, y: -100))
        linePath0.addLine(to: CGPoint(x: 0, y: 0))
        
        let action = SKAction.follow(linePath0.cgPath, asOffset: false, orientToPath: false, duration: duration);
        if(!self.slide!.hasActions()){
            self.slide?.run(action);
        }
    }
    
    func fire(theta: CGFloat) {
        activeWeapon?.fire(theta: theta)
    }
    
    func renderMuzzleFlare() {
        let HSSprite = self.muzzleSprites?.getNext()
        HSSprite?.isHidden = false
        
        let seq = SKAction.sequence([
            SKAction.wait(forDuration: 0.05),
            SKAction.run({
                HSSprite?.isHidden = true
            })
        ]);
        self.run(seq);
    }
    
    func reset(){
        for wep in weapons {
            wep.reset();
        }
    }
    
    func upgradeDmg(){
        for wep in weapons {
            wep.upgradeDmg();
        }
    }
    
    func upgradeRoF(){
        for wep in weapons {
            wep.upgradeRoF();
        }
    }
    
    func supercharge() {
        self.charge = true;
        superchargeEmitter?.isHidden = !self.charge;
    }
    
    func activateSupercharge(){
        if(self.charge && self.chargeNotActive){
            self.charge = false;
            self.chargeNotActive = false;
            superchargeEmitter?.isHidden = !self.charge;
            
            let seq = SKAction.sequence([
                SKAction.run({
                    self.toggleWeapon();
                }),
                SKAction.wait(forDuration: 6.0),
                SKAction.run({
                    self.toggleWeapon();
                    self.chargeNotActive = true;
                })
            ]);
            self.run(seq);
        }
    }
    
    func toggleWeapon(){
        self.run(SoundMaster.swapWeaponSound)
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
    var turret: Turret
    var projectileSprites: SpriteCollection
    var deltaFramesLastFired = 10
    var ROF:CGFloat = 8
    var damage:Int = 1
    var ammo: Int = 0
    var magazineSize: Int = 30
    var SCAN_LENGTH:CGFloat = 3000
    var ready: Bool = false
    var readyDelay: TimeInterval = 0
    var reloadDelay: TimeInterval = 1.4
    var ROF_level:Double = 0;
    let e = 2.71828;
    let t = -0.01;
    
    init(scene: GameScene, turret: Turret){
        self.SCAN_LENGTH = sqrt(pow(scene.frame.height, 2) + pow(scene.frame.width/2, 2))
        self.scene = scene
        self.turret = turret
        self.ammo = self.magazineSize
        
        //init sprites
        var hitscanSprites = [SKSpriteNode]();
        for i in 0..<Assets.bulletSprites.count {
            let HS = SKSpriteNode(texture: Assets.bulletSprites[i])

            HS.anchorPoint = CGPoint(x: 0.5, y: 1)
            HS.position = CGPoint(x: 0, y: 0)
            HS.isHidden = true
            
            hitscanSprites.append(HS)
        }
        
        projectileSprites = SpriteCollection(collection:hitscanSprites)
        for i in 0..<projectileSprites.spriteCollection.count {
            self.scene.addChild(projectileSprites.spriteCollection[i])
        }
    }
    
    func activate() {
        self.ammo = self.magazineSize
        self.ready = true
    }
    
    func deactivate() {
        self.ready = false
    }
    
    func reset() {
        ROF = 16
        damage = 1
        ROF_level = 0;
    }
    
    func reload() {
        self.ready = false
        self.ammo = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + reloadDelay) {
            self.ready = true
            self.ammo = self.magazineSize
        }
    }

    func upgradeDmg() {
        self.damage += 1;
    }
    
    func upgradeRoF() {
        ROF_level += 1;
        let p = pow(e, t*ROF_level);
        ROF = ROF * CGFloat(p);
    }
    
    //Hitscan Sprites are rendered backwards, starting from target back to their source
    func renderHitscan(angle: CGFloat, start: CGPoint, end: CGPoint){
        let HSSprite = self.projectileSprites.getNext()
        HSSprite?.isHidden = false
        HSSprite?.position = start
        HSSprite?.zRotation = angle
        
        
        let seq = SKAction.sequence([
            SKAction.wait(forDuration: 0.05),
            SKAction.run({
                HSSprite?.isHidden = true
            })
            ]);
        self.turret.run(seq);
    }
    
    func hitscan(angleFromYAxis:CGFloat, start:CGPoint, end:CGPoint){
        deltaFramesLastFired = 0
        
        let action = SKAction.run {
            var hitNode: SKNode?;
            var hitPosition: CGPoint?;
            
            
            self.scene.physicsWorld.enumerateBodies(alongRayStart: start, end: end,
                                               using: { (body, point, normal, stop) in
                                                if(body.categoryBitMask >= BitMasksEnum.BLOCK_CONTACT_BM){
                                                    hitNode = body.node
                                                    hitPosition = point
                                                    stop.pointee = true
                                                }
            }
            )
            
            if let myNode = hitNode {
                if(myNode.name == "CriticalSpot"){
                    self.turret.run(SoundMaster.getCritSound());
                } else {
                    self.turret.run(SoundMaster.getArmorSound());
                }
                
                self.renderHitscan(angle: angleFromYAxis, start: hitPosition!, end: start)
                
                self.handleHitscanEvents(node: hitNode, point: hitPosition)
            } else {
                self.turret.run(SoundMaster.getGunSound());
                self.renderHitscan(angle: angleFromYAxis, start: end, end: start)
            }
        }
        
        let seq = SKAction.sequence([
            SKAction.wait(forDuration: readyDelay),
            action
        ])
        self.turret.run(seq);
    }
    
    func handleHitscanEvents(node: SKNode?, point: CGPoint?){
        if let hitNode = node as? enemy{
            
            //render particles
            if(node!.name == "CriticalSpot"){
                if let emitN = scene.criticalEmitters?.getNext() {
                    let emitNWrap = emitN as! SKEmitterWrapper;
                    
                    emitNWrap.zRotation = self.turret.zRotation;
                    emitNWrap.position = point!
                    emitNWrap.Emitter?.resetSimulation()
                }
            }
            else
            {
                if let emitN = scene.projectileEmitters?.getNext() {
                    let emitNWrap = emitN as! SKEmitterWrapper;
                    
                    emitNWrap.zRotation = self.turret.zRotation;
                    emitNWrap.position = point!
                    emitNWrap.Emitter?.resetSimulation()                }
                
            }
            
            
            hitNode.hit(point: point!, damage: self.damage)
        }
    }
    
    func fire(theta: CGFloat) {
        if(self.ready){
            if(self.ammo > 0){
                if(CGFloat(deltaFramesLastFired) > ROF){
                    self.turret.renderMuzzleFlare();
                    self.turret.blowback(frames: (Int)(ROF));
                    let startPos = self.turret.position
                    let farEndPoint = CGPoint(x: -SCAN_LENGTH*sin(theta) + self.turret.position.x,
                                              y: SCAN_LENGTH*cos(theta) + self.turret.position.y)
                    self.hitscan(angleFromYAxis: theta, start: startPos, end: farEndPoint)
                }
            } else {
                reload()
            }
        }
    }
}


class Magnum: weapon {
    var scene:GameScene
    var turret: Turret
    var projectileSprites: SpriteCollection
    var deltaFramesLastFired = 10
    var ROF:CGFloat = 4
    var damage:Int = 1
    var ammo: Int = 0
    var magazineSize: Int = 30
    var SCAN_LENGTH:CGFloat = 3000
    var ready: Bool = false
    var readyDelay: TimeInterval = 0
    var reloadDelay: TimeInterval = 1.4
    var ROF_level:Double = 0;
    let e = 2.71828;
    let t = -0.01;
    
    
    init(scene: GameScene, turret: Turret){
        self.SCAN_LENGTH = sqrt(pow(scene.frame.height, 2) + pow(scene.frame.width/2, 2))
        self.scene = scene
        self.ammo = self.magazineSize
        self.turret = turret
        //init sprites
        let HS3: SKSpriteNode = SKSpriteNode(color: UIColor.cyan, size: CGSize(width: 20, height: 3000));
        
        var hitscanSprites = [SKSpriteNode]();
        
        HS3.anchorPoint = CGPoint(x: 0.5, y: 1)
        HS3.position = CGPoint(x: 0, y: 0)
        HS3.isHidden = true
        hitscanSprites.append(HS3)
        
        projectileSprites = SpriteCollection(collection:hitscanSprites)
        for i in 0..<projectileSprites.spriteCollection.count {
            self.scene.addChild(projectileSprites.spriteCollection[i])
        }
    }

    
    func activate() {
        self.ammo = self.magazineSize
        self.ready = true
    }
    
    func deactivate() {
        self.ready = false;
    }
    
    func reset() {
        ROF = 9
        damage = 1
        ROF_level = 0;
    }
    
    func reload() {
        self.ready = false
        self.ammo = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + reloadDelay) {
            self.ready = true
            self.ammo = self.magazineSize
        }
    }
    
    func upgradeDmg() {
        self.damage += 1;
    }
    
    func upgradeRoF() {
        ROF_level += 1;
        let p = pow(e, t*ROF_level);
        ROF = ROF * CGFloat(p);
    }
    
    //Hitscan Sprites are rendered backwards, starting from target back to their source
    func renderHitscan(angle: CGFloat, start: CGPoint, end: CGPoint){
        let HSSprite = self.projectileSprites.getNext()
        HSSprite?.isHidden = false
        HSSprite?.position = start
        HSSprite?.zRotation = angle
        
        let seq = SKAction.sequence([
            SKAction.wait(forDuration: 0.05),
            SKAction.run({
                HSSprite?.isHidden = true
            })
            ]);
        self.turret.run(seq);
    }
    
    
    func hitscan(angleFromYAxis:CGFloat, start:CGPoint, end:CGPoint){
        deltaFramesLastFired = 0
        

        var hitNode: SKNode?;
        var hitPosition: CGPoint?;
        
        
        self.scene.physicsWorld.enumerateBodies(alongRayStart: start, end: end,
                                           using:  { (body, point, normal, stop) in
                                            if(body.categoryBitMask >= BitMasksEnum.BLOCK_CONTACT_BM){
                                                self.handleHitscanEvents(node: body.node, point: point)
                                            }
        })
        
        self.turret.run(SoundMaster.getGunSound());
        self.renderHitscan(angle: angleFromYAxis, start: end, end: start)
    }
    
    func handleHitscanEvents(node: SKNode?, point: CGPoint?){
        if let hitNode = node as? enemy{
            
            //render particles
            if(node!.name == "CriticalSpot"){
                self.turret.run(SoundMaster.getCritSound());
                if let emitN = scene.criticalEmitters?.getNext() {
                    let emitNWrap = emitN as! SKEmitterWrapper;
                    
                    emitNWrap.zRotation = self.turret.zRotation;
                    emitNWrap.position = point!
                    emitNWrap.Emitter?.resetSimulation()
                }
            }
            else
            {
                if let emitN = scene.projectileEmitters?.getNext() {
                    let emitNWrap = emitN as! SKEmitterWrapper;
                    
                    emitNWrap.zRotation = self.turret.zRotation;
                    emitNWrap.position = point!
                    emitNWrap.Emitter?.resetSimulation()                }
                
            }

            hitNode.hit(point: point!, damage: self.damage)
        }
    }
    
    
    func fire(theta: CGFloat) {
        if(self.ready){
            if(self.ammo > 0){
                if(CGFloat(deltaFramesLastFired) > ROF){
                    self.turret.renderMuzzleFlare();
                    self.turret.blowback(frames: (Int)(ROF));
                    let startPos = self.turret.position
                    let farEndPoint = CGPoint(x: -SCAN_LENGTH*sin(theta) + self.turret.position.x,
                                              y: SCAN_LENGTH*cos(theta) + self.turret.position.y)
                    self.hitscan(angleFromYAxis: theta, start: startPos, end: farEndPoint)
                }
            } else {
                reload()
            }
        }
    }
}
