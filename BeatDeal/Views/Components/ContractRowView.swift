import SwiftUI

struct ContractRowView: View {
    let contract: Contract
    var onShare: () -> Void

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .medium
        return formatter.string(from: contract.createdAt)
    }

    var body: some View {
        HStack(spacing: BeatDealSpacing.md) {
            VStack(alignment: .leading, spacing: BeatDealSpacing.xs) {
                Text(contract.artistName)
                    .font(BeatDealTypography.headline)
                    .foregroundStyle(BeatDealColors.text)

                HStack(spacing: BeatDealSpacing.sm) {
                    Text(contract.licenseType.title)
                        .font(BeatDealTypography.badge)
                        .foregroundStyle(contract.licenseType.badgeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(BeatDealColors.separator)
                        .clipShape(Capsule())

                    Text(dateLabel)
                        .font(BeatDealTypography.caption)
                        .foregroundStyle(BeatDealColors.textSecondary)
                }
            }

            Spacer()

            Button(action: onShare) {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(BeatDealColors.accentLight)
                    .padding(10)
                    .background(BeatDealColors.separator)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .beatDealCard()
    }
}
