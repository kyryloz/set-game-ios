//
//  ModelDelegate.swift
//  Set
//
//  Created by Kyrylo Zapylaiev on 8/12/18.
//  Copyright © 2018 Kyrylo Zapylaiev. All rights reserved.
//

import Foundation

protocol GameDelegate: class {
    func didDeal(cards: [Card])
    
    func didRemove(cards: [Card])
    
    func didReplace(from oldCards: [Card], to newCards: [Card])
    
    func didChangeSelection(for card: Card, to selection: Card.CardState)
    
    func didScoreUpdate(score: Int)
    
    func didCardInDeckAvailabilityChange(count: Int, canDealMore: Bool)
}
