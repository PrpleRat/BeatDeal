import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var deepLinkRouter: DeepLinkRouter
    @State private var showContractFromSplit = false
    @State private var splitImport: SplitPadImport?

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }

            RevenueDashboardView()
                .tabItem {
                    Label("Revenus", systemImage: "eurosign.circle.fill")
                }

            CatalogView()
                .tabItem {
                    Label("Catalogue", systemImage: "music.note.list")
                }

            LicenseTrackerView()
                .tabItem {
                    Label("Licences", systemImage: "bell.badge.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Réglages", systemImage: "gearshape.fill")
                }
        }
        .tint(BeatDealColors.accent)
        .onChange(of: deepLinkRouter.pendingSplitImport?.id) { _, _ in
            guard let pending = deepLinkRouter.pendingSplitImport else { return }
            splitImport = pending
            showContractFromSplit = true
        }
        .sheet(isPresented: $showContractFromSplit, onDismiss: {
            _ = deepLinkRouter.consumePendingImport()
            splitImport = nil
        }) {
            if let splitImport {
                NewContractView(splitImport: splitImport)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DeepLinkRouter.shared)
        .preferredColorScheme(.dark)
}
