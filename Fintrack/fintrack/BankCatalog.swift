//
//  BankCatalog.swift
//  fintrack
//
//  Created by Adrian Rodriguez Llorens on 07/01/26.
//

// BankCatalog.swift
import Foundation

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
