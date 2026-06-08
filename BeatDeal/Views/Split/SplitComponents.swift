import SwiftUI

struct SplitTotalIndicator: View {
    let label: String
    let total: Int
    let target: Int

    private var isValid: Bool { total == target }
    private var remaining: Int { target - total }

    var body: some View {
        VStack(alignment: .leading, spacing: BeatDealSpacing.xs) {
            HStack {
                Text(label)
                    .font(BeatDealTypography.body)
                    .foregroundStyle(BeatDealColors.text)
                Spacer()
                Text("\(total)% / \(target)%")
                    .font(BeatDealTypography.caption)
                    .foregroundStyle(isValid ? BeatDealColors.success : BeatDealColors.textSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(BeatDealColors.separator)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isValid ? BeatDealColors.success : BeatDealColors.accent)
                        .frame(width: geo.size.width * CGFloat(min(total, target)) / CGFloat(target))
                }
            }
            .frame(height: 8)
            if !isValid {
                Text(remaining > 0 ? "Il manque \(remaining)%" : "Dépassement de \(-remaining)%")
                    .font(BeatDealTypography.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(BeatDealSpacing.md)
        .beatDealCard()
    }
}

struct SplitCollaboratorEditor: View {
    @Binding var collaborator: SplitCollaborator
    let splitType: SplitSheetType
    let canRemove: Bool
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BeatDealSpacing.sm) {
            HStack {
                Text("Collaborateur")
                    .font(BeatDealTypography.headline)
                    .foregroundStyle(BeatDealColors.accentLight)
                Spacer()
                if canRemove {
                    Button(role: .destructive, action: onRemove) {
                        Image(systemName: "trash")
                    }
                }
            }

            BeatDealTextField(title: "Nom / alias", text: $collaborator.name, required: true)

            Text("Rôle")
                .font(BeatDealTypography.caption)
                .foregroundStyle(BeatDealColors.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BeatDealSpacing.sm) {
                    ForEach(SplitCollaboratorRole.allCases) { role in
                        Button(role.rawValue) {
                            collaborator.role = role.rawValue
                        }
                        .font(BeatDealTypography.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(collaborator.role == role.rawValue ? BeatDealColors.accent : BeatDealColors.card)
                        .foregroundStyle(BeatDealColors.text)
                        .clipShape(Capsule())
                    }
                }
            }

            VStack(alignment: .leading) {
                HStack {
                    Text("Part Master")
                        .foregroundStyle(BeatDealColors.textSecondary)
                    Spacer()
                    Text("\(collaborator.masterShare)%")
                        .foregroundStyle(BeatDealColors.accentLight)
                        .fontWeight(.bold)
                }
                Slider(
                    value: Binding(
                        get: { Double(collaborator.masterShare) },
                        set: { collaborator.masterShare = Int($0.rounded()) }
                    ),
                    in: 0...100,
                    step: 1
                )
                .tint(BeatDealColors.accent)
            }

            if splitType == .masterAndPublishing {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Part Publishing")
                            .foregroundStyle(BeatDealColors.textSecondary)
                        Spacer()
                        Text("\(collaborator.publishingShare)%")
                            .foregroundStyle(BeatDealColors.accentLight)
                            .fontWeight(.bold)
                    }
                    Slider(
                        value: Binding(
                            get: { Double(collaborator.publishingShare) },
                            set: { collaborator.publishingShare = Int($0.rounded()) }
                        ),
                        in: 0...100,
                        step: 1
                    )
                    .tint(BeatDealColors.accent)
                }
            }

            BeatDealTextField(title: "SACEM / PRO", text: Binding(
                get: { collaborator.sacem ?? "" },
                set: { collaborator.sacem = $0.isEmpty ? nil : $0 }
            ))
            BeatDealTextField(title: "Email", text: Binding(
                get: { collaborator.email ?? "" },
                set: { collaborator.email = $0.isEmpty ? nil : $0 }
            ), keyboard: .emailAddress)
        }
        .beatDealCard()
    }
}
