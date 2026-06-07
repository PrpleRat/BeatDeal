import SwiftUI

struct PaywallView: View {
    @ObservedObject var purchaseService: PurchaseService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: BeatDealSpacing.lg) {
                Spacer()

                Image(systemName: "doc.text.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(BeatDealColors.accent)

                VStack(spacing: BeatDealSpacing.sm) {
                    Text("BeatDeal Pro")
                        .font(BeatDealTypography.title)
                        .foregroundStyle(BeatDealColors.text)

                    Text("Contrats illimités · PDF pro · Partage direct")
                        .font(BeatDealTypography.body)
                        .foregroundStyle(BeatDealColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: BeatDealSpacing.md) {
                    bullet("Contrats PDF illimités")
                    bullet("Templates personnalisables")
                    bullet("Partage iMessage, email, AirDrop")
                }
                .padding(.horizontal, BeatDealSpacing.lg)

                if let error = purchaseService.lastError {
                    Text(error)
                        .font(BeatDealTypography.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button {
                    Task { await purchaseService.purchase() }
                } label: {
                    if purchaseService.isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Débloquer pour 4,99 €")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(purchaseService.isPurchasing)
                .padding(.horizontal, BeatDealSpacing.lg)

                Button("Restaurer l'achat") {
                    Task { await purchaseService.restorePurchases() }
                }
                .font(BeatDealTypography.caption)
                .foregroundStyle(BeatDealColors.textSecondary)

                Spacer()
            }
            .background(BeatDealColors.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .onChange(of: purchaseService.isPro) { _, isPro in
                if isPro { dismiss() }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: BeatDealSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(BeatDealColors.success)
            Text(text)
                .font(BeatDealTypography.body)
                .foregroundStyle(BeatDealColors.text)
        }
    }
}
