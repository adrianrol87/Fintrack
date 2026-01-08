//
//  CardsStorage.swift
//  fintrack
//
//  Created by Adrian Rodriguez Llorens on 07/01/26.
//

// CardsStorage.swift
import Foundation

// MARK: - Persistence
enum CardsStorage {
    private static let key = "credit_cards_items_v1"

    static func load() -> [CreditCardItem] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let items = try? JSONDecoder().decode([CreditCardItem].self, from: data)
        else { return [] }
        return items
    }

    static func save(_ items: [CreditCardItem]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

