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
    static var armorSound = SKAction();
    static var critSound = SKAction();
    static var explosionLightSound = SKAction();
    static var explosionHeavySound = SKAction();
    static var swapWeaponSound = SKAction();
    static var didTakeDmgSound = SKAction();
    static var bgmSound = SKAction();
    static var bgmPlayer = SKAudioNode();
    
    static func load(completion : () -> Void) {
        for i in 1...5{
            let filename:String = "gun_sound_" + String(i)
            gunSounds.append(SKAction.playSoundFileNamed(filename, waitForCompletion: false));
        }
        
        armorSound = SKAction.playSoundFileNamed("armor_sound", waitForCompletion: false);
        critSound = SKAction.playSoundFileNamed("crit_sound", waitForCompletion: false);
        explosionLightSound = SKAction.playSoundFileNamed("explosion_light", waitForCompletion: false);
        explosionHeavySound = SKAction.playSoundFileNamed("explosion_heavy", waitForCompletion: false);
        swapWeaponSound = SKAction.playSoundFileNamed("switch_weapon", waitForCompletion: false);
        didTakeDmgSound = SKAction.playSoundFileNamed("damaged_sound", waitForCompletion: false);
        bgmSound = SKAction.playSoundFileNamed("bgm", waitForCompletion: true);
        bgmPlayer = SKAudioNode(fileNamed: "bgm");
        bgmPlayer.autoplayLooped = true;
        completion();
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
    
    static func getDamagedSound() -> SKAction {
        return didTakeDmgSound;
    }
    
}

