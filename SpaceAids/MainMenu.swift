//
//  MainMenu.swift
//  SolarVoyager
//
//  Created by Kevin Chen on 12/16/17.
//  Copyright © 2017 KamiKazo. All rights reserved.
//
import SpriteKit
import GameplayKit
class MainMenu: SKScene {
    
    /* UI Connections */
    var start: SKSpriteNode?
    
    override init() {
        super.init(size: CGSize(width: 1200, height: 2500));
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.gray
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        start = SKSpriteNode(color: UIColor.red, size: CGSize(width: 500, height: 500))
        start?.position = CGPoint(x: 0, y: 0)
        start?.name = "start"
        self.addChild(start!)
        

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            let pos = touch.location(in: self)
            let touchedNode = self.atPoint(pos)
            if(touchedNode.name == start?.name){
                launchGame()
            }
        }
    }
    
    
    func launchGame() {
//        let sizeRect = UIScreen.main.nativeBounds
//        let width = sizeRect.size.width * UIScreen.main.nativeScale
//        let height = sizeRect.size.height * UIScreen.main.nativeScale
//        let scene = GameScene(size: CGSize(width: width, height: height));
        
        let scene = GameScene(size: CGSize(width: 1250, height: 2800));
        scene.scaleMode = .aspectFill
        if let view = self.view{
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsPhysics = true
            view.showsNodeCount = true
        }
    }
}

