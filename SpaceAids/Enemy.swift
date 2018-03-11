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
        self.init(texture:nil, color: UIColor.yellow, size: size)
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
        self.init(texture:nil, color: UIColor.blue, size: size)
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
            self.hit(point: CGPoint(x: 0, y: 0), damage: 5 * Int(params[1])!)
        }
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
    
    func destroy() {
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self, param: "dead,100")
        
//        mainScene?.enemyDestroyed(node: self, points: 100)
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
        self.init(texture:nil, color: UIColor.green, size: size)
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
        
//        mainScene?.enemyDestroyed(node: self, points: 100)
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
        self.init(texture:nil, color: UIColor.cyan, size: size)
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
        
//        mainScene?.enemyDestroyed(node: self, points: 100)
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
        self.removeFromParent()
        eventWatch?.didDestroyEnemy(node: self, param: "dead,10")
        
//        mainScene?.enemyDestroyed(node: self, points: 10)
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
    var spawner: EnemyGenerator = EnemyGenerator(position: CGPoint(x: 0, y: 0), horizontalRange: 0);
    
    override init(texture: SKTexture!, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        spawner.position = CGPoint(x: -self.size.width/2, y: 0);
        spawner.domain = self.size.width;
        spawner.range = -3000;
        spawner.paths = [CGPath]();
        spawner.initPaths();
        spawner.loadLevel("carrier");
        self.addChild(spawner);
    }
    
    convenience init(position: CGPoint, size: CGSize, delegate: enemyWatchDelegate?) {
        self.init(texture:nil, color: UIColor.gray, size: size)
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
            self.hit(point: CGPoint(x: 0, y: 0), damage: 5 * Int(params[1])!)
        }
    }
    
    func action(level: Int) {
        spawner.spawnLevel();
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
        self.spawner.removeAllActions();
        self.spawner.removeAllChildren();
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self, param: "dead,1000");
        
//        mainScene?.enemyDestroyed(node: self, points: 1000)
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
        
        sprites.append(UIColor.yellow);
        sprites.append(UIColor.blue);
        sprites.append(UIColor.red);
        sprites.append(UIColor.green);
        
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
            SKAction.wait(forDuration: 1.0),
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
        self.removeFromParent()
        eventWatch?.didDestroyEnemy(node: self, param: "power,"+String(type))
    }
    
    func reset() {
        self.isHidden = false
        self.hp = baseHP
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





