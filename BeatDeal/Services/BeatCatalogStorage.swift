import Foundation

@MainActor
final class BeatCatalogStorage: ObservableObject {
    static let shared = BeatCatalogStorage()

    @Published private(set) var beats: [CatalogBeat] = []

    private init() {
        load()
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: AppConstants.storageKeyCatalog) else {
            beats = []
            return
        }
        do {
            beats = try JSONDecoder().decode([CatalogBeat].self, from: data)
                .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        } catch {
            beats = []
        }
    }

    func save(_ beat: CatalogBeat) {
        if let index = beats.firstIndex(where: { $0.id == beat.id }) {
            beats[index] = beat
        } else {
            beats.append(beat)
        }
        beats.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        persist()
    }

    func delete(_ beat: CatalogBeat) {
        beats.removeAll { $0.id == beat.id }
        persist()
    }

    func beat(id: String?) -> CatalogBeat? {
        guard let id else { return nil }
        return beats.first { $0.id == id }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(beats)
            UserDefaults.standard.set(data, forKey: AppConstants.storageKeyCatalog)
        } catch {
            // Silent
        }
    }
}
