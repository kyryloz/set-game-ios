//
//  CardViewDataAdapter.swift
//  Set
//
//  Created by Kyrylo Zapylaiev on 8/13/18.
//  Copyright © 2018 Kyrylo Zapylaiev. All rights reserved.
//

import UIKit

struct CardViewDataAdapter {
    func configure(cardView: CardView, forCard card: Card) {
        let cardFeatures = card.features
        let colorFeature = cardFeatures.indices.contains(0) ? cardFeatures[0] : nil
        let symbolFeature = cardFeatures.indices.contains(1) ? cardFeatures[1] : nil
        let shadeFeature = cardFeatures.indices.contains(2) ? cardFeatures[2] : nil
        let amountFeature = cardFeatures.indices.contains(3) ? cardFeatures[3] : nil
        
        let color: UIColor = {
            switch colorFeature {
            case 0:
                return #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            case 1:
                return #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            case 2:
                return #colorLiteral(red: 0.122511141, green: 0.3951282501, blue: 0.9791532159, alpha: 1)
            default:
                return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
        }()
        
        let symbol: CardView.Symbol = {
            switch symbolFeature {
            case 0:
                return .triangle
            case 1:
                return .circle
            case 2:
                return .square
            default:
                return .triangle
            }
        }()

        let shading: CardView.Shading = {
            switch shadeFeature {
            case 0:
                return .solid
            case 1:
                return .open
            case 2:
                return .stripped
            default:
                return .solid
            }
        }()
        
        cardView.color = color
        cardView.shading = shading
        cardView.repetition = amountFeature != nil ? (amountFeature! + 1) : 1
        cardView.symbol = symbol
    }
    
    func updateHighlighting(for cardView: CardView, with selectionState: Card.CardState) {
        switch selectionState {
        case .selected:
            cardView.highlighting = .selected
        case .matched:
            cardView.highlighting = .matched
        case .unmatched:
            cardView.highlighting = .unmatched
        default:
            cardView.highlighting = .none
        }
    }
}
