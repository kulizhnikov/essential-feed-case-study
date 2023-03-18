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

		sut.validateCache() { _ in }
		store.completeRetrieval(with: anyNSError())

		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}

	func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
		let (sut, store) = makeSUT()

		sut.validateCache() { _ in }
		store.completeWithEmptyCache()

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_validateCache_doesNotDeleteNonExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
		let (sut, store) = makeSUT()

		sut.validateCache() { _ in }
		store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_validateCache_deletesCacheOnExpiration() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
		let (sut, store) = makeSUT()

		sut.validateCache() { _ in }
		store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)

		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}

	func test_validateCache_deletesExpiredCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
		let (sut, store) = makeSUT()

		sut.validateCache() { _ in }
		store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)

		XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
	}

	func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

		sut?.validateCache() { _ in }
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
