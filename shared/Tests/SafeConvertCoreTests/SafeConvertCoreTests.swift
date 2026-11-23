import XCTest
@testable import SafeConvertCore

final class SafeConvertCoreTests: XCTestCase {
    func testBeaconPayloadRoundTripsForBlindRelayAndLocalSos() {
        let secret = Array("safeconvert-test-secret-key-0001".utf8)
        let t0: Int64 = 1_760_000_000_000

        let blind = SafeBeaconMeshCore.buildBeaconPayload(
            secret: secret,
            mode: SafeBeaconMeshCore.modeBlindRelay,
            nowMs: t0
        )
        XCTAssertEqual(blind.count, SafeBeaconMeshCore.packetLength)
        let parsedBlind = SafeBeaconMeshCore.parseBeaconPayload(blind, rssi: -68)
        XCTAssertNotNil(parsedBlind)
        XCTAssertEqual(parsedBlind?.isLocalSos, false)
        XCTAssertEqual(parsedBlind?.rotatingTagHex.count, 32)

        let sos = SafeBeaconMeshCore.buildBeaconPayload(
            secret: secret,
            mode: SafeBeaconMeshCore.modeLocalSos,
            nowMs: t0
        )
        let parsedSos = SafeBeaconMeshCore.parseBeaconPayload(sos, rssi: -59)
        XCTAssertEqual(parsedSos?.isLocalSos, true)
        XCTAssertEqual(parsedSos?.approxMeters ?? 0, 1.0, accuracy: 0.2)
    }

    func testRotatingTagChangesEvery15MinutesAndRejectsTampering() {
        let secret = Array("safeconvert-test-secret-key-0002".utf8)
        let t0: Int64 = 1_760_000_000_000
        let p1 = SafeBeaconMeshCore.buildBeaconPayload(
            secret: secret,
            mode: SafeBeaconMeshCore.modeBlindRelay,
            nowMs: t0
        )
        let p2 = SafeBeaconMeshCore.buildBeaconPayload(
            secret: secret,
            mode: SafeBeaconMeshCore.modeBlindRelay,
            nowMs: t0 + SafeBeaconMeshCore.rotationWindowMs
        )
        let b1 = SafeBeaconMeshCore.parseBeaconPayload(p1, rssi: -70)
        let b2 = SafeBeaconMeshCore.parseBeaconPayload(p2, rssi: -70)
        XCTAssertNotNil(b1)
        XCTAssertNotNil(b2)
        XCTAssertNotEqual(b1?.rotatingTagHex, b2?.rotatingTagHex)

        var tampered = p1
        tampered[8] ^= 0xFF
        XCTAssertNil(SafeBeaconMeshCore.parseBeaconPayload(tampered, rssi: -68))
    }

    func testAutoExpiryCapAndRssiBounds() {
        XCTAssertEqual(SafeBeaconMeshCore.maxBeaconDurationMs, 30 * 60 * 1000)
        XCTAssertEqual(SafeBeaconMeshCore.estimateDistanceMeters(rssi: 5), -1.0)
        XCTAssertEqual(SafeBeaconMeshCore.estimateDistanceMeters(rssi: -130), -1.0)
    }

    func testRegionAndLanguageMapping() {
        XCTAssertEqual(SafeBeaconMeshCore.mapIsoCountryToRegion("US"), "US")
        XCTAssertEqual(SafeBeaconMeshCore.mapIsoCountryToRegion(""), "US")
        XCTAssertEqual(SafeBeaconMeshCore.mapIsoCountryToRegion("gb"), "UK")
        XCTAssertEqual(SafeBeaconMeshCore.mapIsoCountryToRegion("DE"), "EU")
        XCTAssertEqual(SafeBeaconMeshCore.mapIsoCountryToRegion("FR"), "EU")
        XCTAssertEqual(SafeBeaconMeshCore.mapIsoCountryToRegion("CA"), "CA")
        XCTAssertEqual(SafeBeaconMeshCore.mapIsoCountryToRegion("AU"), "AU")
        XCTAssertEqual(SafeBeaconMeshCore.mapIsoCountryToRegion("MX"), "MX")
        XCTAssertEqual(SafeBeaconMeshCore.mapIsoCountryToRegion("IN"), "IN")
        XCTAssertEqual(SafeBeaconMeshCore.mapIsoCountryToRegion("JP"), "GLOBAL")

        XCTAssertEqual(SafeBeaconMeshCore.normalizeLangCode("en-US"), "en")
        XCTAssertEqual(SafeBeaconMeshCore.normalizeLangCode("es-MX"), "es")
        XCTAssertEqual(SafeBeaconMeshCore.normalizeLangCode("fr-FR"), "fr")
        XCTAssertEqual(SafeBeaconMeshCore.normalizeLangCode("de-DE"), "de")
        XCTAssertEqual(SafeBeaconMeshCore.normalizeLangCode("pt-BR"), "pt")
        XCTAssertEqual(SafeBeaconMeshCore.normalizeLangCode("ja"), "en")
    }

    func testExternalSchemeAllowlist() {
        XCTAssertTrue(SafeBeaconMeshCore.isAllowedExternalScheme("tel:18007997233"))
        XCTAssertTrue(SafeBeaconMeshCore.isAllowedExternalScheme("sms:88788?body=START"))
        XCTAssertTrue(SafeBeaconMeshCore.isAllowedExternalScheme("mailto:help@example.org"))
        XCTAssertTrue(SafeBeaconMeshCore.isAllowedExternalScheme("https://lawhelp.org"))
        XCTAssertTrue(SafeBeaconMeshCore.isAllowedExternalScheme("geo:0,0?q=hospital"))
        XCTAssertTrue(SafeBeaconMeshCore.isAllowedExternalScheme("maps:?q=hospital"))

        XCTAssertFalse(SafeBeaconMeshCore.isAllowedExternalScheme("http://example.com"))
        XCTAssertFalse(SafeBeaconMeshCore.isAllowedExternalScheme("javascript:alert(1)"))
        XCTAssertFalse(SafeBeaconMeshCore.isAllowedExternalScheme("file:///etc/passwd"))
        XCTAssertFalse(SafeBeaconMeshCore.isAllowedExternalScheme(nil))
    }
}
