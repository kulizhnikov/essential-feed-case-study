//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 16.02.2023.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {

	func test_init_doesNotMessageStorageUponCreation() {
		let (_, store) = makeSUT()

		XCTAssertEqual(store.receivedMessages, [])
	}

	func test_load_requestsCacheRetrieval() {
		let (sut, store) = makeSUT()

		sut.load() { _ in }

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_failsOnRetrievalError() {
		let (sut, store) = makeSUT()
		let retrievalError = anyNSError()

		expect(sut, toCompleteWith: .failure(retrievalError), when: {
			store.completeRetrieval(with: retrievalError)
		})
	}

	func test_load_deliversNoImagesOnEmptyCache() {
		let (sut, store) = makeSUT()

		expect(sut, toCompleteWith: .success([]), when: {
			store.completeWithEmptyCache()
		})
	}

	func test_load_deliversNoImagesOnSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let sevenDaysOldTime = fixedCurrentDate.adding(days: -7)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

		expect(sut, toCompleteWith: .success([]), when: {
			store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTime)
		})
	}

	func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThanSevenDaysOldTime = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

		expect(sut, toCompleteWith: .success(feed.models), when: {
			store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTime)
		})
	}

	func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let moreThanSevenDaysOldTime = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
		let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

		expect(sut, toCompleteWith: .success([]), when: {
			store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldTime)
		})
	}

	func test_load_hasNoSideEffectsOnRetrievalError() {
		let (sut, store) = makeSUT()

		sut.load { _ in }
		store.completeRetrieval(with: anyNSError())

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_hasNoSideEffectsOnEmptyCache() {
		let (sut, store) = makeSUT()

		sut.load { _ in }
		store.completeWithEmptyCache()

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_hasNoSideEffectsOnLessThanSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let lessThanSevenDaysOldTime = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
		let (sut, store) = makeSUT()

		sut.load { _ in }
		store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTime)

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_hasNoSideEffectsOnSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let sevenDaysOldTime = fixedCurrentDate.adding(days: -7)
		let (sut, store) = makeSUT()

		sut.load { _ in }
		store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTime)

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_hasNoSideEffectsOnMoreThanSevenDaysOldCache() {
		let feed = uniqueImageFeed()
		let fixedCurrentDate = Date()
		let moreThanSevenDaysOldTime = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
		let (sut, store) = makeSUT()

		sut.load { _ in }
		store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldTime)

		XCTAssertEqual(store.receivedMessages, [.retrieve])
	}

	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let store = FeedStoreSpy()
		var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

		var receivedResults: [LocalFeedLoader.LoadResult] = []
		sut?.load { receivedResult in
			receivedResults.append(receivedResult)
		}

		sut = nil
		store.completeWithEmptyCache()

		XCTAssertTrue(receivedResults.isEmpty)
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

	private func expect(
		_ sut: LocalFeedLoader,
		toCompleteWith expectedResult: LocalFeedLoader.LoadResult,
		when action: () -> Void,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let exp = expectation(description: "Wait for load completion")

		sut.load() { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedImages), .success(expectedImages)):
				XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)

			case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
				XCTAssertEqual(receivedError, expectedError, file: file, line: line)

			default:
				XCTFail("Expected result \(expectedResult), got \(receivedResult)", file: file, line: line)
			}

			exp.fulfill()
		}

		action()
		wait(for: [exp], timeout: 1.0)
	}
}
