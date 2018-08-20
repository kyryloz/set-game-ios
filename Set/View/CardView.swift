//
//  CardView.swift
//  Set
//
//  Created by Kyrylo Zapylaiev on 8/6/18.
//  Copyright © 2018 Kyrylo Zapylaiev. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    enum Symbol {
        case diamond
        case circle
        case square
    }
    
    enum Shading {
        case solid
        case open
        case stripped
    }
    
    enum Highlighting {
        case none
        case selected
        case matched
        case unmatched
    }
    
    var symbol: Symbol = Symbol.diamond { didSet { setNeedsDisplay() } }
    var shading: Shading = Shading.solid { didSet { setNeedsDisplay() } }

    var highlighting: Highlighting = Highlighting.none {
        didSet {
            var selectionTransformation = CGAffineTransform.init(scaleX: 1.02, y: 1.02)
            var selectionShadowRadius: CGFloat = 4

            switch highlighting {
            case .selected:
                layer.borderWidth = Constants.highlightingBorderWidth
                layer.borderColor = #colorLiteral(red: 0.08235294118, green: 0.568627451, blue: 0.5725490196, alpha: 0.6996200771)
                layer.cornerRadius = Constants.cornerRadius
            case .matched:
                layer.borderWidth = Constants.highlightingBorderWidth
                layer.borderColor = #colorLiteral(red: 0.1755383771, green: 0.8784866043, blue: 0.1972928789, alpha: 1)
                layer.cornerRadius = Constants.cornerRadius
            case .unmatched:
                layer.borderWidth = Constants.highlightingBorderWidth
                layer.borderColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                layer.cornerRadius = Constants.cornerRadius
            default:
                selectionTransformation = .identity
                selectionShadowRadius = 1
                layer.borderWidth = 0
                layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                layer.cornerRadius = 0
            }

            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.2,
                delay: 0,
                options: [.allowUserInteraction],
                animations: {
                    self.transform = selectionTransformation
                    self.layer.shadowRadius = selectionShadowRadius
                },
                completion: nil)
            }
    }

    var repetition: Int = 1 { didSet { setNeedsDisplay() } }
    var color: UIColor = UIColor.blue { didSet { setNeedsDisplay() } }

    var isFaceUp = true { didSet { setNeedsDisplay() } }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        isOpaque = false
        contentMode = UIViewContentMode.redraw
        layer.masksToBounds = false
        layer.shadowOffset = .zero
        layer.shadowRadius = 1
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: Constants.cornerRadius)
        roundedRect.addClip()
        
        if isFaceUp {
            drawCardFace(path: roundedRect)
        } else {
            drawCardBack(path: roundedRect)
        }
    }

    private func drawCardFace(path: UIBezierPath) {
        UIColor.white.setFill()
        path.fill()

        var symbolDrawPoints = [CGPoint]()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        switch self.repetition {
        case 1:
            symbolDrawPoints += [center]
        case 2:
            symbolDrawPoints += [center.offsetBy(dx: -Constants.symbolSpacingBetweenCenters / 2, dy: 0),
                                 center.offsetBy(dx: Constants.symbolSpacingBetweenCenters / 2, dy: 0)]
        case 3:
            symbolDrawPoints += [center,
                                 center.offsetBy(dx: Constants.symbolSpacingBetweenCenters, dy: 0),
                                 center.offsetBy(dx: -Constants.symbolSpacingBetweenCenters, dy: 0)]
        default:
            break
        }

        var symbols = [UIBezierPath]()
        for point in symbolDrawPoints {
            switch symbol {
            case .diamond:
                symbols.append(drawDiamond(centeredIn: point))
            case .circle:
                symbols.append(drawCircle(centeredIn: point))
            case .square:
                symbols.append(drawSquare(centeredIn: point))
            }
        }

        let context = UIGraphicsGetCurrentContext()!

        switch shading {
        case .stripped:
            context.saveGState()

            addStrippedMask()
            color.withAlphaComponent(0.4).setFill()
            symbols.forEach { path in path.fill() }

            context.restoreGState()

            color.setStroke()
            symbols.forEach { path in path.stroke() }
        case .solid:
            color.setFill()
            symbols.forEach { path in path.fill() }
        case .open:
            color.setStroke()
            symbols.forEach { path in path.stroke() }
        }
    }

    private func drawCardBack(path: UIBezierPath) {
        self.tintColor.setFill()
        path.fill()
    }

    private func drawDiamond(centeredIn point: CGPoint) -> UIBezierPath {
        let symbolWidth = Constants.symbolSize
        let symbolHeight = Constants.symbolSize + Constants.symbolSize / 3.0

        let path = UIBezierPath()
        path.move(to: CGPoint(x: point.x, y: point.y))
        path.addLine(to: CGPoint(x: point.x + symbolWidth / 2, y: point.y - symbolHeight / 2))
        path.addLine(to: CGPoint(x: point.x + symbolWidth, y: point.y))
        path.addLine(to: CGPoint(x: point.x + symbolWidth / 2, y: point.y + symbolHeight / 2))
        path.close()
        path.apply(CGAffineTransform(translationX: -symbolWidth / 2, y: 0))

        return path
    }

    private func drawCircle(centeredIn point: CGPoint) -> UIBezierPath {
        let symbolWidth = Constants.symbolSize
        let symbolHeight = Constants.symbolSize

        let rect = CGRect(origin: point.offsetBy(dx: -symbolWidth / 2, dy: -symbolHeight / 2),
                          size: CGSize(width: symbolWidth, height: symbolHeight))
        let path = UIBezierPath(ovalIn: rect)

        return path
    }

    private func drawSquare(centeredIn point: CGPoint) -> UIBezierPath {
        let symbolWidth = Constants.symbolSize
        let symbolHeight = Constants.symbolSize

        let rect = CGRect(origin: point.offsetBy(dx: -symbolWidth / 2, dy: -symbolHeight / 2),
                          size: CGSize(width: symbolWidth, height: symbolHeight))
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 2)

        return path
    }

    private func addStrippedMask() {
        let strips = UIBezierPath()
        for i in 0..<(Int(bounds.width) / Int(Constants.stripWidth)) {
            let strippedRect = CGRect(x: CGFloat(i) * Constants.stripWidth * Constants.stripStep,
                                      y: 0.0,
                                      width: Constants.stripWidth,
                                      height: bounds.height)
            strips.append(UIBezierPath(rect: strippedRect))
        }
        strips.addClip()
        UIColor.clear.setFill()
        strips.fill()
    }
}

extension CardView {
    private struct Constants {
        static let cornerRadius: CGFloat = 5
        static let highlightingBorderWidth: CGFloat = 1

        static let stripWidth: CGFloat = 1
        static let stripStep: CGFloat = 4

        static let symbolSize: CGFloat = 22
        static let symbolSpacingBetweenCenters: CGFloat = 26.0
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}
