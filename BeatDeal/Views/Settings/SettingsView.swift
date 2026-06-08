import SwiftUI

struct SettingsView: View {
    @ObservedObject private var profileStorage = ProfileStorage.shared

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

                Section("DM Kit — vente") {
                    TextField("Lien de paiement (PayPal.me, Lydia…)", text: $profileStorage.profile.paymentLinkURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                    TextField("Call to action", text: $profileStorage.profile.dmCallToAction, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Devise") {
                    Picker("Devise", selection: $profileStorage.profile.currency) {
                        ForEach(Currency.allCases) { currency in
                            Text(currency.label).tag(currency)
                        }
                    }
                }

                Section("Outils") {
                    NavigationLink {
                        TemplatesView()
                    } label: {
                        Label("Mes modèles", systemImage: "doc.on.doc.fill")
                    }

                    Button("Activer les alertes de licence") {
                        Task { await LicenseAlertService.shared.requestAuthorizationIfNeeded() }
                    }
                }

                Section("À propos") {
                    LabeledContent("Version", value: Bundle.main.appVersion)

                    Link("Politique de confidentialité", destination: URL(string: AppConstants.privacyPolicyURL)!)
                }
            }
            .scrollContentBackground(.hidden)
            .background(BeatDealColors.background.ignoresSafeArea())
            .navigationTitle("Paramètres")
            .onDisappear {
                profileStorage.save()
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
