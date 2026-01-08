//
//  ContentView.swift
//  fintrack
//
//  Created by Adrian Rodriguez Llorens on 05/01/26.
//

// ContentView.swift
import SwiftUI
import UIKit

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

                        HStack(spacing: 12) {

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

                        // 👑 Pro / Upgrade (solo si NO es Pro)
                        if !ProManager.isPro {
                            Button {
                                showPro = true
                            } label: {
                                Image(systemName: "crown")
                            }
                        }

                        Button("Agregar") {
                            let limitReached = !ProManager.isPro && items.count >= Monetization.freeCardsLimit
                            if limitReached {
                                showPro = true
                            } else {
                                showAddCard = true
                            }
                        }

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
                        proTick += 1
                        showPro = false
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

            let baseId = item.id.uuidString
            let idsToRemove = [
                "\(baseId)_due_3",
                "\(baseId)_due_1",
                "\(baseId)_due_0"
            ]
            center.removePendingNotificationRequests(withIdentifiers: idsToRemove)

            let cal = Calendar.current
            let due0 = notificationFireDate(baseDate: item.dueDate)
            let due1 = cal.date(byAdding: .day, value: -1, to: due0)!
            let due3 = cal.date(byAdding: .day, value: -3, to: due0)!

            let targets: [(daysBefore: Int, fireDate: Date, id: String)] = [
                (3, due3, "\(baseId)_due_3"),
                (1, due1, "\(baseId)_due_1"),
                (0, due0, "\(baseId)_due_0")
            ]

            for t in targets {
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

    private var sortedIndexes: [Int] {
        let today = Calendar.current.startOfDay(for: Date())

        func group(for item: CreditCardItem) -> Int {
            if item.isPaid { return 3 }
            if Calendar.current.startOfDay(for: item.dueDate) < today { return 0 }
            if item.daysRemaining <= 5 { return 1 }
            return 2
        }

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
            if item.isPaid { return }

            let baseId = item.id.uuidString
            let idsToRemove = [
                "\(baseId)_cut_3",
                "\(baseId)_cut_1",
                "\(baseId)_cut_0"
            ]
            center.removePendingNotificationRequests(withIdentifiers: idsToRemove)

            let cal = Calendar.current
            let cut0 = notificationFireDate(baseDate: item.cutDate)
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

#Preview {
    ContentView()
}
