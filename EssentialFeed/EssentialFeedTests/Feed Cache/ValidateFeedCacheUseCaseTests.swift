//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 16.02.2023.
//

import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {

	func test_init_doesNotMessageStorageUponCreation() {
		let (_, store) = makeSUT()

		XCTAssertEqual(store.receivedMessages, [])
	}

	func test_validateCache_deletesCacheOnRetrievalError() {
		let (sut, store) = makeSUT()

		sut.validateCache()
		store.completeRetrieval(with: anyNSError())

		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}

	func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
		let (sut, store) = makeSUT()

		sut.validateCache()
		store.completeWithEmptyCache()

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_validateCache_doesNotDeleteLessThanSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThanSevenDaysOldTime = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
		let (sut, store) = makeSUT()

		sut.validateCache()
		store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTime)

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_validateCache_deletesSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let sevenDaysOldTime = fixedCurrentDate.adding(days: -7)
		let (sut, store) = makeSUT()

		sut.validateCache()
		store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTime)

		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}

	func test_validateCache_deletesMoreThanSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let moreThanSevenDaysOldTime = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
		let (sut, store) = makeSUT()

		sut.validateCache()
		store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldTime)

		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}

	func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

		sut?.validateCache()
		sut = nil

		store.completeRetrieval(with: anyNSError())

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	// MARK: - Helpers
	private func makeSUT(
		currentDate: @escaping () -> Date = Date.init,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
		let store = FeedStoreSpy()
		let sut = LocalFeedLoader(store: store, currentDate: currentDate)
		trackForMemoryLeaks(store)
		trackForMemoryLeaks(sut)
		return (sut, store)
	}
}
