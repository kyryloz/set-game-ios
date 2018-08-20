//
//  Card.swift
//  Set
//
//  Created by Kyrylo Zapylaiev on 8/3/18.
//  Copyright © 2018 Kyrylo Zapylaiev. All rights reserved.
//

import Foundation

struct Card: Hashable, Codable {

    enum CardState {
        case unselected
        case selected
        case matched
        case unmatched
    }
    
    private static var currentIdentifier = 0
    
    private static func nextIdentifier() -> Int {
        currentIdentifier += 1
        return currentIdentifier
    }
    
    private let identifier: Int
    
    let features: [Int]
    
    init(features: [Int]) {
        self.features = features
        self.identifier = Card.nextIdentifier()
    }
    
    var hashValue: Int {
        return identifier
    }
}
