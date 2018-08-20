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
}
