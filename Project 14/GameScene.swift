//
//  GameScene.swift
//  Project 14
//
//  Created by Olibo moni on 17/02/2022.
//

import SpriteKit


class GameScene: SKScene {
    
    var numRounds = 0
    var popupTime = 0.85
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    var finalScore: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var isGameOver = false 
    var score = 0 {
        didSet{
            gameScore.text = "Score: \(score)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410))}
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320))}
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230))}
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140))}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
            self?.createEnemy()
            
        }
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(recognizer: )))
        self.view?.addGestureRecognizer(pinchRecognizer)
    }
        
    
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else {return}
            let location = touch.location(in: self)
            let tappedNodes = nodes(at: location)
            
            for node in tappedNodes {
                guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
                
                if !whackSlot.isVisible { continue}
                if whackSlot.isHit { continue}
                whackSlot.hit()
                destroy(charNode: whackSlot)
                if node.name == "charFriend" {
                    // shouldn't have whacked this
                    
                    score -= 5
                    run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
                    
                } else if node.name == "charEnemy" {
                    
                    
                    whackSlot.charNode.xScale = 0.85
                    whackSlot.charNode.yScale = 0.85
                    
                    score += 1
                    run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                }
            }
        }
        
        
        func createSlot(at position: CGPoint){
            let slot = WhackSlot()
            slot.configure(at: position)
            addChild(slot)
            slots.append(slot)
        }
        
    
        func createEnemy(){
            numRounds += 1
            
            if numRounds >= 30 {
                for slot in slots {
                    slot.hide()
                }
                let gameOver = SKSpriteNode(imageNamed: "gameOver")
                gameOver.position = CGPoint(x: 512, y: 384)
                gameOver.zPosition = 1
                addChild(gameOver)
                run(SKAction.playSoundFileNamed("over.mp3", waitForCompletion: false))
                finalScore = SKLabelNode(fontNamed: "chalkDuster")
                finalScore.text = "Final Score: \(score)"
                finalScore.fontColor = .red
                finalScore!.position = CGPoint(x: 512, y: 500)
                finalScore!.zPosition = 1
                addChild(finalScore!)
                
                gameOverLabel = SKLabelNode(fontNamed: "chalkDuster")
                gameOverLabel.text = "Pinch to restart"
                gameOverLabel!.position = CGPoint(x: 512, y: 600)
                gameOverLabel.fontSize = 50
                gameOverLabel.fontColor = .red
                gameOverLabel!.zPosition = 1
                addChild(gameOverLabel)
                
                return
            }
            popupTime *= 0.991
            
            slots.shuffle()
            slots[0].show(hideTime: popupTime)
            
            if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime)}
            if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popupTime)}
            if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime)}
            if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime)}
            
            let minDelay = popupTime / 2
            let maxDelay = popupTime * 2
            let delay = Double.random(in: minDelay...maxDelay)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {[weak self] in
                self?.createEnemy()
            }
        }
    
    func destroy(charNode: WhackSlot){
        if let fireParticles = SKEmitterNode(fileNamed: "smokeParticle"){
            fireParticles.position = charNode.position
            addChild(fireParticles)
        }
        
    }
        
    @objc func handlePinch(recognizer: UIPinchGestureRecognizer){
        if recognizer.state == .ended {
            restartGame()
        }
    }
    
    @objc func restartGame(){
         isUserInteractionEnabled = true
         isGameOver = false
        
        let transition = SKTransition.fade(with: .magenta, duration: 2)
        let restartScene = GameScene()
        restartScene.size = CGSize(width: 1024, height: 768)
       // restartScene.scaleMode = .fill
        self.view?.presentScene(restartScene, transition: transition)
        
     }
    
}
