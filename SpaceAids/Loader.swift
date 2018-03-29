//
//  Loader.swift
//  SpaceAids
//
//  Created by Kevin Chen on 3/26/18.
//  Copyright © 2018 KamiKazo. All rights reserved.
//

import Foundation
import SpriteKit

class Assets {
//    static let Assets = Loader()
    static var bulletSprites: [SKTexture] = [SKTexture]();
    static var muzzleSprites: [SKTexture] = [SKTexture]();
//    static var muzzleSprites: SKTextureAtlas = SKTextureAtlas();
    
    //blocking load
    static func load() {
        let muzzleAtlas = SKTextureAtlas(named: "muzzle_flares");
        muzzleSprites.append(muzzleAtlas.textureNamed("muzzle_flare_1"));
        muzzleSprites.append(muzzleAtlas.textureNamed("muzzle_flare_2"));
        muzzleSprites.append(muzzleAtlas.textureNamed("muzzle_flare_3"));
        
        let hs1 = SKTexture(imageNamed: "bullet_sprite_1");
        bulletSprites.append(hs1);
        let hs2 = SKTexture(imageNamed: "bullet_sprite_2");
        bulletSprites.append(hs2);
        let hs3 = SKTexture(imageNamed: "bullet_sprite_3");
        bulletSprites.append(hs3);
    }
}
