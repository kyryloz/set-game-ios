//
//  SetGame.swift
//  Set
//
//  Created by Kyrylo Zapylaiev on 8/14/18.
//  Copyright © 2018 Kyrylo Zapylaiev. All rights reserved.
//

import Foundation

class SetGame: Game {
    
    private enum Context {
        case matchedSetOnBoard
        case unmatchedSetOnBoard
        case noContext
    }

    private class State: Codable {
        var cardsInDeck = [Card]()
        var cardsInGame = [Card]()
        var score = 0
    }

    private var state = State()

    private weak var gameDelegate: GameDelegate?
    private let maxCardOnBoard: Int?

    private var cardStates = [Card : Card.CardState]()

    private var selectedCards: [Card] {
        return state.cardsInGame.filter { cardStates[$0] != .unselected }
    }

    private var matchedCards: [Card] {
        return state.cardsInGame.filter { cardStates[$0] == .matched }
    }

    private var unmatchedCards: [Card] {
        return state.cardsInGame.filter { cardStates[$0] == .unmatched }
    }
    
    private var context: Context {
        if matchedCards.count > 0 {
            return .matchedSetOnBoard
        }
        
        if unmatchedCards.count > 0 {
            return .unmatchedSetOnBoard
        }
        
        return .noContext
    }

    init(gameDelegate: GameDelegate, maxCardOnBoard: Int? = Constants.maxCardAmount) {
        self.gameDelegate = gameDelegate
        self.maxCardOnBoard = maxCardOnBoard

        let featurePermutations = GameUtils.calculatePermutations(
            forLength: Constants.featureCountMax,
            withOptions: Array(0..<Constants.featureOptionsCountMax))

        for permutation in featurePermutations {
            let card = Card(features: permutation)
            state.cardsInDeck += [card]
            state.cardsInDeck.shuffle()
        }
    }

    init(fromData data: Data, gameDelegate: GameDelegate, maxCardOnBoard: Int? = Constants.maxCardAmount) {
        let decoder = JSONDecoder()
        self.state = try! decoder.decode(State.self, from: data)
        self.gameDelegate = gameDelegate
        self.maxCardOnBoard = maxCardOnBoard

        self.state.cardsInGame.forEach { cardStates[$0] = .unselected }

        gameDelegate.didDeal(cards: self.state.cardsInGame)
        gameDelegate.didCardInDeckAvailabilityChange(count: self.state.cardsInDeck.count, canDealMore: canDeal(count: 3))
        gameDelegate.didScoreUpdate(score: self.state.score)
    }

    func select(card selectedCard: Card) {
        switch context {
        case .matchedSetOnBoard:
            if !matchedCards.contains(selectedCard) {
                switchSelection(for: selectedCard)
            }

            if canDeal(count: matchedCards.count) {
                dealCards(count: matchedCards.count)
            } else {
                removeMatchedCards()
            }
        case .unmatchedSetOnBoard:
            resetAllSelections()
            switchSelection(for: selectedCard)
        case .noContext:
            fallthrough
        default:
            if selectedCards.count == Constants.featureOptionsCountMax - 1, !selectedCards.contains(selectedCard) {
                let cardsToCheck = selectedCards + [selectedCard]
                let isSet = GameUtils.isSet(cardsToCheck, forFeatureCount: Constants.featureCountMax)

                cardsToCheck.forEach {
                    let selection = isSet ? Card.CardState.matched : .unmatched
                    cardStates[$0] = selection
                    gameDelegate?.didChangeSelection(for: $0, to: selection)
                }

                state.score += isSet ? 3 : -1
                if isSet {
                    gameDelegate?.didCardInDeckAvailabilityChange(count: state.cardsInDeck.count, canDealMore: canDeal(count: cardsToCheck.count))
                }
                gameDelegate?.didScoreUpdate(score: state.score)
            } else {
                switchSelection(for: selectedCard)
            }
        }
    }

    func dealCards(count: Int) {
        assert(count > 0, "Cannot deal negative amount of cards")
        assert(canDeal(count: count), "Cannot deal \(count), only \(state.cardsInDeck.count) left")

        var cardsToDeal = [Card]()
        var cardsToReplaceFrom = [Card]()
        var cardsToReplaceTo = [Card]()

        for _ in 0..<count {
            let nextCard = state.cardsInDeck.removeLast()
            cardStates[nextCard] = .unselected

            if let matchedCard = matchedCards.first, let matchedCardIndex = state.cardsInGame.index(of: matchedCard) {
                let prevCard = state.cardsInGame[matchedCardIndex]
                state.cardsInGame[matchedCardIndex] = nextCard
                cardsToReplaceFrom.append(prevCard)
                cardsToReplaceTo.append(nextCard)
            } else {
                state.cardsInGame.append(nextCard)
                cardsToDeal.append(nextCard)
            }
        }

        if !cardsToReplaceFrom.isEmpty {
            gameDelegate?.didReplace(from: cardsToReplaceFrom, to: cardsToReplaceTo)
        }

        if !cardsToDeal.isEmpty {
            gameDelegate?.didDeal(cards: cardsToDeal)
        }

        gameDelegate?.didCardInDeckAvailabilityChange(count: state.cardsInDeck.count, canDealMore: canDeal(count: count))
    }

    func serialize() -> Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(state)
    }

    private func canDeal(count: Int) -> Bool {
        return state.cardsInGame.count - matchedCards.count + count <= maxCardOnBoard ?? Constants.maxCardAmount
            && state.cardsInDeck.count >= count
    }

    private func removeMatchedCards() {
        let matchedCardIndices = matchedCards.map { state.cardsInGame.index(of: $0)! }
        let removedCards = matchedCards
        state.cardsInGame.remove(at: matchedCardIndices)
        gameDelegate?.didRemove(cards: removedCards)
    }

    private func switchSelection(for card: Card) {
        cardStates[card] = cardStates[card] == .unselected ? .selected : .unselected
        gameDelegate?.didChangeSelection(for: card, to: cardStates[card]!)
    }

    private func resetAllSelections() {
        state.cardsInGame.forEach {
            if cardStates[$0] != .unselected {
                cardStates[$0] = .unselected
                gameDelegate?.didChangeSelection(for: $0, to: .unselected)
            }
        }
    }
}

extension SetGame {
    private struct Constants {
        static let featureCountMax = 4
        static let featureOptionsCountMax = 3

        static var maxCardAmount: Int {
            return Int(pow(Double(featureOptionsCountMax), Double(featureCountMax)))
        }
    }
}
