import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }

            TemplatesView()
                .tabItem {
                    Label("Modèles", systemImage: "doc.on.doc.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Paramètres", systemImage: "gearshape.fill")
                }
        }
        .tint(BeatDealColors.accent)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
