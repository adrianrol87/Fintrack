//
//  AddCardView.swift
//  fintrack
//
//  Created by Adrian Rodriguez Llorens on 07/01/26.
//

// AddCardView.swift
import SwiftUI

// MARK: - Add View
struct AddCardView: View {
    let currentCount: Int
    let onSave: (CreditCardItem) -> Void

    @Environment(\.dismiss) private var dismiss

    private let customBankId = "custom"

    @State private var selectedBankId: String = BankCatalog.banks.first?.id ?? "bbva"
    @State private var selectedCardType: String = BankCatalog.banks.first?.cardTypes.first ?? "Azul"

    @State private var customBankName = ""
    @State private var customCardType = "Clásica"

    @State private var lastDigits = ""
    @State private var cutDate = Date()
    @State private var dueDate = Date()

    @State private var showPro = false

    private var limitReached: Bool {
        !ProManager.isPro && currentCount >= Monetization.freeCardsLimit
    }

    var body: some View {
        NavigationStack {
            Form {

                if limitReached {
                    Section {
                        HStack(spacing: 12) {
                            Image(systemName: "crown.fill")
                                .font(.title3.weight(.semibold))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Límite Free alcanzado")
                                    .font(.subheadline.weight(.semibold))
                                Text("Activa Pro para agregar tarjetas ilimitadas.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Tarjeta") {
                    Picker("Banco", selection: $selectedBankId) {
                        ForEach(BankCatalog.banks) { bank in
                            Text(bank.name).tag(bank.id)
                        }
                        Text("Otro (manual)").tag(customBankId)
                    }
                    .onChange(of: selectedBankId) { _, newBankId in
                        if newBankId == customBankId {
                            if customCardType.isEmpty { customCardType = "Clásica" }
                        } else if let bank = BankCatalog.banks.first(where: { $0.id == newBankId }) {
                            selectedCardType = bank.cardTypes.first ?? ""
                        }
                    }

                    if selectedBankId == customBankId {
                        TextField("Nombre del banco", text: $customBankName)
                        TextField("Tipo (ej. Clásica, Oro, Platinum)", text: $customCardType)
                    } else {
                        Picker("Tipo", selection: $selectedCardType) {
                            ForEach(cardTypesForSelectedBank, id: \.self) { type in
                                Text(type).tag(type)
                            }
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
            .navigationTitle("Agregar Tarjeta")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {

                    if limitReached {
                        Button("Desbloquear") { showPro = true }
                    } else {
                        Button("Guardar") {
                            saveCard()
                        }
                        .disabled(!canSave)
                    }
                }
            }
            .sheet(isPresented: $showPro) {
                ProView {
                    // 👇 Importante: aquí NO usamos proTick (no está en scope).
                    // ContentView ya se actualiza al volver porque ProManager.isPro cambia.
                    showPro = false
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

        if selectedBankId == customBankId {
            let nameOk = !customBankName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let typeOk = !customCardType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return digitsOk && datesOk && nameOk && typeOk
        } else {
            let typeOk = !selectedCardType.isEmpty
            return digitsOk && datesOk && typeOk
        }
    }

    private func saveCard() {
        if selectedBankId == customBankId {
            let name = customBankName.trimmingCharacters(in: .whitespacesAndNewlines)
            let type = customCardType.trimmingCharacters(in: .whitespacesAndNewlines)

            let item = CreditCardItem(
                bankCode: "generic",
                bankName: name.isEmpty ? "Otro" : name,
                cardType: type.isEmpty ? "Clásica" : type,
                lastDigits: lastDigits,
                cutDate: cutDate,
                dueDate: dueDate,
                isPaid: false
            )
            onSave(item)
            dismiss()
        } else {
            guard let bank = BankCatalog.banks.first(where: { $0.id == selectedBankId }) else { return }

            let item = CreditCardItem(
                bankCode: bank.id,
                bankName: bank.name,
                cardType: selectedCardType,
                lastDigits: lastDigits,
                cutDate: cutDate,
                dueDate: dueDate,
                isPaid: false
            )
            onSave(item)
            dismiss()
        }
    }
}

