//
//  GraphTheoryApp.swift
//  GraphTheory
//
//  Created by ワトソン・マイク on 2022/12/22.
//

import SwiftUI

extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16 //maximum digits in Double after dot (maximum precision)
        return String(formatter.string(from: number) ?? "")
    }
}

extension Binding {
    func optionalBinding<T>() -> Binding<T>? where T? == Value {
        if let wrappedValue = wrappedValue {
            return Binding<T>(
                get: { wrappedValue },
                set: { self.wrappedValue = $0 }
            )
        } else {
            return nil
        }
    }
}

let darkGray: Color = Color(red: 0.13, green: 0.13, blue: 0.13)

let decFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
}()

let intFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .none
    return formatter
}()

extension Array {
    func copiedElements() -> Array<Element> {
        return self.map{
            let copiable = $0 as! NSCopying
            return copiable.copy() as! Element
        }
    }
}

@main
struct GraphTheoryApp: App {
    @StateObject var model: ModelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}
