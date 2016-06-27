//
//  BattleBots.swift
//  test
//
//  Created by Andrew Carter on 6/24/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

public enum BattleBotError: ErrorProtocol {
    case unknownType
}

public enum Type {
    case wall
    case bot
    
    public init?(string: String) throws {
        
        let first = string.characters.first.map { "\($0)" } ?? " "
        switch first {
        case "W":
            self = .wall
            
        case "B":
            self = .bot
            
        case " ":
            return nil
            
        default:
            throw BattleBotError.unknownType
        }
    }
}

public struct ArenaFrameEntity: Entity {
    public var type: Type
    public var id: String
}

public extension ArenaFrameEntity {
    public init?(string: String) {
        guard let type = try! Type(string: string) else {
            return nil
        }
        self.type = type
        
        guard let id = string.components(separatedBy: ":").last else {
            fatalError("Found entity with no id")
        }
        self.id = id
    }
}

public struct Position: Equatable {
    public let x: Int
    public let y: Int
}

public func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

public struct ArenaFrame {
    public var map: [[String]]
    
    public func find(string: String) -> Position? {
        for (y, col) in map.enumerated() {
            for (x, row) in col.enumerated() {
                if row == string {
                    return Position(x: x, y: y)
                }
            }
        }
        return nil
    }
}

public protocol ArenaRenderer {
    associatedtype EntityType: Entity
    
    var frameTime: TimeInterval { get }
    
    func makeEntity(type: Type, id: String) -> EntityType
    func insert(entity: EntityType, at index: Position)
    func move(id: String, from: Position, to: Position)
    func remove(id: String, at: Position)
    func willProcess(_ frame: ArenaFrame)
    func didProcess(_ frame: ArenaFrame)
}


public extension ArenaRenderer {
    
    public func runDemo() {
        let frameOne = ArenaFrame(map: [
            ["B:001","W:002","     ","     ","     "],
            ["     ","W:003","     ","     ","     "],
            ["     ","W:004","     ","     ","     "],
            ["W:006","W:005","     ","     ","     "],
            ["     ","     ","     ","     ","     "],
            ])
        
        let frameTwo = ArenaFrame(map: [
            ["     ","W:002","     ","     ","     "],
            ["B:001","W:003","     ","     ","     "],
            ["     ","W:004","     ","     ","     "],
            ["W:006","W:005","     ","     ","     "],
            ["     ","     ","     ","     ","     "],
            ])
        
        let frameThree = ArenaFrame(map: [
            ["     ","W:002","     ","     ","     "],
            ["     ","W:003","     ","     ","     "],
            ["B:001","W:004","     ","     ","     "],
            ["W:006","W:005","     ","     ","     "],
            ["     ","     ","     ","     ","     "],
            ])
        
        let frames = [frameOne, frameTwo, frameThree]

        runDemo(frame: 0, previousFrameIndex: nil, frames: frames, nextFrameFunction: +)
    }
    
    public func runDemo(frame index: Int, previousFrameIndex: Int?, frames: [ArenaFrame], nextFrameFunction: (lhs: Int, rhs: Int) -> Int) {
        
        let previosFrame: ArenaFrame?
        if let previousFrameIndex = previousFrameIndex {
            previosFrame = frames[previousFrameIndex]
        } else {
            previosFrame = nil
        }

        process(frame: frames[index], previousFrame: previosFrame)
        
        let confinueFunction: (lhs: Int, rhs: Int) -> Int
        let previousFrame = index
        var nextFrame = nextFrameFunction(lhs: index, rhs: 1)
        if nextFrame >= frames.count {
            nextFrame = frames.count - 2
            confinueFunction = (-)
        }
        else if nextFrame < 0 {
            nextFrame = 1
            confinueFunction = (+)
        } else {
            confinueFunction = nextFrameFunction
        }
        
        DispatchQueue.main.after(when: .now() + frameTime + 1.0) {
            self.runDemo(frame: nextFrame, previousFrameIndex: previousFrame, frames: frames, nextFrameFunction: confinueFunction)
        }
    }
}

public extension ArenaRenderer {
    
    private func process(frame: ArenaFrame, previousFrame: ArenaFrame) {
        var previousRows = Array(previousFrame.map.flatten())
        
        for (y, col) in frame.map.enumerated() {
            for (x, row) in col.enumerated() {
                if let previousRowIndex = previousRows.index(of: row) {
                    previousRows.remove(at: previousRowIndex)
                }
                
                let entity = ArenaFrameEntity(string: row)
                let newIndex = Position(x: x, y: y)
                let previousIndex = previousFrame.find(string: row)
                
                if let previousIndex = previousIndex,
                    let entity = entity where previousIndex != newIndex {
                    move(id: entity.id, from: previousIndex, to: newIndex)
                } else if let entity = entity {
                    insert(entity: makeEntity(type: entity.type, id: entity.id), at: newIndex)
                }
            }
        }
        
        previousRows.forEach { row in
            
            guard let entity = ArenaFrameEntity(string: row),
                let previousIndex = previousFrame.find(string: row) else {
                    return
            }
            remove(id: entity.id, at: previousIndex)
        }
    }
    
    
    private func process(frame: ArenaFrame) {
        for (y, col) in frame.map.enumerated() {
            for (x, row) in col.enumerated() {
                guard let entity = ArenaFrameEntity(string: row) else {
                    continue
                }
                
                insert(entity: makeEntity(type: entity.type, id: entity.id), at: Position(x: x, y: y))
            }
        }
    }
    
    public func process(frame: ArenaFrame, previousFrame: ArenaFrame?) {
        willProcess(frame)
        
        if let previousFrame = previousFrame {
            process(frame: frame, previousFrame: previousFrame)
        } else {
            process(frame: frame)
        }
        
        didProcess(frame)
    }
    
}

public protocol Entity {
    var type: Type { get }
    var id: String { get }
}
