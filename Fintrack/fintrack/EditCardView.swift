//
//  EditCardView.swift
//  fintrack
//
//  Created by Adrian Rodriguez Llorens on 07/01/26.
//

// EditCardView.swift
import SwiftUI

// MARK: - Edit View
struct EditCardView: View {
    let original: CreditCardItem
    let onSave: (CreditCardItem) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var selectedBankId: String
    @State private var selectedCardType: String
    @State private var lastDigits: String
    @State private var cutDate: Date
    @State private var dueDate: Date

    init(item: CreditCardItem, onSave: @escaping (CreditCardItem) -> Void) {
        self.original = item
        self.onSave = onSave

        _selectedBankId = State(initialValue: item.bankCode)
        _selectedCardType = State(initialValue: item.cardType)
        _lastDigits = State(initialValue: item.lastDigits)
        _cutDate = State(initialValue: item.cutDate)
        _dueDate = State(initialValue: item.dueDate)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tarjeta") {
                    Picker("Banco", selection: $selectedBankId) {
                        ForEach(BankCatalog.banks) { bank in
                            Text(bank.name).tag(bank.id)
                        }
                    }
                    .onChange(of: selectedBankId) { _, newBankId in
                        if let bank = BankCatalog.banks.first(where: { $0.id == newBankId }) {
                            if !bank.cardTypes.contains(selectedCardType) {
                                selectedCardType = bank.cardTypes.first ?? ""
                            }
                        }
                    }

                    Picker("Tipo", selection: $selectedCardType) {
                        ForEach(cardTypesForSelectedBank, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }

                    TextField("Últimos 4 dígitos", text: $lastDigits)
                        .keyboardType(.numberPad)
                        .onChange(of: lastDigits) { _, newValue in
                            let digitsOnly = newValue.filter { $0.isNumber }
                            lastDigits = String(digitsOnly.prefix(4))
                        }
                }

                Section("Fechas") {
                    DatePicker("Fecha de corte", selection: $cutDate, displayedComponents: .date)
                    DatePicker("Fecha límite", selection: $dueDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Editar Tarjeta")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        guard let bank = BankCatalog.banks.first(where: { $0.id == selectedBankId }) else { return }

                        let updated = CreditCardItem(
                            id: original.id, // 👈 CLAVE: conservar ID
                            bankCode: bank.id,
                            bankName: bank.name,
                            cardType: selectedCardType,
                            lastDigits: lastDigits,
                            cutDate: cutDate,
                            dueDate: dueDate,
                            isPaid: original.isPaid
                        )

                        onSave(updated)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private var cardTypesForSelectedBank: [String] {
        BankCatalog.banks.first(where: { $0.id == selectedBankId })?.cardTypes ?? []
    }

    private var canSave: Bool {
        let digitsOk = lastDigits.count == 4
        let datesOk = dueDate >= cutDate
        let typeOk = !selectedCardType.isEmpty
        return digitsOk && datesOk && typeOk
    }
}
