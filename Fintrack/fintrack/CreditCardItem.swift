//
//  CreditCardItem.swift
//  fintrack
//
//  Created by Adrian Rodriguez Llorens on 07/01/26.
//

// CreditCardItem.swift
import Foundation

// MARK: - Model
struct CreditCardItem: Identifiable, Codable, Equatable {
    var id: UUID

    let bankCode: String
    let bankName: String
    let cardType: String

    let lastDigits: String
    let cutDate: Date
    let dueDate: Date
    var isPaid: Bool

    init(
        id: UUID = UUID(),
        bankCode: String,
        bankName: String,
        cardType: String,
        lastDigits: String,
        cutDate: Date,
        dueDate: Date,
        isPaid: Bool
    ) {
        self.id = id
        self.bankCode = bankCode
        self.bankName = bankName
        self.cardType = cardType
        self.lastDigits = lastDigits
        self.cutDate = cutDate
        self.dueDate = dueDate
        self.isPaid = isPaid
    }
}

// MARK: - Business Logic (status + assets)
extension CreditCardItem {

    enum StatusStyle {
        case green, orange, red, gray
    }

    var daysRemaining: Int {
        Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: dueDate)
        ).day ?? 0
    }

    var statusText: String {
        if isPaid { return "Pagado" }
        if daysRemaining < 0 { return "Pago vencido" }
        if daysRemaining == 0 { return "Vence hoy" }
        return "Faltan \(daysRemaining) días"
    }

    var statusStyle: StatusStyle {
        if isPaid { return .gray }
        if daysRemaining < 0 { return .red }
        if daysRemaining <= 5 { return .orange }
        return .green
    }

    // Asset naming
    var cardTypeCode: String {
        cardType
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .folding(options: .diacriticInsensitive, locale: .current)
    }

    var preferredAssetName: String { "\(bankCode)_\(cardTypeCode)" }
    var fallbackAssetName: String { bankCode }
}
