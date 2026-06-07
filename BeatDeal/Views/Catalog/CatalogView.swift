import SwiftUI

struct CatalogView: View {
    @ObservedObject private var catalog = BeatCatalogStorage.shared
    @State private var editingBeat: CatalogBeat?
    @State private var showNewBeat = false

    var body: some View {
        NavigationStack {
            Group {
                if catalog.beats.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(catalog.beats) { beat in
                            Button {
                                editingBeat = beat
                            } label: {
                                catalogRow(beat)
                            }
                            .listRowBackground(BeatDealColors.card)
                        }
                        .onDelete(perform: delete)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(BeatDealColors.background.ignoresSafeArea())
            .navigationTitle("Catalogue")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewBeat = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $editingBeat) { beat in
                CatalogBeatEditorView(beat: beat) { updated in
                    catalog.save(updated)
                }
            }
            .sheet(isPresented: $showNewBeat) {
                CatalogBeatEditorView(beat: newBeat()) { updated in
                    catalog.save(updated)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: BeatDealSpacing.md) {
            Image(systemName: "music.note.list")
                .font(.system(size: 48))
                .foregroundStyle(BeatDealColors.accent.opacity(0.6))
            Text("Ajoute tes beats disponibles")
                .font(BeatDealTypography.body)
                .foregroundStyle(BeatDealColors.textSecondary)
            Button("+ Ajouter un beat") { showNewBeat = true }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, BeatDealSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func catalogRow(_ beat: CatalogBeat) -> some View {
        VStack(alignment: .leading, spacing: BeatDealSpacing.xs) {
            Text(beat.title)
                .font(BeatDealTypography.headline)
                .foregroundStyle(BeatDealColors.text)
            HStack(spacing: BeatDealSpacing.sm) {
                if let bpm = beat.bpm {
                    Text("\(bpm) BPM")
                }
                if let tonalite = beat.tonaliteLabel {
                    Text(tonalite)
                }
                Text(beat.genre.label)
            }
            .font(BeatDealTypography.caption)
            .foregroundStyle(BeatDealColors.textSecondary)
            Text("MP3 \(beat.prices.mp3Lease) € · WAV \(beat.prices.wavLease) € · Excl. \(beat.prices.exclusive) €")
                .font(BeatDealTypography.caption)
                .foregroundStyle(BeatDealColors.accentLight)
        }
        .padding(.vertical, 4)
    }

    private func newBeat() -> CatalogBeat {
        CatalogBeat(
            id: UUID().uuidString,
            title: "",
            bpm: nil,
            musicalKey: nil,
            keyMode: nil,
            genre: .trap,
            prices: .defaults(),
            createdAt: Date()
        )
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            catalog.delete(catalog.beats[index])
        }
    }
}

struct CatalogBeatEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State var beat: CatalogBeat
    var onSave: (CatalogBeat) -> Void

    @State private var bpmText = ""
    @State private var selectedKey: MusicalKey?
    @State private var selectedMode: KeyMode?
    @State private var priceTexts: [LicenseType: String] = [:]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BeatDealSpacing.md) {
                    BeatDealTextField(title: "Titre", text: $beat.title, required: true)
                    BeatDealTextField(title: "BPM", text: $bpmText, keyboard: .numberPad)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Genre")
                            .font(BeatDealTypography.caption)
                            .foregroundStyle(BeatDealColors.textSecondary)
                        Picker("Genre", selection: $beat.genre) {
                            ForEach(BeatGenre.allCases) { genre in
                                Text(genre.label).tag(genre)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(BeatDealColors.accentLight)
                    }

                    HStack(spacing: BeatDealSpacing.sm) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tonalité")
                                .font(BeatDealTypography.caption)
                                .foregroundStyle(BeatDealColors.textSecondary)
                            Picker("Tonalité", selection: $selectedKey) {
                                Text("—").tag(Optional<MusicalKey>.none)
                                ForEach(MusicalKey.allCases) { key in
                                    Text(key.label).tag(Optional(key))
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(BeatDealColors.accentLight)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mode")
                                .font(BeatDealTypography.caption)
                                .foregroundStyle(BeatDealColors.textSecondary)
                            Picker("Mode", selection: $selectedMode) {
                                Text("—").tag(Optional<KeyMode>.none)
                                ForEach(KeyMode.allCases) { mode in
                                    Text(mode.rawValue).tag(Optional(mode))
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(BeatDealColors.accentLight)
                        }
                    }

                    FormSectionHeader(title: "Prix par type de licence")
                    ForEach(LicenseType.allCases) { type in
                        BeatDealTextField(
                            title: type.title,
                            text: bindingPrice(for: type),
                            keyboard: .numberPad
                        )
                    }
                }
                .padding(BeatDealSpacing.md)
            }
            .background(BeatDealColors.background.ignoresSafeArea())
            .navigationTitle(beat.title.isEmpty ? "Nouveau beat" : beat.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") { saveBeat() }
                        .disabled(beat.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { syncFromBeat() }
        }
    }

    private func bindingPrice(for type: LicenseType) -> Binding<String> {
        Binding(
            get: { priceTexts[type] ?? String(beat.prices.price(for: type)) },
            set: { priceTexts[type] = $0 }
        )
    }

    private func syncFromBeat() {
        bpmText = beat.bpm.map(String.init) ?? ""
        selectedKey = beat.musicalKey.flatMap { key in MusicalKey.allCases.first { $0.label == key } }
        selectedMode = beat.keyMode.flatMap { mode in KeyMode.allCases.first { $0.rawValue == mode } }
        for type in LicenseType.allCases {
            priceTexts[type] = String(beat.prices.price(for: type))
        }
    }

    private func saveBeat() {
        beat.bpm = Int(bpmText.trimmingCharacters(in: .whitespaces))
        beat.musicalKey = selectedKey?.label
        beat.keyMode = selectedMode?.rawValue
        for type in LicenseType.allCases {
            if let text = priceTexts[type], let value = Int(text) {
                beat.prices.setPrice(value, for: type)
            }
        }
        onSave(beat)
        dismiss()
    }
}

#Preview {
    CatalogView()
        .preferredColorScheme(.dark)
}
