import SwiftUI
import UIKit

struct HomeView: View {
    @ObservedObject private var storage = ContractStorage.shared
    @ObservedObject private var splitStorage = SplitSheetStorage.shared
    @State private var shareContract: Contract?
    @State private var shareURL: URL?
    @State private var showShare = false
    @State private var showNewSplit = false
    @State private var alertMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BeatDealSpacing.lg) {
                    header

                    NavigationLink {
                        NewContractView()
                    } label: {
                        Label("+ Nouveau contrat", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button {
                        showNewSplit = true
                    } label: {
                        Label("+ Split en 90s", systemImage: "person.2.fill")
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    splitRecentSection

                    revenueSummary

                    recentSection
                }
                .padding(BeatDealSpacing.md)
            }
            .background(BeatDealColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showShare) {
                if let shareURL {
                    ShareSheet(items: [shareURL])
                }
            }
            .sheet(isPresented: $showNewSplit) {
                NewSplitSheetView()
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

    @ViewBuilder
    private var splitRecentSection: some View {
        let recent = splitStorage.recent(limit: 3)
        if !recent.isEmpty {
            Text("Splits récents")
                .font(BeatDealTypography.headline)
                .foregroundStyle(BeatDealColors.text)
            VStack(spacing: BeatDealSpacing.sm) {
                ForEach(recent) { split in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(split.title)
                                .font(BeatDealTypography.body)
                                .foregroundStyle(BeatDealColors.text)
                            Text("\(split.ref) · \(split.collaborators.count) collab.")
                                .font(BeatDealTypography.caption)
                                .foregroundStyle(BeatDealColors.textSecondary)
                        }
                        Spacer()
                    }
                    .beatDealCard()
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: BeatDealSpacing.xs) {
            Text(AppConstants.appName)
                .font(BeatDealTypography.title)
                .foregroundStyle(BeatDealColors.text)
            Text(AppConstants.appTagline)
                .font(BeatDealTypography.body)
                .foregroundStyle(BeatDealColors.textSecondary)
        }
        .padding(.top, BeatDealSpacing.sm)
    }

    private var revenueSummary: some View {
        let month = RevenueStatsEngine.stats(for: storage.contracts, in: .month)
        return NavigationLink {
            RevenueDashboardView()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ce mois")
                        .font(BeatDealTypography.caption)
                        .foregroundStyle(BeatDealColors.textSecondary)
                    Text("\(month.totalEUR) €")
                        .font(BeatDealTypography.headline)
                        .foregroundStyle(BeatDealColors.text)
                    Text("\(month.contractCount) contrat\(month.contractCount > 1 ? "s" : "")")
                        .font(BeatDealTypography.caption)
                        .foregroundStyle(BeatDealColors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(BeatDealColors.textSecondary)
            }
            .beatDealCard()
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var recentSection: some View {
        Text("Contrats récents")
            .font(BeatDealTypography.headline)
            .foregroundStyle(BeatDealColors.text)

        let recent = storage.recent(limit: 5)
        if recent.isEmpty {
            emptyState
        } else {
            VStack(spacing: BeatDealSpacing.sm) {
                ForEach(recent) { contract in
                    ContractRowView(contract: contract) {
                        shareAgain(contract)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: BeatDealSpacing.md) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(BeatDealColors.accent.opacity(0.6))
            Text("Ton premier contrat en 60s")
                .font(BeatDealTypography.body)
                .foregroundStyle(BeatDealColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BeatDealSpacing.xl)
        .beatDealCard()
    }

    private func shareAgain(_ contract: Contract) {
        do {
            let url = try PDFGenerator.generatePDF(for: contract)
            shareURL = url
            showShare = true
        } catch {
            alertMessage = "Impossible de générer le PDF : \(error.localizedDescription)"
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
