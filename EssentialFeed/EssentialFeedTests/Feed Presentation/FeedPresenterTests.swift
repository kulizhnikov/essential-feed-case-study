//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 17.03.2023.
//

import XCTest
import EssentialFeed

final class FeedPresenterTests: XCTestCase {

	func test_title_isLocalized() {
		XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
	}

	func test_map_createsViewModels() {
		let feed = uniqueImageFeed().models

		let viewModel = FeedPresenter.map(feed)

		XCTAssertEqual(viewModel.feed, feed)
	}

	// MARK: - Helpers

	private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "Feed"
		let bundle = Bundle(for: FeedPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)

		XCTAssertNotEqual(key, value, "Missing localized string for key \(key) in table \(table)", file: file, line: line)
		return value
	}
}
