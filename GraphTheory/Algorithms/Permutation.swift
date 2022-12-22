//
//  Permutation.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import Foundation

public class Permutation {
    
    static func permuteVertices(_ values: [Vertex]) -> [[Vertex]]{
        var values = values
        var newValues = values
        var permutations: [[Vertex]] = []
        
        func swap(_ pair: [Vertex]) -> [Vertex] {
            var pair = pair
            let tempA = pair[0]
            pair[0] = pair[1]
            pair[1] = tempA
            return pair
        }
        
        func swap(_ first: Int, _ second: Int) -> [Vertex] {
            let tempFirst = values[first]
            var newValues = values
            newValues[first] = newValues[second]
            newValues[second] = tempFirst
            return newValues
        }
        
        if values.count == 2 {
            permutations.append(values)
            values = swap(values)
            permutations.append(values)
            return permutations
        } else {
            for i in 0..<values.count {
                newValues = swap(0, i)
                let shortenedValues = newValues.suffix(from: 1)
                let shortPermutations = permuteVertices(Array(shortenedValues))
                for shortPermuted in shortPermutations {
                    var temp = shortPermuted
                    temp.insert(newValues[0], at: 0)
                    permutations.append(temp)
                }
            }
            return permutations
        }
    }
}
