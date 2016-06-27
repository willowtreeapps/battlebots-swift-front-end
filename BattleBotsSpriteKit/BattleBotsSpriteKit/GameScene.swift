//
//  GameScene.swift
//  BattleBotsSpriteKit
//
//  Created by Andrew Carter on 6/27/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import SpriteKit
import GameplayKit
import BattleBotsCocoaTouch

enum EntityTexture {
    case bot
    case wall
    case grass
    
    var texture: SKTexture {
        let emoji: String
        switch self {
        case .bot:
            emoji = "😀"
            
        case .wall:
            emoji = "◻️"
            
        case .grass:
            emoji = ["🍃", "🍃", "🍃", "🍃", "🍃", "🌱", "🌿", "🍄", "🌸"].random()
            
        }
        
        let text = AttributedString(string: emoji, attributes:  [NSFontAttributeName : UIFont.systemFont(ofSize: 40.0)])
        let size = text.size()
        
        let renderer = UIGraphicsImageRenderer(bounds: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        let image = renderer.image() { context in
            text.draw(at: .zero)
        }
        
        return SKTexture(image: image)
    }
}

enum Decoration: String {
    case grass
}

class SpriteEntity: SKSpriteNode, Entity {
    var type: Type = .bot
    var id: String {
        return name ?? ""
    }
}

class GameScene: SKScene, ArenaRenderer {
    
    typealias EntityType = SpriteEntity
    var frameTime = 1.0
    var didSetupBackground = false
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        runDemo()
    }
    
    func insert(entity: EntityType, at index: Position) {
        addChild(entity)
        entity.position = CGPoint(x: CGFloat(index.x) * entity.frame.width, y: CGFloat(index.y) * entity.frame.height)
        entity.run(SKAction.fadeIn(withDuration: frameTime))
    }
    
    func makeEntity(type: Type, id: String) -> EntityType {
        switch type {
        case .bot:
            let entity = SpriteEntity(texture: EntityTexture.bot.texture)
            entity.zPosition = 2
            entity.type = type
            entity.name = id
            entity.alpha = 0.0
            let sequence = SKAction.sequence([SKAction.rotate(toAngle: 1.0, duration: frameTime / 2.0), SKAction.rotate(toAngle: -1.0, duration: frameTime / 2.0)])
            entity.run(SKAction.repeatForever(sequence))
            return entity
            
        case .wall:
            let entity = SpriteEntity(texture: EntityTexture.wall.texture)
            entity.zPosition = 1
            entity.type = type
            entity.name = id
            entity.alpha = 0.0
            
            return entity
        }
    }
    
    func move(id: String, from: Position, to: Position) {
        guard let sprite = childNode(withName: id) as? EntityType else {
            return
        }
        
        let toX = CGFloat(to.x) * sprite.size.width
        let toY = CGFloat(to.y) * sprite.size.height
        let point = CGPoint(x: toX, y: toY)
        let action = SKAction.move(to: point, duration: frameTime)
        
        sprite.run(action)
    }
    
    func remove(id: String, at: Position) {
        guard let sprite = childNode(withName: id) as? EntityType else {
            return
        }
        let action = SKAction.sequence([SKAction.fadeOut(withDuration: frameTime), SKAction.removeFromParent()])
        sprite.run(action)
    }
    
    func setupBackground(with frame: ArenaFrame) {
        for (y, col) in frame.map.enumerated() {
            for (x, _) in col.enumerated() {
                let grass = SpriteEntity(texture: EntityTexture.grass.texture)
                grass.position = CGPoint(x: CGFloat(x) * grass.frame.width, y: CGFloat(y) * grass.frame.height)
                grass.zPosition = 0
                addChild(grass)
            }
        }
    }
    
    func willProcess(_ frame: ArenaFrame) {
        if !didSetupBackground {
            didSetupBackground = true
            setupBackground(with: frame)
        }
    }
    
    func didProcess(_ frame: ArenaFrame) {
        
    }
    
}
