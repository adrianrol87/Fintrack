//
//  ProView.swift
//  fintrack
//
//  Created by Adrian Rodriguez Llorens on 07/01/26.
//

// ProView.swift
import SwiftUI

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
                    ProManager.isPro = true // simula restaurar compra (demo)
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

