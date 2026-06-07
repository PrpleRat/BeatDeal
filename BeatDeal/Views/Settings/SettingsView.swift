import SwiftUI

struct SettingsView: View {
    @ObservedObject private var profileStorage = ProfileStorage.shared
    @ObservedObject private var purchaseService = PurchaseService.shared
    @State private var alertMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Profil producteur") {
                    TextField("Nom de producteur", text: $profileStorage.profile.producerName)
                    TextField("Alias", text: $profileStorage.profile.producerAlias)
                    TextField("Email", text: $profileStorage.profile.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("SIRET / SIREN (optionnel)", text: $profileStorage.profile.siret)
                    TextField("Pays", text: $profileStorage.profile.country)
                }

                Section("Devise") {
                    Picker("Devise", selection: $profileStorage.profile.currency) {
                        ForEach(Currency.allCases) { currency in
                            Text(currency.label).tag(currency)
                        }
                    }
                }

                Section("À propos") {
                    LabeledContent("Version", value: Bundle.main.appVersion)

                    Link("Politique de confidentialité", destination: URL(string: AppConstants.privacyPolicyURL)!)

                    Button("Restaurer l'achat") {
                        Task {
                            await purchaseService.restorePurchases()
                            if let error = purchaseService.lastError {
                                alertMessage = error
                            } else if purchaseService.isPro {
                                alertMessage = "Achat restauré avec succès."
                            }
                        }
                    }

                    if purchaseService.isPro {
                        Label("BeatDeal Pro activé", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(BeatDealColors.success)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(BeatDealColors.background.ignoresSafeArea())
            .navigationTitle("Paramètres")
            .onDisappear {
                profileStorage.save()
            }
            .alert("BeatDeal", isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }
}

private extension Bundle {
    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
