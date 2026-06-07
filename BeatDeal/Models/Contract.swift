import Foundation

struct ProducerProfile: Codable, Equatable {
    var producerName: String = ""
    var producerAlias: String = ""
    var email: String = ""
    var siret: String = ""
    var country: String = "France"
    var currency: Currency = .eur
}

struct Contract: Codable, Identifiable, Equatable {
    var id: String
    var createdAt: Date
    var licenseType: LicenseType
    var artistName: String
    var artistEmail: String
    var beatTitle: String
    var bpm: Int?
    var musicalKey: String?
    var keyMode: String?
    var producerName: String
    var producerAlias: String
    var producerEmail: String
    var producerCountry: String
    var price: Int
    var currency: Currency
    var paymentMethod: PaymentMethod
    var paymentReference: String
    var rights: ContractRights
    var maxStreams: Int
    var additionalClauses: String
    var pdfFileName: String?

    var reference: String { "BEAT-\(id.prefix(8).uppercased())" }

    var tonaliteLabel: String? {
        guard let musicalKey, let keyMode else { return nil }
        return "\(musicalKey) \(keyMode)"
    }

    var licenseBadge: String { licenseType.title }
}

struct ContractDraft: Equatable {
    var step: Int = 1
    var licenseType: LicenseType?
    var artistName: String = ""
    var artistEmail: String = ""
    var beatTitle: String = ""
    var bpm: String = ""
    var selectedKey: MusicalKey?
    var selectedMode: KeyMode?
    var producerName: String = ""
    var producerAlias: String = ""
    var producerEmail: String = ""
    var producerCountry: String = "France"
    var price: String = ""
    var currency: Currency = .eur
    var paymentMethod: PaymentMethod = .paypal
    var paymentReference: String = ""
    var rights: ContractRights = LicenseType.mp3Lease.defaultRights
    var maxStreams: Int = LicenseType.mp3Lease.defaultMaxStreams
    var additionalClauses: String = ""

    mutating func applyProfile(_ profile: ProducerProfile) {
        producerName = profile.producerName
        producerAlias = profile.producerAlias
        producerEmail = profile.email
        producerCountry = profile.country
        currency = profile.currency
    }

    mutating func applyTemplate(_ template: LicenseTemplate) {
        price = String(template.defaultPrice)
        rights = template.defaultRights
        maxStreams = template.maxStreams
        if additionalClauses.isEmpty {
            additionalClauses = template.defaultClause
        }
    }

    func buildContract(id: String = UUID().uuidString) -> Contract? {
        guard let licenseType else { return nil }
        guard let priceInt = Int(price.trimmingCharacters(in: .whitespaces)) else { return nil }

        return Contract(
            id: id,
            createdAt: Date(),
            licenseType: licenseType,
            artistName: artistName.trimmingCharacters(in: .whitespaces),
            artistEmail: artistEmail.trimmingCharacters(in: .whitespaces),
            beatTitle: beatTitle.trimmingCharacters(in: .whitespaces),
            bpm: Int(bpm.trimmingCharacters(in: .whitespaces)),
            musicalKey: selectedKey?.label,
            keyMode: selectedMode?.rawValue,
            producerName: producerName.trimmingCharacters(in: .whitespaces),
            producerAlias: producerAlias.trimmingCharacters(in: .whitespaces),
            producerEmail: producerEmail.trimmingCharacters(in: .whitespaces),
            producerCountry: producerCountry.trimmingCharacters(in: .whitespaces),
            price: priceInt,
            currency: currency,
            paymentMethod: paymentMethod,
            paymentReference: paymentReference.trimmingCharacters(in: .whitespaces),
            rights: rights,
            maxStreams: maxStreams,
            additionalClauses: additionalClauses.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    var canProceedStep1: Bool { licenseType != nil }

    var canProceedStep2: Bool {
        !artistName.trimmingCharacters(in: .whitespaces).isEmpty
            && !artistEmail.trimmingCharacters(in: .whitespaces).isEmpty
            && artistEmail.contains("@")
            && !beatTitle.trimmingCharacters(in: .whitespaces).isEmpty
            && !producerName.trimmingCharacters(in: .whitespaces).isEmpty
            && !producerEmail.trimmingCharacters(in: .whitespaces).isEmpty
            && Int(price.trimmingCharacters(in: .whitespaces)) != nil
    }
}
