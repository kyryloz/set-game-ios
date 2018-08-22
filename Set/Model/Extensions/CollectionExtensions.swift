//
//  ArrayExtensions.swift
//  Set
//
//  Created by Kyrylo Zapylaiev on 8/4/18.
//  Copyright © 2018 Kyrylo Zapylaiev. All rights reserved.
//

import Foundation

extension MutableCollection {
    
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Collection {
    func all(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        for item in self {
            let result = try predicate(item)
            
            if !result {
                return false
            }
        }
        
        return true
    }
    
    func single() -> Element? {
        return count == 1 ? first : nil
    }

    func skipNulls() -> [Element] {
        return compactMap { $0 }
    }
}

extension Collection where Element: Hashable {
    
    func areAllItemsSameOrAllDifferent() -> Bool {
        return allSame() || allDifferent()
    }

    func allSame() -> Bool {
        return uniqCount() <= 1
    }

    func allDifferent() -> Bool {
        return uniqCount() == self.count
    }
    
    func uniqCount() -> Int {
        return Set(self).count
    }
}

extension Array {
    mutating func remove(at indexes: [Int]) {
        for index in indexes.sorted(by: >) {
            remove(at: index)
        }
    }
}

extension Sequence {
    
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
