//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Dmitry Kulizhnikov on 15.03.2023.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
	func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
		let table = "Feed"
		let bundle = Bundle(for: FeedPresenter.self)
		assertLocalizedKeyAndValuesExist(in: bundle, table)
	}
}
