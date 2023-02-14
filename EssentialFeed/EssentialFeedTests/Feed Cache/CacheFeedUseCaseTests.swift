//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 14.02.2023.
//

import XCTest

class LocalFeedLoader {
	init(store: FeedStore) {

	}
}

class FeedStore {
	var deleteCachedFeedCallCount = 0
}

final class CacheFeedUseCaseTests: XCTestCase {

	func test_init_doesNotDeleteCacheUponCreation() {
		let store = FeedStore()
		_ = LocalFeedLoader(store: store)

		XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
	}

}
