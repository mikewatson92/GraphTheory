//
//  Permutation.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/7/24.
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
    
    static func permute(_ list: [T], r: Int) -> [[T]]? {
        guard r <= list.count else { return nil }
        guard r > 0 else { return nil }
        
        // Base case
        if list.count == r {
            return permute(list)
        } else if r == 1 {
            var permutations: [[T]] = []
            for item in list {
                permutations.append([item])
            }
            return permutations
        }
        
        var permutations: [[T]] = []
        var listToPermute = list
        // Base case
        if list.count == 1 { return [list]}
        
        // Recursive step
        for i in 0..<list.count {
            let removedElement: T = listToPermute.remove(at: i)
            var remainingPermuted = permute(listToPermute, r: r - 1)!
            for j in 0..<remainingPermuted.count {
                remainingPermuted[j].insert(removedElement, at: 0)
                permutations.append(remainingPermuted[j])
            }
            listToPermute = list
        }
        
        return permutations
    }
}
