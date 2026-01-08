//
//  CardComponents.swift
//  fintrack
//
//  Created by Adrian Rodriguez Llorens on 07/01/26.
//

// CardComponents.swift
import SwiftUI
import UIKit

// MARK: - UI Components
struct StatusBadge: View {
    let text: String
    let style: CreditCardItem.StatusStyle

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .clipShape(Capsule())
    }

    private var color: Color {
        switch style {
        case .green: return Color(.statusGreen)
        case .orange: return Color(.statusOrange)
        case .red: return Color(.statusRed)
        case .gray: return Color(.statusGray)
        }
    }
}

struct CardImageView: View {
    let preferred: String
    let fallback: String

    var body: some View {
        if UIImage(named: preferred) != nil {
            Image(preferred).resizable().scaledToFill()
        } else if UIImage(named: fallback) != nil {
            Image(fallback).resizable().scaledToFill()
        } else {
            Image("generic").resizable().scaledToFill()
        }
    }
}

struct CardRowView: View {
    @Binding var item: CreditCardItem
    let onPaid: (CreditCardItem) -> Void

    private var borderColor: Color {
        switch item.statusStyle {
        case .green: return Color(.statusGreen).opacity(0.45)
        case .orange: return Color(.statusOrange).opacity(0.55)
        case .red: return Color(.statusRed).opacity(0.65)
        case .gray: return Color(.statusGray).opacity(0.35)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {

                CardImageView(
                    preferred: item.preferredAssetName,
                    fallback: item.fallbackAssetName
                )
                .frame(width: 120, height: 76)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(item.bankName) \(item.cardType)")
                        .font(.headline)

                    Text("Terminación • \(item.lastDigits)")
                        .foregroundStyle(.secondary)

                    Text("Corte: \(format(item.cutDate))")
                        .foregroundStyle(.secondary)

                    Text("Límite: \(format(item.dueDate))")
                        .foregroundStyle(.secondary)

                    StatusBadge(text: item.statusText, style: item.statusStyle)
                        .padding(.top, 4)
                }
                Spacer()
            }

            Button {
                withAnimation(.easeInOut(duration: 0.5)) {
                    item.isPaid.toggle()
                }
                onPaid(item)
            } label: {
                Label(
                    item.isPaid ? "Pagado" : "Marcar como pagado",
                    systemImage: item.isPaid ? "checkmark.circle.fill" : "checkmark.circle"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(item.isPaid ? Color(.systemGray6) : Color("AccentSoft"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .opacity(item.isPaid ? 0.9 : 1.0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.cardBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(borderColor, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 6)
    }

    private func format(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_MX")
        f.dateFormat = "dd/MM/yyyy"
        return f.string(from: date)
    }
}

