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
    
    //enemy type, number of spawns, enemy hp, spawn pattern, speed, delay per spawn(ms), wave delay(ms)
    var testString = "1, 5, 5, 0, 8, 200, 3000"
    
    init(position: CGPoint, horizontalRange: CGFloat){
        super.init();
        
        let testNode = SKSpriteNode(color: UIColor.yellow, size: CGSize(width: 50, height: 50))
        self.addChild(testNode)
        
        self.position = position; //put at top left...
        domain = horizontalRange;
        range = position.y + 100;
        initPaths();
        loadLevel("level_1");
    
    }

    
    func loadLevel(_ filename: String){
        guard let filepath = Bundle.main.path(forResource: filename, ofType: "csv") else {
            return;
        }
        
        do {
            let contents = try String(contentsOfFile: filepath);
            levelLines = contents.components(separatedBy: "\n");
            levelIndex = 0;
        } catch {
            print("File Read Error for file \(filepath)")
            return
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didDestroyEnemy(node: enemy) {
        let n = node as! SKNode;
        n.removeAllActions();
        n.removeFromParent();
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
        
        //0 - S curve left
        let bezCurve0 = UIBezierPath()
        bezCurve0.move(to: CGPoint(x: 200, y: 0))
        bezCurve0.addCurve(to: CGPoint(x:200, y: -range),
                          controlPoint1: CGPoint(x: -400, y: -(range/2)),
                          controlPoint2: CGPoint(x: 400, y: -(range/2)))
        paths.append(bezCurve0.cgPath);
    
    }
    
    func spawnWave()->TimeInterval{
        if(levelIndex >= levelLines.count){ return -1 }
        let input = levelLines[levelIndex];
        levelIndex+=1;
        if(input.count < 1){
            return -1.0;
        }
        
        let replacedString = String(input.filter {$0 != " "});
        let p = replacedString.split(separator: ",", omittingEmptySubsequences: true)
        let arr: [Int] = p.flatMap { Int($0) }
        
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
        
        
        for i in 0..<sprites.count {
            let action = SKAction.follow(path, asOffset: true, orientToPath: true, speed: speed)
            let mySprite = sprites[i];
            mySprite.isHidden = false;
            
            
            var e = sprites[i] as! enemy;
            e.hp = myHP
            
            let sequence = SKAction.sequence([
                SKAction.wait(forDuration: spawnDelay * Double(i)),
                action
            ]);
            
            self.addChild(mySprite);
            mySprite.run(sequence);
        }
        return nextWaveDelay;
    }
    
    func buildWave(type: Int, count: Int)->[SKSpriteNode]{
        var ret = [SKSpriteNode]();
        if(type == 1) {
            for _ in 0..<count {
                let suicideBomber = SuicideBomber(position: CGPoint(x: 0, y: 0), size: CGSize(width: 140, height: 140), delegate: self);
                ret.append(suicideBomber);
            }
            return ret;
        }
        if(type == 2){
            for _ in 0..<count {
                let figher = Fighter(position: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100), delegate: self);
                ret.append(figher);
            }
            return ret;
        }
        return ret;
    }
}

