import SwiftUI

@main
struct BeatDealApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var deepLinkRouter = DeepLinkRouter.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deepLinkRouter)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    deepLinkRouter.handle(url: url)
                }
                .task {
                    await LicenseAlertService.shared.requestAuthorizationIfNeeded()
                    await LicenseAlertService.shared.refreshAlerts(for: ContractStorage.shared.contracts)
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        Task {
                            await LicenseAlertService.shared.refreshAlerts(for: ContractStorage.shared.contracts)
                        }
                    }
                }
        }
    }
}
