//
//  Array.swift
//  BattleBots
//
//  Created by Andrew Carter on 6/25/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

extension Array {
    
    func random() -> Element {
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
    
}
