//
//  DoubleFactorial.swift
//  GraphTheory
//
//  Created by Mike Watson on 12/25/24.
//

import Foundation

struct DoubleFactorial {
    private func evenDoubleFactorial(n: Int) -> Int {
        if n == 2 {
            return 2
        } else {
            return n * evenDoubleFactorial(n: n - 2)
        }
    }
    
    private func oddDoubleFactorial(n: Int) -> Int {
        if n == 1 {
            return 1
        } else {
            return n * oddDoubleFactorial(n: n - 2)
        }
    }
    
    func doubleFactorial(n: Int) -> Int? {
        guard n > 0 else { return nil }
        if n % 2 == 0 {
            return evenDoubleFactorial(n: n)
        } else {
            return oddDoubleFactorial(n: n)
        }
    }
}
