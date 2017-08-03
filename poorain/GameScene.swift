//
//  GameScene.swift
//  poorain
//
//  Created by Macky Mas on 2017. 8. 1..
//  Copyright © 2017년 kate. All rights reserved.
//

import SpriteKit

// CGPoint 다루기 쉽게 메소드, 연산자 추가

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}
func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}


//
//#if !(arch(x86_64) || arch(arm64))
//    func sqrt(a: CGFloat) -> CGFloat {
//        return CGFloat(sqrtf(Float(a)))
//    }
//#endif

// object에 고유번호 부여
struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Poo       : UInt32 = 0b1
    static let Player    : UInt32 = 0b10
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // 주인공 등장
    let playerTexture = SKTexture(imageNamed: "player")
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    let bounds = UIScreen.main.bounds
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    
    // 스코어
    var poosDestroyed = 0 {
        willSet(newVal) {
            scoreLabel.text = "score: \(newVal)"
        }
    }
    
    override func sceneDidLoad() {
        
        screenWidth = bounds.size.width
        screenHeight = bounds.size.height
        
        // 배경은 흰바탕
        backgroundColor = SKColor.white
        // 떨어지는 방향 아래로 - 환경 설정
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        // 주인공 진짜 등장
        player = SKSpriteNode(texture: playerTexture)
        
        // 스코어 라벨 추가
        scoreLabel = SKLabelNode(fontNamed: "Verdana")
        scoreLabel.text = "score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: scoreLabel.frame.width*1.1, y: size.height/1.07)
        addChild(scoreLabel)
        
        // 사람 투하
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        
        // 플레이어의 물리모델 설정 - 설정항목별 명세는 직접 들어가서 보시기를..
        // 좀더 세밀한 인간표현을 위해
        player.physicsBody = SKPhysicsBody(texture: playerTexture,
                                           size: CGSize(width: player.size.width,
                                                        height: player.size.height))
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Poo
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(player)
        
    }
    
    override func didMove(to view: SKView) {
        
        // 똥뿌리기
        let waitD = 0.3// - (Double)(poosDestroyed/10)
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addPoo),
                SKAction.wait(forDuration: waitD)
                ])
        ))
    }
    
    // 플레이어 움직이기
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let lastPosX = player.position.x
        let lastPosY = player.position.y
        let posX = touches.first?.location(in: self).x
        let moveToX: CGFloat = lastPosX > (posX)! ? -6 : 6
        
        let movePos = CGPoint(x: lastPosX + moveToX, y: lastPosY)
        player.position = movePos
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    func addPoo() {
        
        // 응가 선언
        let pooTexture = SKTexture(imageNamed: "poo")
        let poo = SKSpriteNode(texture: pooTexture)
        // 좀더 세밀한 응가표현을 위해
        
        // 응가의 물리모델 설정 - 설정항목별 명세는 직접 들어가서 보시기를..
        poo.physicsBody = SKPhysicsBody(texture: pooTexture,
                                        size: CGSize(width: poo.size.width,
                                                     height: poo.size.height))
        poo.physicsBody?.isDynamic = true
        poo.physicsBody?.categoryBitMask = PhysicsCategory.Poo
        poo.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        poo.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // 떨어지는 위치 랜덤 설정
        let actualX = random(min: poo.size.width/2, max: size.width - poo.size.width/2)
        poo.position = CGPoint(x: actualX, y: size.height + poo.size.height/2)
        // 응가 등판
        addChild(poo)
        
        // 응가 속도도 랜덤 설정, // 스코어 올라가면 좀더 빠르게..
        let minD = 3.5// - (Double)(poosDestroyed/10)
        let maxD = 5.5// - (Double)(poosDestroyed/10)
        let actualDuration = random(min: CGFloat(minD), max: CGFloat(maxD))
        
        let minA = -15.0// - (Double)(poosDestroyed/10)
        let maxA = -5.0// - (Double)(poosDestroyed/10)
        let actualAcc = random(min: CGFloat(minA), max: CGFloat(maxA))
        
        // 하늘에서 응가가 내린다, 가속도 붙은 응가가..
        let actionMove = SKAction.applyForce(CGVector(dx: 0 ,dy: actualAcc), duration: TimeInterval(actualDuration))
        let actionFinish = SKAction.run({
            SKAction.removeFromParent()
            self.poosDestroyed += 1
        })
        
        poo.run(SKAction.sequence([actionMove, actionFinish]))
        
    }
    
    // SKPhysicsContactDelegate 의 delegate method
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Poo 와 Player 충돌 감지
        if ((firstBody.categoryBitMask & PhysicsCategory.Poo != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
            if let poo = firstBody.node as? SKSpriteNode, let player = secondBody.node as? SKSpriteNode {
                playerDidCollideWithPoo(player: player, poo: poo)
            }
        }
    }
    
    // 게임오버....
    func playerDidCollideWithPoo(player: SKSpriteNode, poo: SKSpriteNode) {
        let reveal = SKTransition.flipVertical(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size, won: false, score: poosDestroyed)
        self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    // 랜덤용함수
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}
