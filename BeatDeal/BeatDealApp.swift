import SwiftUI

@main
struct BeatDealApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
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
