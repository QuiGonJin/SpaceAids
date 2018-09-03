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
    var scoreLabelLabel : SKLabelNode?
    var scoreLabel : SKLabelNode?
    
    override init() {
        super.init(size: CGSize(width: 1200, height: 2500));
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadPage(){
        SoundMaster.load();
        
        self.backgroundColor = UIColor.black
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        //Banner
        let banner = SKSpriteNode(texture: SKTexture(imageNamed: "space_aids_banner"));
        banner.position = CGPoint(x: 0, y: 400);
        self.addChild(banner);
        
        //Logo
        
        let logo = SKSpriteNode(texture: SKTexture(imageNamed: "kami_kazo_logo"));
        logo.position = CGPoint(x: 450, y: -1000);
        self.addChild(logo);
        
        //High Score
        let defaults = UserDefaults.standard;
        let hs = defaults.integer(forKey: "SpaceAidsHighScore") as Int;
        
        scoreLabelLabel = SKLabelNode(text: "High Score");
        scoreLabelLabel?.fontColor = UIColor.white;
        scoreLabelLabel?.fontSize = 90;
        scoreLabelLabel?.position = CGPoint(x: 0, y: 0)
        
        scoreLabel = SKLabelNode(text: String(hs));
        scoreLabel?.fontColor = UIColor.white;
        scoreLabel?.fontSize = 60;
        scoreLabel?.position = CGPoint(x: 0, y: -100);
        
        self.addChild(scoreLabelLabel!);
        self.addChild(scoreLabel!);
        
        //Start Button
        start = SKSpriteNode(texture: SKTexture(imageNamed: "start_button"));
        start?.position = CGPoint(x: 0, y: -500)
        start?.name = "start"
        
        self.addChild(start!)
    }
    
    override func didMove(to view: SKView) {
        Assets.load(completion: loadPage);
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
        let scene = GameScene(size: CGSize(width: 1250, height: 2800));
        scene.run(SoundMaster.swapWeaponSound);
        scene.scaleMode = .aspectFill
        if let view = self.view{
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsPhysics = false
            view.showsNodeCount = false
        }
    }
}

