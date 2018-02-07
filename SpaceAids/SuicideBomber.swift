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

class SuicideBomber: SKSpriteNode, enemy, enemyWatchDelegate {
    var eventWatch: enemyWatchDelegate?
    let baseHP:Int = 9
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
    
    func action() -> SKAction? {
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

