//
//  ViewController.swift
//  Set
//
//  Created by Kyrylo Zapylaiev on 8/3/18.
//  Copyright © 2018 Kyrylo Zapylaiev. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, CardViewTapDelegate, GameDelegate {

    @IBOutlet weak var cardBoardView: CardBoard!
    @IBOutlet weak var buttonDrawNext: UIButton!
    @IBOutlet weak var scoreText: UILabel!
    @IBOutlet weak var discardPileView: UIView!
    
    @IBAction func didDealPress(_ sender: Any) {
        game.dealCards(count: 3)
    }

    var stateData: Data?

    private var game: Game!
    
    private let cardViewDataAdapter = CardViewDataAdapter()
    
    private var cardViews = [Card: CardView]()
    
    func didDeal(cards: [Card]) {
        let cardViewItems = cards.map { (card) -> CardView in
            let cardView = CardView()
            cardViewDataAdapter.configure(cardView: cardView, forCard: card)
            cardViews[card] = cardView
            return cardView
        }

        cardBoardView.addCardViews(cardViewItems)
    }
    
    func didRemove(cards: [Card]) {
        let cardViewItems = cards
            .map { card -> CardView? in
                if let cardView = cardViews[card] {
                    cardViews[card] = nil
                    return cardView
                } else {
                    return nil
                }
            }
            .compactMap { $0 }

        cardBoardView.removeCardViews(cardViewItems)
    }
    
    func didReplace(from oldCards: [Card], to newCards: [Card]) {
        assert(oldCards.count == newCards.count)

        let cardViewItemsToReplaceFrom = oldCards
            .map { card -> CardView? in
                if let cardView = cardViews[card] {
                    cardViews[card] = nil
                    return cardView
                } else {
                    return nil
                }

            }
            .compactMap { $0 }

        let cardViewItemsToReplaceTo = newCards.map { (card) -> CardView in
            let cardView = CardView()
            cardViewDataAdapter.configure(cardView: cardView, forCard: card)
            cardViews[card] = cardView
            return cardView
        }

        cardBoardView.replaceCardView(from: cardViewItemsToReplaceFrom, to: cardViewItemsToReplaceTo)
    }
    
    func didChangeSelection(for card: Card, to selection: Card.CardState) {
        if let cardView = cardViews[card] {
            cardViewDataAdapter.updateHighlighting(for: cardView, with: selection)
        }
    }
    
    func didScoreUpdate(score: Int) {
        scoreText.text = "Score: \(score)"
    }
    
    func didCardInDeckAvailabilityChange(count: Int, canDealMore: Bool) {
        buttonDrawNext.isEnabled = canDealMore
        buttonDrawNext.alpha = canDealMore ? 1 : 0.5
    }

    func didTap(cardView: CardView) {
        if let card = cardViews.someKey(forValue: cardView) {
            game.select(card: card)
        }
    }

    override func viewDidLoad() {
        cardBoardView.tapDelegate = self
        cardBoardView.deckView = buttonDrawNext
        cardBoardView.discardView = discardPileView
    }

    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParentViewController {
            UserDefaults.standard.set(game.serialize(), forKey: "state")
        }
    }

    override func viewDidLayoutSubviews() {
        if game == nil {
            if let data = stateData {
                game = SetGame(fromData: data, gameDelegate: self, maxCardOnBoard: 24)
            } else {
                game = SetGame(gameDelegate: self, maxCardOnBoard: 24)
                cardViews = [:]
                cardBoardView.clear()
                game.dealCards(count: 12)
            }
        }
    }
}
