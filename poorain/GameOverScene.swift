//
//  GameOverScene.swift
//  poorain
//
//  Created by Macky Mas on 2017. 8. 1..
//  Copyright © 2017년 kate. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, won:Bool, score: Int) {
        
        super.init(size: size)
        
        backgroundColor = SKColor.white
        
        let mlabel = SKLabelNode(fontNamed: "Verdana")
        mlabel.text = won ? "Aha?" : "ㅋㅋㅋ게임오버염"
        mlabel.fontSize = 36
        mlabel.fontColor = SKColor.black
        mlabel.position = CGPoint(x: size.width/2, y: size.height/1.5)
        addChild(mlabel)
        
        let slabel = SKLabelNode(fontNamed: "Verdana")
        slabel.text = "당신이 피한 똥은 \(score) 개"
        slabel.fontSize = 24
        slabel.fontColor = SKColor.black
        slabel.position = CGPoint(x: size.width/2, y: size.height/3)
        addChild(slabel)
        
        let action: SKAction = SKAction.sequence([
            SKAction.run() {
                let reveal = SKTransition.flipVertical(withDuration: 0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition: reveal)
            }
            ])
        let rlabel = ReplayGameLabel(action: action, fontNamed: "Verdana")
        rlabel.text = "다시하기"
        rlabel.fontSize = 24
        rlabel.fontColor = SKColor.red
        rlabel.position = CGPoint(x: size.width/2, y: size.height/6)
        rlabel.isUserInteractionEnabled = true
        addChild(rlabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
}

class ReplayGameLabel: SKLabelNode {
    
    var action: SKAction?
    
    init(action: SKAction, fontNamed fontName: String) {
        super.init(fontNamed: fontName)
        self.action = action
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(self.action!)
    }
}
