//
//  Spawner.swift
//  SpaceAids
//
//  Created by Kevin Chen on 1/16/18.
//  Copyright © 2018 KamiKazo. All rights reserved.
//

import Foundation
import UIKit
import GameKit

class EnemyGenerator: SKNode, enemyWatchDelegate {
    //same as top left of scene
    var domain:CGFloat = 0;
    var range: CGFloat = 0;
    var waveRunDuration: TimeInterval = 5.0;
    var paths: [CGPath] = [CGPath]();
    var actions: [SKAction] = [SKAction]();
    var levelLines: [String] = [String]();
    var levelIndex:Int = 0;
    var patterns: [String] = [String]();
    
    //enemy type, number of spawns, enemy hp, spawn path, speed, delay per spawn(ms), wave delay(ms)
    var testString = "1, 5, 5, 0, 8, 200, 3000"
    
    init(position: CGPoint, horizontalRange: CGFloat){
        super.init();
        
        self.position = position; //put at top left...
        domain = horizontalRange;
        range = position.y + 100;
        
        patterns.append("1, 1, 12, 0, 200, 600");
        patterns.append("1, 1, 12, 1, 200, 600");
        patterns.append("1, 1, 12, 1, 200, 600");
        patterns.append("2, 5, 2, 3, 800, 200");
        patterns.append("2, 5, 2, 4, 800, 200");
        patterns.append("2, 5, 2, 5, 800, 200");
        patterns.append("2, 5, 2, 6, 800, 200");
        patterns.append("3, 5, 2, 7, 800, 200");
        patterns.append("3, 5, 2, 8, 800, 200");
        patterns.append("3, 5, 2, 10, 800, 200");
        patterns.append("3, 5, 2, 11, 800, 200");
        patterns.append("10, 1, 50, 9, 100, 1000");
    }

    func bogus1(){
        patterns.removeAll();
        patterns.append("1, 2, 12, 0, 200, 600");
        patterns.append("1, 2, 12, 1, 200, 600");
        patterns.append("1, 2, 12, 1, 200, 600");
        patterns.append("2, 8, 2, 3, 800, 200");
        patterns.append("2, 8, 2, 4, 800, 200");
        patterns.append("2, 8, 2, 5, 800, 200");
        patterns.append("2, 8, 2, 6, 800, 200");
        patterns.append("3, 8, 2, 7, 800, 200");
        patterns.append("3, 8, 2, 8, 800, 200");
        patterns.append("3, 8, 2, 10, 800, 200");
        patterns.append("3, 8, 2, 11, 800, 200");
        patterns.append("10, 1, 100, 9, 100, 1000");
    }
    
    func bogus2(){
        patterns.removeAll();
        patterns.append("1, 2, 18, 0, 300, 600");
        patterns.append("1, 2, 18, 1, 300, 600");
        patterns.append("1, 2, 18, 1, 300, 600");
        patterns.append("2, 10, 3, 3, 800, 200");
        patterns.append("2, 10, 3, 4, 800, 200");
        patterns.append("2, 10, 3, 5, 800, 200");
        patterns.append("2, 10, 3, 6, 800, 200");
        patterns.append("3, 10, 3, 7, 800, 200");
        patterns.append("3, 10, 3, 8, 800, 200");
        patterns.append("3, 10, 3, 10, 800, 200");
        patterns.append("3, 10, 3, 11, 800, 200");
        patterns.append("10, 1, 200, 9, 100, 1000");
    }
    
    func bogus3(){
        patterns.removeAll();
        patterns.append("1, 2, 20, 1, 300, 600");
        patterns.append("1, 2, 20, 1, 300, 600");
        patterns.append("2, 10, 3, 3, 800, 200");
        patterns.append("2, 10, 3, 4, 800, 200");
        patterns.append("2, 10, 3, 5, 800, 200");
        patterns.append("2, 10, 3, 6, 800, 200");
        patterns.append("3, 10, 3, 7, 800, 200");
        patterns.append("3, 10, 3, 8, 800, 200");
        patterns.append("3, 10, 3, 10, 800, 200");
        patterns.append("3, 10, 3, 11, 800, 200");
        patterns.append("10, 1, 150, 7, 500, 1000");
        patterns.append("10, 1, 150, 8, 500, 1000");
        patterns.append("10, 1, 200, 9, 100, 1000");
    }
    
    func generateRandomLevel(){
        var rngsus: Int;
        levelLines.removeAll();
        levelIndex = 0;
        for _ in 0...16 {
            rngsus = Int(arc4random_uniform(UInt32(patterns.count)));
            var pick:String = patterns[rngsus];
            pick += ", " + String(arc4random_uniform(2000));
            self.levelLines.append(pick);
        }
        
    }
    
    func loadLevel(_ filename: String)->Bool{
        guard let filepath = Bundle.main.path(forResource: filename, ofType: "csv") else {
            generateRandomLevel();
            return true;
        }
        
        do {
            let contents = try String(contentsOfFile: filepath);
            levelLines = contents.components(separatedBy: "\n");
            levelIndex = 0;
            return true;
        } catch {
            print("File Read Error for file \(filepath)")
            return false;
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didDestroyEnemy(node: enemy, param: String?) {
        let n = node as! SKNode;
        
        n.removeAllActions();
        n.removeFromParent();
        guard let msg = param else {
            return;
        }
        let params: [String] = msg.components(separatedBy: ",");
        let type = params[0];
        if(type == "crit"){

        } else if(type == "dead") {
            mainScene?.enemyDestroyed(node: n, points: Int(params[1])!)
        } else if(type == "power"){
            mainScene?.powerUp(type: Int(params[1])!);
        } else if(type == "suicide"){
            
        }
    }
    
    func initPaths(){
        // =========  line paths  =========
        
        //0 - line path left
        let linePath0 = UIBezierPath()
        linePath0.move(to: CGPoint(x: 100, y: 0))
        linePath0.addLine(to: CGPoint(x: 100, y: -range))
        paths.append(linePath0.cgPath)
        
        //1 - line path center
        let linePath1 = UIBezierPath()
        linePath1.move(to: CGPoint(x: domain / 2, y: 0))
        linePath1.addLine(to: CGPoint(x: domain / 2, y: -range))
        paths.append(linePath1.cgPath)
        
        //2 - line path right
        let linePath2 = UIBezierPath()
        linePath2.move(to: CGPoint(x: domain - 100 , y: 0))
        linePath2.addLine(to: CGPoint(x: domain - 100, y: -range))
        paths.append(linePath2.cgPath)
        
        // =========== S Curve ==============
        
        //3 - S curve left
        let bezCurve0 = UIBezierPath()
        
        bezCurve0.move(to: CGPoint(x: domain/2 - 50, y: 0))
        bezCurve0.addCurve(to: CGPoint(x:domain/2 - 50, y: -range),
                          controlPoint1: CGPoint(x: -400, y: -(range/3)),
                          controlPoint2: CGPoint(x: 400, y: -(range/3)))
        paths.append(bezCurve0.cgPath);
        
        //4 - S curve right
        let bezCurve1 = UIBezierPath()
        bezCurve1.move(to: CGPoint(x: domain/2 + 50, y: 0))
        bezCurve1.addCurve(to: CGPoint(x: domain/2 + 50, y: -range),
                           controlPoint1: CGPoint(x: domain + 400, y: -(range/3)),
                           controlPoint2: CGPoint(x: domain - 400, y: -(range/3)))
        paths.append(bezCurve1.cgPath);
        
        // ======== Cross Curve ==============
        var startX: CGFloat = 100
        var endX: CGFloat = domain - 100
        
        //5 - Cross curve left
        let cCurve0 = UIBezierPath()
        cCurve0.move(to: CGPoint(x: startX, y: 0))
        cCurve0.addCurve(to: CGPoint(x: endX, y: -range),
                          controlPoint1: CGPoint(x: startX, y: -range/2 ),
                          controlPoint2: CGPoint(x: endX, y: -range/2) )
        paths.append(cCurve0.cgPath)
        
        //6 - Cross curve right
        startX = domain - 100
        endX = 100
        
        let cCurve1 = UIBezierPath()
        cCurve1.move(to: CGPoint(x: startX, y: 0))
        cCurve1.addCurve(to: CGPoint(x: endX, y: -range),
                         controlPoint1: CGPoint(x: startX, y: -range/2 ),
                         controlPoint2: CGPoint(x: endX, y: -range/2) )
        paths.append(cCurve1.cgPath)
        
        
        // ============ loop ===================
        var lstartX:CGFloat = 100
        var radius:CGFloat = (domain - 175) / 2
        var loopStart = CGPoint(x: lstartX, y: -(range/3));
        
        //7 - left loop
        let loop0 = UIBezierPath()
        loop0.move(to: CGPoint(x: lstartX, y: 0))
        loop0.addLine(to: loopStart)
        loop0.addArc(withCenter: CGPoint(x: lstartX + radius, y: loopStart.y), radius: radius, startAngle: CGFloat.pi, endAngle:CGFloat.pi*3, clockwise: true)
        loop0.addLine(to: CGPoint(x: lstartX, y: -range))
        paths.append(loop0.cgPath)
        
        //8 - right loop

        lstartX = domain - 100
        loopStart = CGPoint(x: lstartX, y: -(range/3));
        
        let loop1 = UIBezierPath()
        loop1.move(to: CGPoint(x: lstartX, y: 0))
        loop1.addLine(to: loopStart)
        loop1.addArc(withCenter: CGPoint(x: lstartX - radius, y: loopStart.y), radius: radius, startAngle: CGFloat.pi * 2, endAngle: 0 , clockwise: false)
        loop1.addLine(to: CGPoint(x: lstartX, y: -range))
        paths.append(loop1.cgPath)
        
        //9 - boss loop
        let bossLoop = UIBezierPath()
        bossLoop.move(to: CGPoint(x: domain/2, y: 0))
        bossLoop.addLine(to: CGPoint(x: domain/2, y: -range/3));
        bossLoop.addLine(to: CGPoint(x: domain - 200, y: -range/2));
        bossLoop.addLine(to: CGPoint(x: 200, y: -range/2));
        bossLoop.addLine(to: CGPoint(x: domain/2, y: -range/3));
        bossLoop.addLine(to: CGPoint(x: domain/2, y: -range));
        paths.append(bossLoop.cgPath);
        
        //10 - right crazy loop
        let czLoop = UIBezierPath()
        czLoop.move(to: CGPoint(x: domain - 100, y: 0))
        czLoop.addLine(to: loopStart);
        czLoop.addArc(withCenter: CGPoint(x: lstartX - radius, y: loopStart.y), radius: radius, startAngle: 0, endAngle:CGFloat.pi*2, clockwise: true)
        czLoop.addLine(to: CGPoint(x: lstartX, y: -range))
        paths.append(czLoop.cgPath)
        
        //11 - left crazy loop
        lstartX = 100
        loopStart = CGPoint(x: lstartX, y: -(range/3));
        
        
        let lzLoop = UIBezierPath()
        lzLoop.move(to: CGPoint(x: lstartX, y: 0))
        lzLoop.addLine(to: loopStart);
        lzLoop.addArc(withCenter: CGPoint(x: lstartX + radius, y: loopStart.y), radius: radius, startAngle: CGFloat.pi*2, endAngle:0, clockwise: true)
        lzLoop.addLine(to: CGPoint(x: lstartX, y: -range))
        paths.append(lzLoop.cgPath)
        
    }
    
    func spawnWave()->TimeInterval{
        if(levelIndex >= levelLines.count){ return -1 }
        let input = levelLines[levelIndex];
        if(input.count < 1){ return -1 }
        levelIndex+=1;
        
        let replacedString = String(input.filter {$0 != " "});
        let p = replacedString.split(separator: ",", omittingEmptySubsequences: true)
        let arr: [Int] = p.compactMap{ Int($0) }
        
        let type: Int = arr[0]
        let count: Int = arr[1]
        let myHP: Int = arr[2]
        let path:CGPath = paths[arr[3]];
        let speed:CGFloat = CGFloat(arr[4]);
        let spawnDelay:Double = Double(arr[5]) / 1000.0;
        let nextWaveDelay:Double = Double(arr[6]) / 1000.0;
        
        let sprites:[SKSpriteNode] = buildWave(type: type, count: count);
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 100, y: 0))
        linePath.addLine(to: CGPoint(x: 100, y: range))
        
        var OTP = true;
        
        if (type == enemyTypeEnum.CARRIER){
            OTP = false;
        }
        
        for i in 0..<sprites.count {
            let action = SKAction.follow(path, asOffset: true, orientToPath: OTP, speed: speed)
            let mySprite = sprites[i];
            
            var e = sprites[i] as! enemy;
            e.hp = myHP
            
            let group = SKAction.group([
                action,
                SKAction.run({
                    mySprite.isHidden = false;
                    e.action(level: 0)
                })
            ])
            
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: spawnDelay * Double(i)),
                SKAction.run({
                    self.addChild(mySprite);
                    mySprite.run(group);
                })
            ]);
            self.run(sequence);
        }
        return nextWaveDelay;
    }
    
    func spawnLevel() {
        let delay = spawnWave();
        if(delay > 0){
            let seq = SKAction.sequence([
                    SKAction.wait(forDuration: delay),
                    SKAction.run {
                        self.spawnLevel();
                    }
                ]);
            self.run(seq);
        }
    }
    
    func buildWave(type: Int, count: Int)->[SKSpriteNode]{
        var ret = [SKSpriteNode]();
        if(type == enemyTypeEnum.SUICIDE) {
            for _ in 0..<count {
                let sprite = SuicideBomber(position: CGPoint(x: 0, y: 0), size: CGSize(width: 140, height: 140), delegate: self);
                sprite.isHidden = true;
                ret.append(sprite);
            }
            return ret;
        }
        if(type == enemyTypeEnum.FIGHTER){
            for _ in 0..<count {
                let sprite = Fighter(position: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100), delegate: self);
                sprite.isHidden = true;
                ret.append(sprite);
            }
            return ret;
        }
        if(type == enemyTypeEnum.LILBASTERD){
            for _ in 0..<count {
                let sprite = LilBasterd(position: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100), delegate: self);
                sprite.isHidden = true;
                ret.append(sprite);
            }
            return ret;
        }
        if(type == enemyTypeEnum.BULLET){
            for _ in 0..<count {
                let sprite = Bullet(position: CGPoint(x: 0, y: 0), size: CGSize(width: 50, height: 50), delegate: self);
                sprite.isHidden = true;
                ret.append(sprite);
            }
            return ret;
        }
        if(type == enemyTypeEnum.POWERUP){
            for _ in 0..<count {
                let sprite = PowerUp(position: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100), delegate: self);
                sprite.isHidden = true;
                ret.append(sprite);
            }
            return ret;
        }
        if(type == enemyTypeEnum.CARRIER){
            for _ in 0..<count {
                let sprite = Carrier(position: CGPoint(x: 0, y: 0), size: CGSize(width: 250, height: 250), delegate: self);
                sprite.isHidden = true;
                ret.append(sprite);
            }
            return ret;
        }
        return ret;
    }
}

