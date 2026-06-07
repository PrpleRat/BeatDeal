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

    func testRoyaltyCalculatorBreakEven() {
        let spotify = StreamingPlatform(id: "spotify", name: "Spotify", ratePerStreamEUR: 0.003)
        let projection = RoyaltyCalculator.project(
            platform: spotify,
            projectedStreams: 50_000,
            licensePrice: 49,
            licenseTitle: "WAV Lease"
        )
        XCTAssertEqual(projection.breakEvenStreams, 16_334)
        XCTAssertTrue(projection.isProfitable)
        XCTAssertEqual(projection.estimatedRevenueEUR, 150, accuracy: 0.01)
    }

    func testRevenueStatsEngine() {
        let contracts = [
            sampleContract(license: .mp3Lease, price: 29),
            sampleContract(license: .wavLease, price: 49)
        ]
        let allTime = RevenueStatsEngine.stats(for: contracts, in: .all)
        XCTAssertEqual(allTime.totalEUR, 78)
        XCTAssertEqual(allTime.contractCount, 2)
        XCTAssertEqual(allTime.byLicenseType[.mp3Lease], 1)
        XCTAssertEqual(allTime.byLicenseType[.wavLease], 1)
    }

    func testContractStreamAlertThreshold() {
        var contract = sampleContract(license: .mp3Lease, price: 29)
        contract.streamsReported = 2_000
        contract.maxStreams = 2_500
        XCTAssertFalse(contract.isApproachingStreamLimit)
        contract.streamsReported = 2_100
        XCTAssertTrue(contract.isApproachingStreamLimit)
        XCTAssertEqual(contract.suggestedUpgradeLicense, .wavLease)
    }

    func testContractHTMLContainsReference() {
        let contract = sampleContract(license: .mp3Lease, price: 29)
        let html = ContractHTMLBuilder.buildHTML(for: contract)
        XCTAssertTrue(html.contains("CONTRAT DE LICENCE DE BEAT"))
        XCTAssertTrue(html.contains("Dark Trap"))
    }

    private func sampleContract(license: LicenseType, price: Int) -> Contract {
        Contract(
            id: "abc12345-uuid",
            createdAt: Date(),
            licenseType: license,
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
            price: price,
            currency: .eur,
            paymentMethod: .paypal,
            paymentReference: "",
            rights: license.defaultRights,
            maxStreams: license.defaultMaxStreams == Int.max ? 999_999 : license.defaultMaxStreams,
            additionalClauses: "",
            pdfFileName: nil,
            streamsReported: 0,
            expiresAt: Contract.defaultExpiresAt(from: Date(), licenseType: license),
            catalogBeatId: nil
        )
    }
}
