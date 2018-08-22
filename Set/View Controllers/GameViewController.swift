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
    @IBOutlet weak var scoringLabel: UILabel!
    
    @IBAction func didDealPress(_ sender: Any) {
        if game.canDealWithoutPenalty() {
            game.dealCards(count: 3, withPenalty: false)
        } else {
            let alert = UIAlertController(title: "Oops",
                                          message: "There is set on the board. Dealing more cards will cost you 3 points. Still want to deal more?",
                                          preferredStyle: UIAlertControllerStyle.alert)

            alert.addAction(UIAlertAction(title: "No, forget it", style: UIAlertActionStyle.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes, I can't find any!", style: UIAlertActionStyle.default, handler: { _ in
                self.game.dealCards(count: 3, withPenalty: true)
            }))

            self.present(alert, animated: true, completion: nil)
        }
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
    
    func didScoreUpdate(sumScore: Int, lastMoveScore: Score?) {
        scoreText.text = "Score: \(sumScore)"

        if let score = lastMoveScore {
            UserDefaults.standard.set(game.serialize(), forKey: "state")

            scoringLabel.text = {
                switch score {
                case .veryNegative:
                    return "Booo (( \(score.rawValue) points."
                case .negative:
                    return "That's wrong. \(score.rawValue) point."
                case .low:
                    return "OK. \(score.rawValue) point."
                case .medium:
                    return "Good! \(score.rawValue) points."
                case .high:
                    return "Like a boss! \(score.rawValue) points."
                case .highest:
                    return "WOW! I like you! \(score.rawValue) points."
                }
            }()

            scoringLabel.textColor = {
                switch score {
                case .veryNegative:
                    return #colorLiteral(red: 0.9374603426, green: 0.07006900477, blue: 0, alpha: 1)
                case .negative:
                    return #colorLiteral(red: 0.7733978426, green: 0.006644498635, blue: 0.04286223362, alpha: 1)
                case .low:
                    return #colorLiteral(red: 0.1231316989, green: 0.3867650947, blue: 0.2095457099, alpha: 1)
                case .medium:
                    return #colorLiteral(red: 0.1578833635, green: 0.585996986, blue: 0.2998679061, alpha: 1)
                case .high:
                    return #colorLiteral(red: 0, green: 0.7802189086, blue: 0.01377618002, alpha: 1)
                case .highest:
                    return #colorLiteral(red: 0.9969027123, green: 0, blue: 1, alpha: 1)
                }
            }()

            scoringLabel.alpha = 0
            scoringLabel.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)

            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.3,
                delay: 0,
                options: [.curveEaseIn],
                animations: {
                    self.scoringLabel.alpha = 1
                    self.scoringLabel.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
                },
                completion: { _ in
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 2,
                        delay: 1,
                        options: [.curveEaseIn],
                        animations: {
                            self.scoringLabel.alpha = 0
                            self.scoringLabel.transform = .identity
                        },
                        completion: nil)
                })
        }
    }
    
    func didCardInDeckAvailabilityChange(count: Int, canDealMore: Bool) {
        buttonDrawNext.isEnabled = canDealMore
        buttonDrawNext.alpha = canDealMore ? 1 : 0.3
    }

    func didGameFinish(score: Int) {
        let prevHighScore = UserDefaults.standard.integer(forKey: "highScore")

        var message = "You've scored \(score) points"

        if score > prevHighScore {
            UserDefaults.standard.set(score, forKey: "highScore")
            message = "You've scored \(score) points. That's a highscore!"
        }

        let alert = UIAlertController(title: "No sets left",
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "New game", style: UIAlertActionStyle.cancel, handler: { _ in
            self.startNewGame()
        }))
        alert.addAction(UIAlertAction(title: "Finish", style: UIAlertActionStyle.default, handler: { _ in
            self.finishGame()
        }))

        self.present(alert, animated: true, completion: nil)
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

    override func viewDidLayoutSubviews() {
        if game == nil {
            if let data = stateData {
                continueGame(data: data)
            } else {
                startNewGame()
            }
        }
    }

    private func startNewGame() {
        game = SetGame(gameDelegate: self, maxCardOnBoard: 24)
        cardViews = [:]
        cardBoardView.clear()
        game.dealCards(count: 12, withPenalty: false)
    }

    private func continueGame(data: Data) {
        game = SetGame(fromData: data, gameDelegate: self, maxCardOnBoard: 24)
    }

    private func finishGame() {
        UserDefaults.standard.removeObject(forKey: "state")
        UserDefaults.standard.synchronize()
        navigationController?.popViewController(animated: true)
    }
}
