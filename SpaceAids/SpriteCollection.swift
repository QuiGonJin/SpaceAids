//
//  SpriteCollection.swift
//  SpaceAids
//
//  Created by Kevin Chen on 1/15/18.
//  Copyright © 2018 KamiKazo. All rights reserved.
//

import Foundation
import UIKit
import GameKit

class SpriteCollection {
    var spriteCollection: [SKSpriteNode]
    var index:Int = 0
    
    init(collection:[SKSpriteNode]){
        self.spriteCollection = collection
    }
    
    func getNext() -> SKSpriteNode? {
        if(spriteCollection.count < 1){ return nil }
        if(index >= spriteCollection.count) {
            index = 0
        }
        let i = index
        index += 1
        return spriteCollection[i]
    }
}

class SKEmitterWrapper: SKNode {
    var Emitter: SKEmitterNode?;
    
    override init() {
        super.init();
    }
    
    convenience init(emitter: SKEmitterNode) {
        self.init();
        self.Emitter = emitter;
        self.Emitter?.targetNode = self;
        self.addChild(self.Emitter!);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//lol woops...
class NodeCollection {
    var collection: [SKNode]
    var index:Int = 0
    
    init(collection:[SKNode]){
        self.collection = collection
    }
    
    func getNext() -> SKNode? {
        if(collection.count < 1){ return nil }
        if(index >= collection.count) {
            index = 0
        }
        let i = index
        index += 1
        return collection[i]
    }
}
