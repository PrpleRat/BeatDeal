import Foundation

enum SplitSheetType: String, Codable, CaseIterable, Identifiable {
    case masterOnly = "master_only"
    case masterAndPublishing = "master_and_publishing"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .masterOnly: return "Master uniquement"
        case .masterAndPublishing: return "Master + Publishing"
        }
    }
}

enum SplitCollaboratorRole: String, Codable, CaseIterable, Identifiable {
    case producteur = "Producteur"
    case coproducteur = "Co-producteur"
    case parolier = "Parolier"
    case compositeur = "Compositeur"
    case artiste = "Artiste"
    case arrangeur = "Arrangeur"
    case custom = "Custom"

    var id: String { rawValue }
}

struct SplitCollaborator: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var role: String
    var masterShare: Int
    var publishingShare: Int
    var sacem: String?
    var email: String?
    var signed: Bool

    static func empty(id: String = UUID().uuidString) -> SplitCollaborator {
        SplitCollaborator(
            id: id,
            name: "",
            role: SplitCollaboratorRole.producteur.rawValue,
            masterShare: 0,
            publishingShare: 0,
            sacem: nil,
            email: nil,
            signed: false
        )
    }
}

struct SplitSheet: Codable, Identifiable, Equatable {
    var id: String
    var ref: String
    var title: String
    var artist: String?
    var genre: String?
    var isrc: String?
    var createdAt: Date
    var splitType: SplitSheetType
    var collaborators: [SplitCollaborator]
    var clauses: [String]
    var notes: String?
    var status: String

    var totalMaster: Int {
        collaborators.reduce(0) { $0 + $1.masterShare }
    }

    var totalPublishing: Int {
        collaborators.reduce(0) { $0 + $1.publishingShare }
    }

    var isValid: Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard collaborators.contains(where: { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }) else { return false }
        guard totalMaster == 100 else { return false }
        if splitType == .masterAndPublishing {
            return totalPublishing == 100
        }
        return true
    }

    static func generateRef() -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        let code = (0..<6).map { _ in chars.randomElement()! }
        return "SPLIT-\(String(code))"
    }
}

struct SplitSheetDraft: Equatable {
    var title: String = ""
    var artist: String = ""
    var genre: String = ""
    var isrc: String = ""
    var createdAt: Date = Date()
    var splitType: SplitSheetType = .masterAndPublishing
    var collaborators: [SplitCollaborator] = [SplitCollaborator.empty()]
    var clauses: [String] = [
        "Ce split s'applique à toutes les versions du morceau",
        "En cas de sample non clearé, ce split est suspendu",
    ]
    var notes: String = ""

    mutating func applyProfile(_ profile: ProducerProfile) {
        guard let first = collaborators.indices.first else { return }
        if collaborators[first].name.isEmpty {
            collaborators[first].name = profile.producerAlias.isEmpty ? profile.producerName : profile.producerAlias
            collaborators[first].email = profile.email
        }
    }

    mutating func applyImport(_ importData: SplitPadImport) {
        title = importData.title
        if let a = importData.artist, !a.isEmpty {
            artist = a
        }
        if let coName = importData.coProducerName, let share = importData.coProducerSharePercent {
            if collaborators.count < 2 {
                collaborators.append(SplitCollaborator.empty())
            }
            collaborators[1].name = coName
            collaborators[1].role = SplitCollaboratorRole.coproducteur.rawValue
            collaborators[1].masterShare = share
        }
    }

    func buildSheet(id: String = UUID().uuidString) -> SplitSheet? {
        let valid = collaborators.filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty, !valid.isEmpty else { return nil }

        return SplitSheet(
            id: id,
            ref: SplitSheet.generateRef(),
            title: title.trimmingCharacters(in: .whitespaces),
            artist: artist.isEmpty ? nil : artist,
            genre: genre.isEmpty ? nil : genre,
            isrc: isrc.isEmpty ? nil : isrc,
            createdAt: createdAt,
            splitType: splitType,
            collaborators: valid,
            clauses: clauses,
            notes: notes.isEmpty ? nil : notes,
            status: "pending"
        )
    }
}
