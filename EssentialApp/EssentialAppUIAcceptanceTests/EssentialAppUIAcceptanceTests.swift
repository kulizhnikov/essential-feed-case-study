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
		app.launchArguments = ["-reset"]
		app.launch()

		let feedCells = app.cells.matching(identifier: "feed-image-cell")
		XCTAssertEqual(feedCells.count, 22)

		let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
		XCTAssertTrue(firstImage.exists)
	}

	func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
		let onlineApp = XCUIApplication()
		onlineApp.launchArguments = ["-reset"]
		onlineApp.launch()

		let offlineApp = XCUIApplication()
		offlineApp.launchArguments = ["-connectivity", "offline"]
		offlineApp.launch()

		let chachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
		XCTAssertEqual(chachedFeedCells.count, 22)

		let cachedFirstImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
		XCTAssertTrue(cachedFirstImage.exists)
	}

	func test_onLanuch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
		let app = XCUIApplication()
		app.launchArguments = ["-reset", "-connectivity", "offline"]
		app.launch()

		let chachedFeedCells = app.cells.matching(identifier: "feed-image-cell")
		XCTAssertEqual(chachedFeedCells.count, 0)
	}

}
