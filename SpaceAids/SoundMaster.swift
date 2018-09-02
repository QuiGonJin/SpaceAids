//
//  Loader.swift
//  SpaceAids
//
//  Created by Kevin Chen on 3/26/18.
//  Copyright © 2018 KamiKazo. All rights reserved.
//

import Foundation
import SpriteKit

class SoundMaster {
    static var gunSounds: [SKAction] = [SKAction]();
    static var armorSound = SKAction.playSoundFileNamed("armor_sound", waitForCompletion: false);
    static var critSound = SKAction.playSoundFileNamed("crit_sound", waitForCompletion: false);
    static var explosionLightSound = SKAction.playSoundFileNamed("explosion_light", waitForCompletion: false);
    static var explosionHeavySound = SKAction.playSoundFileNamed("explosion_heavy", waitForCompletion: false);
    static var swapWeaponSound = SKAction.playSoundFileNamed("switch_weapon", waitForCompletion: false);
    
    static func load() {
        for i in 1...5{
            let filename:String = "gun_sound_" + String(i)
            gunSounds.append(SKAction.playSoundFileNamed(filename, waitForCompletion: false));
        }
    }
    
    static func getGunSound() -> SKAction {
        return gunSounds[Int(arc4random_uniform(UInt32(gunSounds.count)))];
    }
    
    static func getArmorSound() -> SKAction {
        return armorSound;
    }
    
    static func getCritSound() -> SKAction {
        return critSound;
    }
    
}

