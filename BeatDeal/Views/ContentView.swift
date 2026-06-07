import SwiftUI

struct ContentView: View {
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
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
