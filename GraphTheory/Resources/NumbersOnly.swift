//
//  NumbersOnly.swift
//  GraphTheory
//
//  Created by Mike Watson on 11/26/24.
//

import Foundation

class NumbersOnly: ObservableObject {
    @Published var value = "" {
        didSet {
            let filtered = value.filter { $0.isNumber }
            
            if value != filtered {
                value = filtered
            }
        }
    }
}
