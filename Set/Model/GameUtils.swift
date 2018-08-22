//
//  GameUtils.swift
//  Set
//
//  Created by Kyrylo Zapylaiev on 8/5/18.
//  Copyright © 2018 Kyrylo Zapylaiev. All rights reserved.
//

import Foundation

class GameUtils {
    static func calculatePermutations(forLength length: Int, withOptions options: [Int]) -> [[Int]] {
        assert(length > 0, "Length must be > 0")
        
        if length == 1 {
            return options.map { [$0] }
        }
        
        var permutations: [[Int]] = []
        
        options.forEach { option in
            calculatePermutations(forLength: length - 1, withOptions: options).forEach { permutation in
                let permutation = [option] + permutation
                permutations.append(permutation)
            }
        }
        
        return permutations
    }
    
    static func isSet(_ cards: [Card], forFeatureCount featureCount: Int) -> Bool {
        if cards.isEmpty {
            return false
        }
        
        for featureIndex in 0..<featureCount {
            let cardFeatures = cards.map { $0.features[featureIndex] }
            if !cardFeatures.areAllItemsSameOrAllDifferent() {
                return false
            }
        }
        
        return true
    }

    static func calculateScore(_ cards: [Card]) -> Score {
        assert(!cards.isEmpty)
        assert(isSet(cards, forFeatureCount: cards.first?.features.count ?? 0))

        var differentFeaturesCount = 0

        for featureIndex in 0..<(cards.first?.features.count ?? 0) {
            let cardFeatures = cards.map { $0.features[featureIndex] }
            if cardFeatures.allDifferent() {
                differentFeaturesCount += 1
            }
        }

        return Score(rawValue: differentFeaturesCount)!
    }

    static func containsSet(in cards: [Card], forFeatureCount featureCount: Int) -> Bool {
        if cards.count == 0 {
            return false
        }

        if cards.count >= 21 {
            return true
        }

        for first in 0..<cards.count {
            for second in (first + 1)..<cards.count {
                for third in (second + 1)..<cards.count {
                    let maybeSet = [cards[first], cards[second], cards[third]]
                    if isSet(maybeSet, forFeatureCount: featureCount) {
                        return true
                    }
                }
            }
        }

        return false
    }
}
