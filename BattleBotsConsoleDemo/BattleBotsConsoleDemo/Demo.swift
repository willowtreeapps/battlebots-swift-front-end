//
//  Demo.swift
//  BattleBotsConsoleDemo
//
//  Created by Andrew Carter on 6/27/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation
import BattleBotsCocoa

struct TextEntity: Entity, CustomStringConvertible {
    var type: Type
    var id: String
    
    let description: String
}

class CLIRenderer: ArenaRenderer {
    typealias EntityType = TextEntity
    
    let frameTime = 0.1
    
    var entities = [[TextEntity?]]()
    var createdEntities = [String: TextEntity]()
    
    func makeEntity(type: Type, id: String) -> TextEntity {
        let emoji: String
        switch type {
        case .bot:
            emoji = "😃"
        case .wall:
            emoji = "📕"
        }
        let newEntity = TextEntity(type: type, id: id, description: emoji)
        createdEntities[id] = newEntity
        return newEntity
    }
    
    func insert(entity: EntityType, at index: Position) {
        entities[index.x][index.y] = entity
    }
    
    func move(id: String, from: Position, to: Position) {
        entities[to.x][to.y] = entities[from.x][from.y]
        entities[from.x][from.y] = nil
    }
    
    func remove(id: String, at: Position) {
        entities[at.x][at.y] = nil
    }
    
    func willProcess(_ frame: ArenaFrame) {
        if entities.flatten().isEmpty {
            entities = Array(repeating: Array(repeating: nil, count: frame.map[0].count), count: frame.map.count)
        }
    }
    
    func didProcess(_ frame: ArenaFrame) {
        print(entities.reduce("", combine: { (result, row) -> String in
            
            let string = row.reduce("", combine: { (result, entity) -> String in
                return "\(result)\(entity?.description ?? "🌱")"
            })
            
            
            return "\(result)\n\(string)"
            
        }))
    }
}
