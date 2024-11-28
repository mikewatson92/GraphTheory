//
//  Permutation.swift
//  GraphTheory2
//
//  Created by Mike Watson on 11/30/24.
//

import Foundation

struct Permutation<T> {
    
    static func permute(_ list: [T]) -> [[T]] {
        var permutations: [[T]] = []
        var listToPermute = list
        
        if list.count == 1 {
            return [list]
        }
        
        for i in 0..<list.count {
            let removedElement: T = listToPermute.remove(at: i)
            var remainingPermuted = permute(listToPermute)
            for j in 0..<remainingPermuted.count {
                remainingPermuted[j].insert(removedElement, at: 0)
                permutations.append(remainingPermuted[j])
            }
            listToPermute = list
        }
        return permutations
    }
}
