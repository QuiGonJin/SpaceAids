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
    static var critSpotSprite: SKTexture = SKTexture(imageNamed: "crit_spot");
    static var suicideSprites: [SKTexture] = [SKTexture]();
    static var lilBasterdSprites: [SKTexture] = [SKTexture]();
    static var fighterSprites: [SKTexture] = [SKTexture]();
    
//    static var muzzleSprites: SKTextureAtlas = SKTextureAtlas();
    
    //blocking load
    static func load() {
        //bullets
        let hs1 = SKTexture(imageNamed: "bullet_sprite_1");
        bulletSprites.append(hs1);
        let hs2 = SKTexture(imageNamed: "bullet_sprite_2");
        bulletSprites.append(hs2);
        let hs3 = SKTexture(imageNamed: "bullet_sprite_3");
        bulletSprites.append(hs3);
        
        //muzzle flare
        let muzzleAtlas = SKTextureAtlas(named: "muzzle_flares");
        for sp in muzzleAtlas.textureNames {
            muzzleSprites.append(muzzleAtlas.textureNamed(sp))
        }
    
        //suicide enemy
        let suicideAtlas = SKTextureAtlas(named: "suicide_sprites");
        for sp in suicideAtlas.textureNames {
            suicideSprites.append(suicideAtlas.textureNamed(sp))
        }
        
        //lilbasterd enemy
        let lbAtlas = SKTextureAtlas(named: "lilBasterd_sprites");
        for sp in lbAtlas.textureNames {
            lilBasterdSprites.append(lbAtlas.textureNamed(sp))
        }
        
        //fighter enemy
        let fighterAtlas = SKTextureAtlas(named: "fighter_sprites");
        for sp in fighterAtlas.textureNames {
            fighterSprites.append(fighterAtlas.textureNamed(sp))
        }
        
    }
}
