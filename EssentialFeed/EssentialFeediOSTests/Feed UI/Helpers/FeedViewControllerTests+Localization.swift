//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Dmitry Kulizhnikov on 14.03.2023.
//

import Foundation
import XCTest
import EssentialFeed

extension FeedUIIntegrationTests {
	func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
		let table = "Feed"
		let bundle = Bundle(for: FeedPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)

		XCTAssertNotEqual(key, value, "Missing localized string for key \(key) in table \(table)", file: file, line: line)
		return value
	}
}
