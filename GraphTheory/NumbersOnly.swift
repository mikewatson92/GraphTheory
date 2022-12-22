//
//  NumbersOnly.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
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
