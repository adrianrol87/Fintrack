//
//  ContentView.swift
//  fintrack
//
//  Created by Adrian Rodriguez Llorens on 05/01/26.
//

import SwiftUI
import UIKit


// MARK: - Bank Catalog

struct BankCatalog {
    struct Bank: Identifiable, Hashable {
        let id: String
        let name: String
        let cardTypes: [String]
    }

    static let banks: [Bank] = [
        .init(id: "bbva", name: "BBVA", cardTypes: [
            "Azul", "Oro", "Platinum", "Vive", "Start", "Crea", "Primera",
            "Educación", "IPN", "UNAM", "Rayados"
        ]),
        .init(id: "banamex", name: "Banamex", cardTypes: [
            "Clásica", "Oro", "Platinum", "Lineup", "Costco", "Home Depot", "Teletón",
            "Joy", "Affinity", "Beyond", "Comer", "Conquista", "Descubre", "Explora"
        ]),
        .init(id: "santander", name: "Santander", cardTypes: [
            "LikeU", "Gold", "Platinum", "World Elite", "Amex",
            "Fiesta Oro", "Fiesta Platino",
            "Aeroméxico BCA", "Aeroméxico Platino", "Aeroméxico Infinite"
        ]),
        .init(id: "banorte", name: "Banorte", cardTypes: ["Clásica", "Oro"]),
        .init(id: "banregio", name: "Banregio", cardTypes: ["Oro", "Platino"]),
        .init(id: "azteca", name: "Banco Azteca", cardTypes: ["Clásica", "Oro"]),
        .init(id: "vexi", name: "Vexi", cardTypes: ["Carnet", "American Express"]),
        .init(id: "nu", name: "Nu", cardTypes: ["Clásica"]),
        .init(id: "hey", name: "Hey Banco", cardTypes: ["Clásica"]),
        .init(id: "rappi", name: "Rappi", cardTypes: ["Clásica"]),
        .init(id: "didi", name: "DiDi", cardTypes: ["Clásica"]),
        .init(id: "plata", name: "Plata", cardTypes: ["Clásica"]),
        .init(id: "mercadolibre", name: "Mercado Libre", cardTypes: ["Clásica"]),
        .init(id: "invex", name: "invex", cardTypes: ["despegargold", "despegarplat",
            "ikea", "sams", "volaris", "volaris0", "volaris2", "voyage", "voyageplat",
            "walmart"])
    ]
}

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

// MARK: - Main Screen

struct ContentView: View {
    
    @State private var pressedId: UUID?

    enum CardsFilter: String, CaseIterable, Identifiable {
        case all = "Todas"
        case pending = "Pendientes"
        case overdue = "Vencidas"
        case paid = "Pagadas"

        var id: String { rawValue }
    }

    @State private var filter: CardsFilter = .all
    @State private var isDark = false
    @State private var showAddCard = false
    @State private var editingItem: CreditCardItem?
    @State private var showPro = false
    @State private var proTick = 0


    @State private var items: [CreditCardItem] = []
    
    @ViewBuilder
    private var upgradeBanner: some View {
        if limitReached {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.title3.weight(.semibold))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Límite Free alcanzado")
                        .font(.subheadline.weight(.semibold))
                    Text("Desbloquea tarjetas ilimitadas, widget y más.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onTapGesture {
                showPro = true
            }
        } else if !ProManager.isPro {
            // opcional: cuando aún tienes espacio, muestra "te quedan X"
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.title3.weight(.semibold))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Plan Free")
                        .font(.subheadline.weight(.semibold))
                    Text("Te quedan \(remainingSlots) espacio(s) para tarjetas.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }


    var body: some View {
        let _ = proTick
        
        ZStack {
            LinearGradient(
                colors: [Color(.bgTop), Color(.bgBottom)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            NavigationStack {
                
                List {
                    Section {
                        
                        upgradeBanner
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 6, trailing: 16))
                        
                        // --- Mini Dashboard ---

                            HStack(spacing: 12) {

                                // Por vencer (<= 5 días)
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "bell.fill")
                                        Text("\(countDueSoon)")
                                            .font(.title3.bold())
                                    }
                                    Text("Por vencer")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .onTapGesture {
                                    filter = .pending
                                }

                                // Vencidas (< 0 días)
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                        Text("\(countOverdue)")
                                            .font(.title3.bold())
                                    }
                                    Text("Vencidas")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .onTapGesture {
                                    filter = .overdue
                                }

                                // Activas (no pagadas)
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "creditcard.fill")
                                        Text("\(countActive)")
                                            .font(.title3.bold())
                                    }
                                    Text("Activas")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .onTapGesture {
                                    filter = .pending
                                }
                            }
                            .padding(.vertical, 6)
                        
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 2, trailing: 16))

                        Text("Próximos pagos de tus tarjetas")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 6, trailing: 16))

                        Picker("Filtro", selection: $filter) {
                            ForEach(CardsFilter.allCases) { f in
                                Text(f.rawValue).tag(f)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(Color("Accent"))
                        .padding(.top, 6)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 10, trailing: 16))
                    }

                    Section {
                        ForEach(sortedIndexes, id: \.self) { i in
                            CardRowView(item: $items[i]) { changedItem in
                                if changedItem.isPaid {
                                    removeDueNotifications(for: changedItem)
                                    removeCutNotifications(for: changedItem)
                                } else {
                                    scheduleDueNotifications(for: changedItem)
                                    scheduleCutNotifications(for: changedItem)
                                }
                            }
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .scaleEffect(pressedId == items[i].id ? 0.98 : 1.0)
                                .animation(.easeOut(duration: 0.12), value: pressedId)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()

                                    pressedId = items[i].id
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                                        pressedId = nil
                                        editingItem = items[i]
                                    }
                                }

                        }
                        .onDelete(perform: deleteItemsSorted)
                    }
                }
                
                .overlay {
                    if sortedIndexes.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "tray")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.secondary)

                            Text("No hay tarjetas en este filtro")
                                .font(.headline)

                            Text("Cambia el filtro o agrega una tarjeta nueva.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .padding(22)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.horizontal, 24)
                    }
                }

                
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .navigationTitle(ProManager.isPro ? "Mis Tarjetas • Pro" : "Mis Tarjetas")
                .tint(Color("Accent"))
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {

                        // 👑 Pro / Upgrade (solo si NO es Pro)   ✅ (CAMBIO 3)
                        if !ProManager.isPro {
                            Button {
                                showPro = true
                            } label: {
                                Image(systemName: "crown")
                            }
                        }

                        // ➕ Agregar
                        Button("Agregar") {
                            let limitReached = !ProManager.isPro && items.count >= Monetization.freeCardsLimit
                            if limitReached {
                                showPro = true
                            } else {
                                showAddCard = true
                            }
                        }

                        // 🌙 Dark/Light
                        Button { isDark.toggle() } label: {
                            Image(systemName: isDark ? "moon.fill" : "moon")
                        }
                    }
                }
                .sheet(isPresented: $showAddCard) {
                    AddCardView(currentCount: items.count) { newItem in
                        items.append(newItem)
                        scheduleDueNotifications(for: newItem)
                        scheduleCutNotifications(for: newItem)
                    }
                }

                .sheet(isPresented: $showPro) {
                    ProView {
                        proTick += 1          // 👈 fuerza refresh
                        showPro = false  // cierra la hoja de Pro
                    }
                }
                .sheet(item: $editingItem) { item in
                    EditCardView(item: item) { updated in
                        if let index = items.firstIndex(where: { $0.id == item.id }) {
                            items[index] = updated
                            removeDueNotifications(for: updated)
                            removeCutNotifications(for: updated)
                            scheduleDueNotifications(for: updated)
                            scheduleCutNotifications(for: updated)
                        }
                    }
                }
                .onAppear {
                    let saved = CardsStorage.load()
                    if !saved.isEmpty { items = saved }
                    rescheduleAllNotifications()
                }
                .onChange(of: items) { _, newValue in
                    CardsStorage.save(newValue)
                }
            }
        }
        .preferredColorScheme(isDark ? .dark : .light)
    }
    
    private var countDueSoon: Int {
        items.filter { !$0.isPaid && $0.daysRemaining >= 0 && $0.daysRemaining <= 5 }.count
    }

    private var countOverdue: Int {
        items.filter { !$0.isPaid && $0.daysRemaining < 0 }.count
    }

    private var countActive: Int {
        items.filter { !$0.isPaid }.count
    }
    
    private var limitReached: Bool {
        !ProManager.isPro && items.count >= Monetization.freeCardsLimit
    }

    private var remainingSlots: Int {
        max(0, Monetization.freeCardsLimit - items.count)
    }

    
    private func scheduleDueNotifications(for item: CreditCardItem) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }

            // 1) Primero elimina las notificaciones anteriores de esta tarjeta (por si se editó)
            let baseId = item.id.uuidString
            let idsToRemove = [
                "\(baseId)_due_3",
                "\(baseId)_due_1",
                "\(baseId)_due_0"
            ]
            center.removePendingNotificationRequests(withIdentifiers: idsToRemove)

            // 2) Arma las 3 fechas objetivo
            let cal = Calendar.current
            let due0 = notificationFireDate(baseDate: item.dueDate) // día que vence 9:00
            let due1 = cal.date(byAdding: .day, value: -1, to: due0)!
            let due3 = cal.date(byAdding: .day, value: -3, to: due0)!

            let targets: [(daysBefore: Int, fireDate: Date, id: String)] = [
                (3, due3, "\(baseId)_due_3"),
                (1, due1, "\(baseId)_due_1"),
                (0, due0, "\(baseId)_due_0")
            ]

            for t in targets {
                // No programes notificaciones en el pasado
                if t.fireDate <= Date() { continue }

                let content = UNMutableNotificationContent()
                content.title = "Fintrack"
                if t.daysBefore == 0 {
                    content.body = "Hoy vence tu tarjeta \(item.bankName) \(item.cardType) • \(item.lastDigits)"
                } else {
                    content.body = "En \(t.daysBefore) día(s) vence tu tarjeta \(item.bankName) \(item.cardType) • \(item.lastDigits)"
                }
                content.sound = .default

                let components = cal.dateComponents([.year, .month, .day, .hour, .minute], from: t.fireDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

                let request = UNNotificationRequest(identifier: t.id, content: content, trigger: trigger)
                center.add(request)
            }
        }
    }

    
    private func notificationFireDate(baseDate: Date, hour: Int = 9, minute: Int = 0) -> Date {
        var cal = Calendar.current
        cal.timeZone = .current

        let start = cal.startOfDay(for: baseDate)
        return cal.date(bySettingHour: hour, minute: minute, second: 0, of: start) ?? baseDate
    }



    // MARK: Filter + Sort (Paso 15 + 16)

    private var sortedIndexes: [Int] {
        let today = Calendar.current.startOfDay(for: Date())

        func group(for item: CreditCardItem) -> Int {
            if item.isPaid { return 3 } // pagadas al final
            if Calendar.current.startOfDay(for: item.dueDate) < today { return 0 } // vencidas arriba
            if item.daysRemaining <= 5 { return 1 } // por vencer
            return 2 // normales
        }
        
        

        // FILTRO
        let base = items.indices.filter { i in
            let item = items[i]
            switch filter {
            case .all:
                return true
            case .pending:
                return !item.isPaid && item.daysRemaining >= 0
            case .overdue:
                return !item.isPaid && item.daysRemaining < 0
            case .paid:
                return item.isPaid
            }
        }

        // ORDEN
        return base.sorted { a, b in
            let ia = items[a]
            let ib = items[b]

            let ga = group(for: ia)
            let gb = group(for: ib)
            if ga != gb { return ga < gb }

            if ia.dueDate != ib.dueDate { return ia.dueDate < ib.dueDate }
            if ia.bankName != ib.bankName { return ia.bankName < ib.bankName }
            return ia.lastDigits < ib.lastDigits
        }
    }

    private func deleteItemsSorted(at offsets: IndexSet) {
        let realIndexes = offsets.map { sortedIndexes[$0] }.sorted(by: >)
        for i in realIndexes {
            removeDueNotifications(for: items[i])
            removeCutNotifications(for: items[i])
            items.remove(at: i)
        }
    }
    
    private func removeDueNotifications(for item: CreditCardItem) {
        let center = UNUserNotificationCenter.current()
        let baseId = item.id.uuidString
        let ids = [
            "\(baseId)_due_3",
            "\(baseId)_due_1",
            "\(baseId)_due_0"
        ]
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }
    
    private func scheduleCutNotifications(for item: CreditCardItem) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            if item.isPaid { return } // si está pagada, no avisamos

            let baseId = item.id.uuidString
            let idsToRemove = [
                "\(baseId)_cut_3",
                "\(baseId)_cut_1",
                "\(baseId)_cut_0"
            ]
            center.removePendingNotificationRequests(withIdentifiers: idsToRemove)

            let cal = Calendar.current
            let cut0 = notificationFireDate(baseDate: item.cutDate) // día de corte 9:00
            let cut1 = cal.date(byAdding: .day, value: -1, to: cut0)!
            let cut3 = cal.date(byAdding: .day, value: -3, to: cut0)!

            let targets: [(daysBefore: Int, fireDate: Date, id: String)] = [
                (3, cut3, "\(baseId)_cut_3"),
                (1, cut1, "\(baseId)_cut_1"),
                (0, cut0, "\(baseId)_cut_0")
            ]

            for t in targets {
                if t.fireDate <= Date() { continue }

                let content = UNMutableNotificationContent()
                content.title = "Fintrack"
                if t.daysBefore == 0 {
                    content.body = "Hoy es el corte de \(item.bankName) \(item.cardType) • \(item.lastDigits)"
                } else {
                    content.body = "En \(t.daysBefore) día(s) es el corte de \(item.bankName) \(item.cardType) • \(item.lastDigits)"
                }
                content.sound = .default

                let components = cal.dateComponents([.year, .month, .day, .hour, .minute], from: t.fireDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

                let request = UNNotificationRequest(identifier: t.id, content: content, trigger: trigger)
                center.add(request)
            }
        }
    }
    
    private func removeCutNotifications(for item: CreditCardItem) {
        let center = UNUserNotificationCenter.current()
        let baseId = item.id.uuidString
        let ids = [
            "\(baseId)_cut_3",
            "\(baseId)_cut_1",
            "\(baseId)_cut_0"
        ]
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }
    
    private func rescheduleAllNotifications() {
        for item in items {
            removeDueNotifications(for: item)
            removeCutNotifications(for: item)
            scheduleDueNotifications(for: item)
            scheduleCutNotifications(for: item)
        }
    }


}

// MARK: - Pro Screen (placeholder)

struct ProView: View {
    @Environment(\.dismiss) private var dismiss
    let onActivated: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.top, 14)

                Text("Fintrack Pro")
                    .font(.title.bold())

                Text("Desbloquea tarjetas ilimitadas, widget y más.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Button {
                    ProManager.isPro = true
                    onActivated()
                    dismiss()
                } label: {
                    Text("Activar Pro (demo)")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("AccentSoft"))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                
                Button {
                    ProManager.isPro = true   // ✅ (CAMBIO 4) simula restaurar compra (demo)
                    onActivated()
                    dismiss()
                } label: {
                    Text("Restaurar (demo)")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)

                #if DEBUG
                Button {
                    ProManager.isPro = false
                    onActivated()
                    dismiss()
                } label: {
                    Text("Quitar Pro (debug)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.red)
                }
                .padding(.top, 4)
                #endif


                Button("Cerrar") { dismiss() }
                    .padding(.top, 6)

                Spacer()
            }
            .padding()
            .navigationTitle("Mejorar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}



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

                    // 👇 Si llegaste al límite: en vez de guardar, abre Pro
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
                ProView{
                    showPro = false
                    dismiss()
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

#Preview {
    ContentView()
}
