//
//  CardBoard.swift
//  Set
//
//  Created by Kyrylo Zapylaiev on 8/6/18.
//  Copyright © 2018 Kyrylo Zapylaiev. All rights reserved.
//

import UIKit

@IBDesignable
class CardBoard: UIView {
    
    private var grid: Grid = Grid(layout: Grid.Layout.dimensions(rowCount: 1, columnCount: 1))
    
    private var cards = [CardView]()
    
    var deckView: UIView!
    var discardView: UIView!
    
    var tapDelegate: CardViewTapDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CardBoard.onTap(recognizer:)))
        addGestureRecognizer(tapRecognizer)
        contentMode = UIViewContentMode.redraw
    }
    
    @objc func onTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let cardView = hitTest(recognizer.location(ofTouch: 0, in: self), with: nil) as? CardView {
                tapDelegate?.didTap(cardView: cardView)
            }
        default:
            break
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        layoutCards()
    }

    func addCardViews(_ cardViews: [CardView]) {
        cards += cardViews

        cardViews.forEach {
            self.addSubview($0)
        }

        layoutCards()

        for index in cardViews.indices {
            self.animateCardAdding(cardViews[index], withDelay: TimeInterval(Double(index) / 10.0))
        }
    }
    
    func removeCardViews(_ cardViews: [CardView]) {
        for index in cardViews.indices {
            if let cardIndex = cards.index(of: cardViews[index]) {
                let removedCardView = cards.remove(at: cardIndex)
                animateCardRemoving(removedCardView, withDelay: TimeInterval(Double(index) / 10.0))
            }
        }

        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false, block: { _ in
            self.layoutCards()
        })
    }
    
    func replaceCardView(from oldCardViews: [CardView], to newCardViews: [CardView]) {
        assert(oldCardViews.count == newCardViews.count)

        var newCardInsertIndices = [Int]()

        for index in oldCardViews.indices {
            if let oldCardViewIndex = cards.index(of: oldCardViews[index]) {
                let removedCardView = cards.remove(at: oldCardViewIndex)

                animateCardRemoving(removedCardView, withDelay: TimeInterval(Double(index) / 10.0))

                newCardInsertIndices.insert(oldCardViewIndex, at: 0)
            }
        }

        for index in newCardViews.indices {
            let newCardView = newCardViews[index]
            self.cards.insert(newCardView, at: newCardInsertIndices[index])
            newCardView.isHidden = true
            self.addSubview(newCardView)
        }

        layoutCards()

        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
            for index in newCardViews.indices {
                self.animateCardAdding(newCardViews[index], withDelay: TimeInterval(Double(index) / 10.0))
            }
        })
    }
    
    func clear() {
        for view in cards {
            view.removeFromSuperview()
        }
        cards = []
    }

    private func layoutCards() {
        grid.frame = bounds
        var rowCount = Int(ceil(Double(cards.count) / 3.0))
        if (rowCount <= 1) {
            rowCount = 2
        }
        grid.dimensions = (rowCount: rowCount, columnCount: 3)

        for index in self.cards.indices {
            if let cellBounds = self.grid[index] {
                let cardViewItem = self.cards[index]

                if cardViewItem.frame == .zero {
                    cardViewItem.frame = cellBounds.insetBy(dx: 5, dy: 5)
                } else {
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.5,
                        delay: 0,
                        options: [.curveEaseOut],
                        animations: {
                            cardViewItem.frame = cellBounds.insetBy(dx: 5, dy: 5)
                    },
                        completion: nil)
                }
            }
        }
    }

    private func animateCardAdding(_ cardView: CardView, withDelay delay: TimeInterval) {
        cards.forEach { sendSubview(toBack: $0)}
        bringSubview(toFront: cardView)

        let originalFrame = cardView.frame
        cardView.isHidden = true
        cardView.frame = self.superview!.convert(self.deckView.frame, to: self)

        cardView.isHidden = false
        cardView.isFaceUp = false

        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: delay,
            options: [.curveEaseInOut],
            animations: {
                cardView.frame = originalFrame
            },
            completion: { _ in
                UIView.transition(with: cardView,
                                  duration: 0.4,
                                  options: [.transitionFlipFromRight],
                                  animations: {
                                      cardView.isFaceUp = true
                                      self.sendSubview(toBack: cardView)
                                  })
                })
    }
    
    private func animateCardRemoving(_ cardView: CardView, withDelay delay: TimeInterval) {
        cards.forEach { sendSubview(toBack: $0)}
        bringSubview(toFront: cardView)

        cardView.highlighting = .none
        UIView.transition(with: cardView,
                          duration: 0.4,
                          options: [.transitionFlipFromLeft],
                          animations: {
                              cardView.isFaceUp = false
                          },
                          completion: { _ in
                             UIViewPropertyAnimator.runningPropertyAnimator(
                                 withDuration: 0.5,
                                 delay: delay,
                                 options: [.curveEaseInOut],
                                 animations: {
                                     cardView.frame = self.superview!.convert(self.discardView.frame, to: self)
                             },
                                 completion: { _ in
                                     cardView.removeFromSuperview()
                             })
                          })
    }
}

extension CGFloat {
    var arc4random: CGFloat {
        return self * (CGFloat(arc4random_uniform(UInt32.max)) / CGFloat(UInt32.max))
    }
}
