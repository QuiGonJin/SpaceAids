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
