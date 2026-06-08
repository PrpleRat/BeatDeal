import SwiftUI

struct NewSplitSheetView: View {
    var splitImport: SplitPadImport? = nil

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var profileStorage = ProfileStorage.shared
    @ObservedObject private var splitStorage = SplitSheetStorage.shared

    @State private var draft = SplitSheetDraft()
    @State private var previewSheet: SplitSheet?
    @State private var previewURL: URL?
    @State private var alertMessage: String?

    private var totalMaster: Int {
        draft.collaborators.reduce(0) { $0 + $1.masterShare }
    }

    private var totalPublishing: Int {
        draft.collaborators.reduce(0) { $0 + $1.publishingShare }
    }

    private var canGenerate: Bool {
        !draft.title.trimmingCharacters(in: .whitespaces).isEmpty
            && totalMaster == 100
            && (draft.splitType == .masterOnly || totalPublishing == 100)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BeatDealSpacing.md) {
                    FormSectionHeader(title: "Morceau")
                    BeatDealTextField(title: "Titre", text: $draft.title, required: true)
                    BeatDealTextField(title: "Artiste principal", text: $draft.artist)

                    Text("Genre")
                        .font(BeatDealTypography.caption)
                        .foregroundStyle(BeatDealColors.textSecondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(AppConstants.splitGenres, id: \.self) { g in
                                Button(g) { draft.genre = draft.genre == g ? "" : g }
                                    .font(BeatDealTypography.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(draft.genre == g ? BeatDealColors.accent : BeatDealColors.card)
                                    .foregroundStyle(BeatDealColors.text)
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    FormSectionHeader(title: "Type de split")
                    HStack(spacing: BeatDealSpacing.sm) {
                        ForEach(SplitSheetType.allCases) { type in
                            Button(type.label) { draft.splitType = type }
                                .font(BeatDealTypography.caption)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(draft.splitType == type ? BeatDealColors.accent : BeatDealColors.card)
                                .foregroundStyle(BeatDealColors.text)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    FormSectionHeader(title: "Collaborateurs")
                    ForEach($draft.collaborators) { $collab in
                        SplitCollaboratorEditor(
                            collaborator: $collab,
                            splitType: draft.splitType,
                            canRemove: draft.collaborators.count > 1,
                            onRemove: {
                                draft.collaborators.removeAll { $0.id == collab.id }
                            }
                        )
                    }

                    Button {
                        draft.collaborators.append(SplitCollaborator.empty())
                    } label: {
                        Label("Ajouter un collaborateur", systemImage: "person.badge.plus")
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    SplitTotalIndicator(label: "Master", total: totalMaster, target: 100)
                    if draft.splitType == .masterAndPublishing {
                        SplitTotalIndicator(label: "Publishing", total: totalPublishing, target: 100)
                    }

                    Button("Générer le PDF") { generate() }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(!canGenerate)
                        .opacity(canGenerate ? 1 : 0.5)
                }
                .padding(BeatDealSpacing.md)
            }
            .background(BeatDealColors.background.ignoresSafeArea())
            .navigationTitle("Split en 90s")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .onAppear {
                draft.applyProfile(profileStorage.profile)
                if let splitImport {
                    draft.applyImport(splitImport)
                }
            }
            .sheet(item: $previewSheet) { sheet in
                SplitSheetPreviewView(
                    split: sheet,
                    pdfURL: previewURL,
                    onDismiss: { dismiss() }
                )
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

    private func generate() {
        guard let sheet = draft.buildSheet() else {
            alertMessage = "Vérifie le titre et les pourcentages (100%)."
            return
        }
        do {
            let url = try SplitSheetPDFGenerator.generatePDF(for: sheet)
            splitStorage.save(sheet)
            previewURL = url
            previewSheet = sheet
        } catch {
            alertMessage = "Erreur PDF : \(error.localizedDescription)"
        }
    }
}
