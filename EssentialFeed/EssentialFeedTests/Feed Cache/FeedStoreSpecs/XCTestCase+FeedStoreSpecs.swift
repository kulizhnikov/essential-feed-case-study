//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 02.03.2023.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
	func assertThatRetrieveDeliversEmptyOnEmptyCache(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		expect(sut, toRetrieve: .empty, file: file, line: line)
	}

	func assertThatRetriveHasNoSideEffectsOnEmptyCache(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		expect(sut, toRetrieveTwice: .empty, file: file, line: line)
	}

	func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let feed = uniqueImageFeed().local
		let timestamp = Date()

		insert((feed, timestamp), to: sut)

		expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp), file: file, line: line)
	}

	func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let feed = uniqueImageFeed().local
		let timestamp = Date()

		insert((feed, timestamp), to: sut)

		expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp), file: file, line: line)
	}

	func assertThatInsertDeliversNoErrorOnEmptyCache(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let firstInsertion = insert((uniqueImageFeed().local, Date()), to: sut)
		XCTAssertNil(firstInsertion, "Expected to insert cache successfully", file: file, line: line)
	}

	func assertThatInsertDeliversNoErrorOnNonEmptyCache(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		insert((uniqueImageFeed().local, Date()), to: sut)

		let latestFeed = uniqueImageFeed().local
		let latestTimestamp = Date()
		let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)

		XCTAssertNil(latestInsertionError, "Expected to insert into non-empty cache successfully", file: file, line: line)
	}

	func assertThatInsertOverridePreviouslyInsertedCacheValues(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		insert((uniqueImageFeed().local, Date()), to: sut)

		let latestFeed = uniqueImageFeed().local
		let latestTimestamp = Date()
		insert((latestFeed, latestTimestamp), to: sut)

		expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp), file: file, line: line)
	}

	func assertThatDeleteDeliversNoErrorOnEmptyCache(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let deletionError = deleteCache(from: sut)

		XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
	}

	func assertThatDeleteHasNoSideEffectsOnEmptyCache(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		deleteCache(from: sut)

		expect(sut, toRetrieve: .empty, file: file, line: line)
	}

	func assertThatDeleteDeliversNoErrorOnNonEmptyCache(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		insert((uniqueImageFeed().local, Date()), to: sut)

		let deletionError = deleteCache(from: sut)

		XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
	}

	func assertThatDeleteEmptiesPreviouslyInsertedCache(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		insert((uniqueImageFeed().local, Date()), to: sut)

		deleteCache(from: sut)

		expect(sut, toRetrieve: .empty, file: file, line: line)
	}

	func assertThatStoreSideEffectsRunSerially(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		var completedOperationsInOrder: [XCTestExpectation] = []

		let op1 = expectation(description: "Operation 1")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationsInOrder.append(op1)
			op1.fulfill()
		}

		let op2 = expectation(description: "Operation 2")
		sut.deleteCachedFeed { _ in
			completedOperationsInOrder.append(op2)
			op2.fulfill()
		}

		let op3 = expectation(description: "Operation 3")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationsInOrder.append(op3)
			op3.fulfill()
		}

		waitForExpectations(timeout: 5.0)

		XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], file: file, line: line)
	}

}

extension FeedStoreSpecs where Self: XCTestCase {
	@discardableResult
	func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for cache insertion")
		var insertionError: Error?
		sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
			insertionError = receivedInsertionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)

		return insertionError

	}

	@discardableResult
	func deleteCache(from sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for cache deletion")
		var deletionError: Error?
		sut.deleteCachedFeed() { receivedDeletionError in
			deletionError = receivedDeletionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)

		return deletionError

	}

	func expect(
		_ sut: FeedStore,
		toRetrieve expectedResult: RetrieveCachedFeedResult,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let exp = expectation(description: "Wait for cache retrieval")
		sut.retrieve { retrievedResult in
			switch (retrievedResult, expectedResult) {
			case (.empty, .empty),
				(.failure, .failure):
				break

			case let (.found(retrievedFeed, retrievedTimestamp), .found(expectedFeed, expectedTimestamp)):
				XCTAssertEqual(retrievedFeed, expectedFeed)
				XCTAssertEqual(retrievedTimestamp, expectedTimestamp)

			default:
				XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
			}

			exp.fulfill()
		}

		wait(for: [exp], timeout: 1.0)
	}

	func expect(
		_ sut: FeedStore,
		toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}
}
