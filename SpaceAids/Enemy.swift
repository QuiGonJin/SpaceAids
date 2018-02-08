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
        eventWatch?.didDestroyEnemy(node: self)
    }
    
    //CriticalSpot cannot be destroyed
    func destroy() {
        return
    }
    
    func reset() {
        return
    }
    
    func action(level: Int) -> SKAction? {
        return nil
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
    func didDestroyEnemy(node: enemy) {
        guard let sNode = node as? SKSpriteNode else {
            return;
        }
        if(sNode.name == "CriticalSpot"){
            self.hit(point: CGPoint(x: 0, y: 0), damage: 3)
        }
    }
    
    func action(level: Int) -> SKAction? {
        return nil
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
        eventWatch?.didDestroyEnemy(node: self)
        
        mainScene?.enemyDestroyed(node: self, points: 100)
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
    
    func action(level: Int)->SKAction?{

        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 0, y: 0))
        linePath.addLine(to: CGPoint(x: 0, y: -3000))
        
        let action = SKAction.run({
            //get this node's position inside of enemyGroup relative to gamescene
            let p = self.parent?.convert(self.position, to: (mainScene)!)
            
            let bullet: Bullet = Bullet(position: p!, size: CGSize(width: 75, height: 75), delegate: nil)
            let action = SKAction.follow(linePath.cgPath, asOffset: true, orientToPath: false, speed: 500)
            
            let delete = SKAction.run({
                bullet.destroy()
            })
            
            let seq = SKAction.sequence([
                    action,
                    delete
            ])
            bullet.run(seq)
            mainScene?.addChild(bullet)
        });
        
        let seq = SKAction.sequence([
                SKAction.wait(forDuration: 1),
                action
            ]);
        
        return seq
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
    func didDestroyEnemy(node: enemy) {
        guard let sNode = node as? SKSpriteNode else {
            return;
        }
        if(sNode.name == "CriticalSpot"){
            self.hit(point: CGPoint(x: 0, y: 0), damage: 3)
        }
    }
    
    func destroy() {
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self)
        
        mainScene?.enemyDestroyed(node: self, points: 100)
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
    func didDestroyEnemy(node: enemy) {
        guard let sNode = node as? SKSpriteNode else {
            return;
        }
        if(sNode.name == "CriticalSpot"){
            self.hit(point: CGPoint(x: 0, y: 0), damage: 3)
        }
    }
    
    func action(level: Int)->SKAction?{
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 0, y: 0))
        linePath.addLine(to: CGPoint(x: 0, y: -3000))
        
        let bulletSpeed = 500 + (CGFloat(level) * 20)
        
        let action = SKAction.run({
            //get this node's position inside of enemyGroup relative to gamescene
            let p = self.parent?.convert(self.position, to: (mainScene)!)
            
            let bullet: Bullet = Bullet(position: p!, size: CGSize(width: 75, height: 75), delegate: nil)
            let action = SKAction.follow(linePath.cgPath, asOffset: true, orientToPath: false, speed: bulletSpeed)
            
            let delete = SKAction.run({
                bullet.destroy()
            })
            
            let seq = SKAction.sequence([
                action,
                delete
                ])
            bullet.run(seq)
            mainScene?.addChild(bullet)
        });
        
        let randDuration = ( CGFloat(arc4random_uniform(101)) / 100 ) * 3
        
        let fireLoop = SKAction.repeat(SKAction.sequence([
                SKAction.wait(forDuration: Double(250/bulletSpeed)),
                action
            ]), count: level)
        
        let seq = SKAction.sequence([
            SKAction.wait(forDuration: Double(randDuration)),
            fireLoop
            ]);
        
        return seq
    }
    
    func destroy() {
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        eventWatch?.didDestroyEnemy(node: self)
        
        mainScene?.enemyDestroyed(node: self, points: 100)
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
    func didDestroyEnemy(node: enemy) {
        guard let sNode = node as? SKSpriteNode else {
            return;
        }
        if(sNode.name == "CriticalSpot"){
            self.hit(point: CGPoint(x: 0, y: 0), damage: 3)
        }
    }
    
    func action(level: Int) -> SKAction? {
        return nil
    }
    
    func destroy() {
        self.isHidden = true
        self.hp = 0
        self.removeAllActions()
        self.removeFromParent()
        eventWatch?.didDestroyEnemy(node: self)
        
        mainScene?.enemyDestroyed(node: self, points: 10)
    }
    
    func reset() {
        self.isHidden = false
        self.hp = baseHP
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}






