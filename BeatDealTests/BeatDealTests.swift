import XCTest
@testable import BeatDeal

final class BeatDealTests: XCTestCase {

    func testLicenseTypeDefaults() {
        XCTAssertEqual(LicenseType.mp3Lease.defaultPrice, 29)
        XCTAssertEqual(LicenseType.exclusive.defaultMaxStreams, Int.max)
        XCTAssertFalse(LicenseType.mp3Lease.defaultRights.commercialRadio)
        XCTAssertTrue(LicenseType.exclusive.defaultRights.sync)
    }

    func testContractDraftValidation() {
        var draft = ContractDraft()
        XCTAssertFalse(draft.canProceedStep1)
        draft.licenseType = .wavLease
        XCTAssertTrue(draft.canProceedStep1)
        XCTAssertFalse(draft.canProceedStep2)

        draft.artistName = "Artist"
        draft.artistEmail = "a@b.com"
        draft.beatTitle = "Beat"
        draft.producerName = "Prod"
        draft.producerEmail = "p@b.com"
        draft.price = "49"
        XCTAssertTrue(draft.canProceedStep2)
    }

    func testContractHTMLContainsReference() {
        let contract = Contract(
            id: "abc12345-uuid",
            createdAt: Date(),
            licenseType: .mp3Lease,
            artistName: "Artist",
            artistEmail: "a@b.com",
            beatTitle: "Dark Trap",
            bpm: 140,
            musicalKey: "A",
            keyMode: "Min",
            producerName: "Metro",
            producerAlias: "Prod. by Metro",
            producerEmail: "p@b.com",
            producerCountry: "France",
            price: 29,
            currency: .eur,
            paymentMethod: .paypal,
            paymentReference: "",
            rights: LicenseType.mp3Lease.defaultRights,
            maxStreams: 2500,
            additionalClauses: ""
        )
        let html = ContractHTMLBuilder.buildHTML(for: contract)
        XCTAssertTrue(html.contains("CONTRAT DE LICENCE DE BEAT"))
        XCTAssertTrue(html.contains("BEAT-ABC12345"))
        XCTAssertTrue(html.contains("Dark Trap"))
    }
}
