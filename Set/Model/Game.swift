//
//  SetGame.swift
//  Set
//
//  Created by Kyrylo Zapylaiev on 8/14/18.
//  Copyright © 2018 Kyrylo Zapylaiev. All rights reserved.
//

import Foundation

protocol Game {
    func select(card: Card)

    func dealCards(count: Int, withPenalty: Bool)

    func serialize() -> Data

    func isGameFinished() -> Bool

    func areThereAnySetsInGame() -> Bool
}
