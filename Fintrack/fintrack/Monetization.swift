//
//  Monetization.swift
//  fintrack
//
//  Created by Adrian Rodriguez Llorens on 07/01/26.
//

// Monetization.swift
import Foundation

// MARK: - Pro (flag + limits)
enum ProManager {
    private static let key = "fintrack_is_pro_v1"

    static var isPro: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

enum Monetization {
    static let freeCardsLimit = 3
}

