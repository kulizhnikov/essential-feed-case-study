//
//  EssentialAppUIAcceptanceTests.swift
//  EssentialAppUIAcceptanceTests
//
//  Created by Dmitry Kulizhnikov on 22.03.2023.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {

	func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
		let app = XCUIApplication()

		app.launch()

		XCTAssertEqual(app.cells.count, 22)
		XCTAssertEqual(app.cells.firstMatch.images.count, 1)
	}

}
