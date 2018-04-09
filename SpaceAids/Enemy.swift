//
//  suicideBomber.swift
//  SpaceAids
//
//  Created by Kevin Chen on 1/12/18.
//  Copyright © 2018 KamiKazo. All rights reserved.
//

import Foundation
import UIKit
import GameKit

enum enemyTypeEnum {
    static let SUICIDE:Int = 1
    static let FIGHTER:Int = 2
    static let LILBASTERD:Int = 3
    static let BULLET:Int = 4
    static let POWERUP:Int = 5
    static let CARRIER:Int = 10
}

class CriticalSpot: SKSpriteNode, enemy {
    var hp: Int = 100
    var eventWatch: enemyWatchDelegate?
    
    override init (texture: SKTexture!, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(position: CGPoint, size: CGSize, delegate: enemyWatchDelegate?) {
        self.init(texture: Assets.critSpotSprite);
        self.size = size;
        self.name = "CriticalSpot"
        self.eventWatch = delegate

        //body
        self.position = position
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2)
        self.physicsBody?.isDynamic = false
        
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.categoryBitMask = BitMasksEnum.HIT_CONTACT_BM
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //enemy prototype funcs
    //CriticalSpot is speshul, it doesn't die. Instead, tell watcher it received critical hit
    func hit(point: CGPoint, damage: Int){
        eventWatch?.didDestroyEnemy(node: self, param: "crit,"+String(damage))
    }
    
    //CriticalSpot cannot be destroyed
    func destroy() {
        return
    }
    
    func suicide() -> Int {
        return 0
    }
    
    func reset() {
        return
    }
    
    func action(level: Int) {
    }
}

class SuicideBomber: SKSpriteNode, enemy, enemyWatchDelegate {
    var eventWatch: enemyWatchDelegate?
    let baseHP:Int = 12
    var hp: Int = 0
    
    override init(texture: SKTexture!, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(position: CGPoint, size: CGSize, delegate: enemyWatchDelegate?) {
        self.init(texture: Assets.suicideSprites[0], color: SKColor.clear, size: size);
        
        self.name = "SuicideBomber"
        self.eventWatch = delegate
        self.hp = baseHP
        
        //body
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: size);
        self.physicsBody?.isDynamic = false
        
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.categoryBitMask = BitMasksEnum.HIT_CONTACT_BM
        
        //Crit Spot
        let critSpot = CriticalSpot(position: CGPoint(x: 0, y: size.height/2), size: CGSize(width: 50, height: 50), delegate: self)
        self.addChild(critSpot as SKSpriteNode)
        
    }
    
    //respond to criticalSpot child
    func didDestroyEnemy(node: enemy, param: String?) {
        guard let sNode = node as? SKSpriteNode else {
            return;
        }
        if(sNode.name == "CriticalSpot"){
            guard let msg = param else {
                return;
            }
            let params: [String] = msg.components(separatedBy: ",");
            self.hit(point: CGPoint(x: 0, y: 0), damage: 2 * Int(params[1])!)
        }
    }
    
    func action(level: Int) {
        let f = SKAction.animate(with: Assets.suicideSprites, timePerFrame: 0.5);
        self.run(SKAction.repeatForever(f));
    }
    
    //enemy prototype funcs
    func hit(point: CGPoint, damage: Int){
        if(self.hp > 0 ){
            self.hp -= damage
            if(hp <= 0){
                self.destroy()
            }
        }
    }
    
    func destroy() {
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self, param: "dead,100")
    }
    
    func suicide() -> Int {
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self, param: "suicide,0")
        return 50
    }
    
    
    func reset() {
        self.removeAllActions()
        self.isHidden = true
        self.hp = baseHP
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Fighter: SKSpriteNode, enemy, enemyWatchDelegate {
    var eventWatch: enemyWatchDelegate?
    let baseHP:Int = 9
    var hp: Int = 0
    
    override init(texture: SKTexture!, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(position: CGPoint, size: CGSize, delegate: enemyWatchDelegate?) {
        self.init(texture: Assets.fighterSprites[0], color: SKColor.clear, size: size);
        
        self.name = "Fighter"
        self.eventWatch = delegate
        self.hp = baseHP
        
        //body
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: size);
        self.physicsBody?.isDynamic = false
        
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.categoryBitMask = BitMasksEnum.HIT_CONTACT_BM
        
        //Crit Spot
        let critSpot = CriticalSpot(position: CGPoint(x: 0, y: size.height/2), size: CGSize(width: 50, height: 50), delegate: self)
        self.addChild(critSpot as SKSpriteNode)
    }
    
    func action(level: Int) {

    }
    
    //enemy prototype funcs
    func hit(point: CGPoint, damage: Int){
        if(self.hp > 0 ){
            self.hp -= damage
            if(hp <= 0){
                self.destroy()
            }
        }
    }
    
    //respond to criticalSpot child
    func didDestroyEnemy(node: enemy, param: String?) {
        guard let sNode = node as? SKSpriteNode else {
            return;
        }
        if(sNode.name == "CriticalSpot"){
            guard let msg = param else {
                return;
            }
            let params: [String] = msg.components(separatedBy: ",");
            self.hit(point: CGPoint(x: 0, y: 0), damage: 5 * Int(params[1])!)
        }
    }
    
    func destroy() {
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self, param: "dead,100")
    }
    
    func suicide() -> Int {
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self, param: "suicide,0")
        return 20
    }
    
    
    func reset() {
        self.removeAllActions()
        self.isHidden = true
        self.hp = baseHP
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LilBasterd: SKSpriteNode, enemy, enemyWatchDelegate {
    var eventWatch: enemyWatchDelegate?
    let baseHP:Int = 6
    var hp: Int = 0
    
    override init(texture: SKTexture!, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(position: CGPoint, size: CGSize, delegate: enemyWatchDelegate?) {
        self.init(texture: Assets.lilBasterdSprites[0], color: SKColor.clear, size: size);
        
        self.name = "LilBasterd"
        self.eventWatch = delegate
        self.hp = baseHP
        
        //body
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: size);
        self.physicsBody?.isDynamic = false
        
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.categoryBitMask = BitMasksEnum.HIT_CONTACT_BM
        
        //Crit Spot
        let critSpot = CriticalSpot(position: CGPoint(x: 0, y: size.height/2), size: CGSize(width: 50, height: 50), delegate: self)
        self.addChild(critSpot as SKSpriteNode)
    }
    
    //enemy prototype funcs
    func hit(point: CGPoint, damage: Int){
        if(self.hp > 0 ){
            self.hp -= damage
            if(hp <= 0){
                self.destroy()
            }
        }
    }
    
    //respond to criticalSpot child
    func didDestroyEnemy(node: enemy, param: String?) {
        guard let sNode = node as? SKSpriteNode else {
            return;
        }
        if(sNode.name == "CriticalSpot"){
            guard let msg = param else {
                return;
            }
            let params: [String] = msg.components(separatedBy: ",");
            self.hit(point: CGPoint(x: 0, y: 0), damage: 5 * Int(params[1])!)
        }
    }
    
    func action(level: Int) {
        
    }
    
    func destroy() {
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self, param: "dead,100")
    }
    
    func suicide() -> Int {
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self, param: "suicide,0")
        return 20
    }
    
    func reset() {
        self.removeAllActions()
        self.isHidden = true
        self.hp = baseHP
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class Bullet: SKSpriteNode, enemy, enemyWatchDelegate {
    var eventWatch: enemyWatchDelegate?
    let baseHP:Int = 1
    var hp: Int = 0
    
    override init(texture: SKTexture!, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(position: CGPoint, size: CGSize, delegate: enemyWatchDelegate?) {
        self.init(texture:nil, color: UIColor.purple, size: size)
        self.name = "Bullet"
        self.eventWatch = delegate
        self.hp = baseHP
        
        //body
        self.position = position
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width/2);
        self.physicsBody?.isDynamic = false
        
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.categoryBitMask = BitMasksEnum.HIT_CONTACT_BM
    }
    
    //enemy prototype funcs
    func hit(point: CGPoint, damage: Int){
        if(self.hp > 0 ){
            self.hp -= damage
            if(hp <= 0){
                self.destroy()
            }
        }
    }
    
    //respond to criticalSpot child
    func didDestroyEnemy(node: enemy, param: String?) {
        guard let sNode = node as? SKSpriteNode else {
            return;
        }
        if(sNode.name == "CriticalSpot"){
            guard let msg = param else {
                return;
            }
            let params: [String] = msg.components(separatedBy: ",");
            self.hit(point: CGPoint(x: 0, y: 0), damage: 5 * Int(params[1])!)
        }
    }
    
    func action(level: Int) {
    }
    
    func destroy() {
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self, param: "dead,20")
//        mainScene?.enemyDestroyed(node: self, points: 10)
    }
    
    func suicide() -> Int {
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self, param: "suicide,0")
        return 10
    }
    
    func reset() {
        self.isHidden = false
        self.hp = baseHP
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Carrier: SKSpriteNode, enemy, enemyWatchDelegate {
    var eventWatch: enemyWatchDelegate?
    let baseHP:Int = 50
    var hp: Int = 0
    
    override init(texture: SKTexture!, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(position: CGPoint, size: CGSize, delegate: enemyWatchDelegate?) {
        self.init(texture: Assets.lilBasterdSprites[0], color: SKColor.clear, size: size);
        self.name = "Carrier"
        self.eventWatch = delegate
        self.hp = baseHP
        
        //body
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOf: size);
        self.physicsBody?.isDynamic = false
        
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.categoryBitMask = BitMasksEnum.HIT_CONTACT_BM
        
        //Crit Spot
        let critSpot = CriticalSpot(position: CGPoint(x: 0, y: -size.height/2), size: CGSize(width: 100, height: 100), delegate: self)
        self.addChild(critSpot as SKSpriteNode)
    }
    
    //respond to criticalSpot child
    func didDestroyEnemy(node: enemy, param: String?) {
        guard let sNode = node as? SKSpriteNode else {
            return;
        }
        if(sNode.name == "CriticalSpot"){
            guard let msg = param else {
                return;
            }
            let params: [String] = msg.components(separatedBy: ",");
            self.hit(point: CGPoint(x: 0, y: 0), damage: 2 * Int(params[1])!)
        }
    }
    
    func carrierSpawn(count: Int, speed: Int){
        if let msSpawn = mainScene?.spawner {
            let linePath0 = UIBezierPath()
            linePath0.move(to: CGPoint(x:0, y: 0))
            linePath0.addLine(to: CGPoint(x: 0, y: -3000))
            
            let spawnDelay : Double = 0.300;
            let mSprites = msSpawn.buildWave(type: 4, count: count);
            
            for i in 0..<mSprites.count {
                let action = SKAction.follow(linePath0.cgPath, asOffset: true, orientToPath: true, speed: CGFloat(speed))
                let mySprite = mSprites[i];
                var e = mSprites[i] as! enemy;
                e.hp = 1
                
                let group = SKAction.group([
                    action,
                    SKAction.run({
                        mySprite.isHidden = false;
                    })
                    ])
                
                let sequence = SKAction.sequence([
                    SKAction.wait(forDuration: spawnDelay * Double(i)),
                    SKAction.run({
                        mySprite.position = self.position;
                        msSpawn.addChild(mySprite);
                        mySprite.run(group);
                    })
                    ]);
                self.run(sequence);
            }
        }
    }
    
    func action(level: Int) {

        
        let seq = SKAction.sequence([
                SKAction.wait(forDuration: 3),
                SKAction.run({
                    self.carrierSpawn(count: 5, speed: 300)
                })
         ]);
        
        let rep = SKAction.repeatForever(seq);
        
        self.run(rep);
    }
    
    //enemy prototype funcs
    func hit(point: CGPoint, damage: Int){
        if(self.hp > 0 ){
            self.hp -= damage
            if(hp <= 0){
                self.destroy()
            }
        }
    }
    
    func destroy() {
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self, param: "dead,500");
    }
    
    func suicide() -> Int{
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self, param: "suicide,0");
        return 50
    }
    
    func reset() {
        self.removeAllActions()
        self.isHidden = true
        self.hp = baseHP
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PowerUp: SKSpriteNode, enemy, enemyWatchDelegate {
    var eventWatch: enemyWatchDelegate?
    let baseHP: Int = 1
    var hp: Int = 0
    var type: Int = 0;
    var sprites: [UIColor] = [UIColor]();
    
    override init(texture: SKTexture!, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(position: CGPoint, size: CGSize, delegate: enemyWatchDelegate?) {
        self.init(texture:nil, color: UIColor.gray, size: size)
        self.name = "PowerUp"
        self.eventWatch = delegate
        self.hp = baseHP
        
        sprites.append(UIColor.blue);
        sprites.append(UIColor.red);
        sprites.append(UIColor.green);
        sprites.append(UIColor.yellow);
        
        self.color = sprites[type];
        
        //body
        self.position = position
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width/2);
        self.physicsBody?.isDynamic = false
        
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.categoryBitMask = BitMasksEnum.HIT_CONTACT_BM
    }
    
    //enemy prototype funcs
    func hit(point: CGPoint, damage: Int){
        if(self.hp > 0 ){
            self.hp -= damage
            if(hp <= 0){
                self.destroy()
            }
        }
    }
    
    //respond to criticalSpot child
    func didDestroyEnemy(node: enemy, param: String?) {
        guard let sNode = node as? SKSpriteNode else {
            return;
        }
        if(sNode.name == "CriticalSpot"){
            guard let msg = param else {
                return;
            }
            let params: [String] = msg.components(separatedBy: ",");
            self.hit(point: CGPoint(x: 0, y: 0), damage: 5 * Int(params[1])!)
        }
    }
    
    func action(level: Int) {
        let seq = SKAction.sequence([
            SKAction.wait(forDuration: 0.50),
            SKAction.run({
                self.type += 1;
                let index = self.type % self.sprites.count;
                self.color = self.sprites[index]
            })
        ])
        self.run(SKAction.repeatForever(seq));
    }
    
    func destroy() {
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self, param: "power,"+String(self.type % self.sprites.count))
    }
    
    func suicide() -> Int {
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self, param: "suicide,0")
        return 0
    }

    func reset() {
        self.isHidden = false
        self.hp = baseHP
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





