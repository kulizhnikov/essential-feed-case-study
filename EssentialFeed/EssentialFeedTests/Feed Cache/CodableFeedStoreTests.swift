//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 17.02.2023.
//

import XCTest
import EssentialFeed

final class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {

	override func setUp() {
		super.setUp()

		setupEmptyStoreState()
	}

	override func tearDown() {
		super.tearDown()

		setupEmptyStoreState()
	}

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()

		expect(sut, toRetrieve: .empty)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		expect(sut, toRetrieveTwice: .empty)
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date()

		insert((feed, timestamp), to: sut)

		expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
	}

	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		let sut = makeSUT()
		let feed = uniqueImageFeed().local
		let timestamp = Date()

		insert((feed, timestamp), to: sut)

		expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
	}

	func test_retrive_deliversFailureOnRetrievalError() {
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)

		try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

		expect(sut, toRetrieve: .failure(anyNSError()))
	}

	func test_retrieve_hasNoSideEffectsOnFailure() {
		let storeURL = testSpecificStoreURL()
		let sut = makeSUT(storeURL: storeURL)

		try! "Invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

		expect(sut, toRetrieveTwice: .failure(anyNSError()))
	}

	func test_insert_overridePreviouslyInsertedCacheValues() {
		let sut = makeSUT()

		let firstInsertion = insert((uniqueImageFeed().local, Date()), to: sut)
		XCTAssertNil(firstInsertion, "Expected to insert cache successfully")

		let latestFeed = uniqueImageFeed().local
		let latestTimestamp = Date()
		let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)

		XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
		expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
	}

	func test_insert_deliversErrorOnInsertionError() {
		let invalidStoreURL = URL(string: "invalid://store-url")!
		let sut = makeSUT(storeURL: invalidStoreURL)

		let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
		XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
	}

	func test_insert_hasNoSideEffectsOnInsertionError() {
		let invalidStoreURL = URL(string: "invalid://store-url")!
		let sut = makeSUT(storeURL: invalidStoreURL)

		insert((uniqueImageFeed().local, Date()), to: sut)

		expect(sut, toRetrieve: .empty)
	}

	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		let deletionError = deleteCache(from: sut)

		XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
		expect(sut, toRetrieve: .empty)
	}

	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()
		insert((uniqueImageFeed().local, Date()), to: sut)

		let deletionError = deleteCache(from: sut)

		XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
		expect(sut, toRetrieve: .empty)
	}

	func test_delete_deliversErrorOnDelitionError() {
		let noDeleteAccessURL = noAccessDirectory()
		let sut = makeSUT(storeURL: noDeleteAccessURL)

		let deletionError = deleteCache(from: sut)

		XCTAssertNotNil(deletionError, "Expected error on deletion for no access directory")
	}

	func test_delete_hasNoSideEffectsOnDelitionError() {
		let noDeleteAccessURL = noAccessDirectory()
		let sut = makeSUT(storeURL: noDeleteAccessURL)

		deleteCache(from: sut)

		expect(sut, toRetrieve: .empty)
	}

	func test_storeSideEffects_runSerially() {
		let sut = makeSUT()
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

		let op3 = expectation(description: "Operation 2")
		sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
			completedOperationsInOrder.append(op3)
			op3.fulfill()
		}

		waitForExpectations(timeout: 5.0)

		XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3])
	}

	// MARK: - Helpers
	private func makeSUT(
		storeURL: URL? = nil,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> FeedStore {
		let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
		trackForMemoryLeaks(sut)

		return sut
	}

	@discardableResult
	private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
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
	private func deleteCache(from sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for cache deletion")
		var deletionError: Error?
		sut.deleteCachedFeed() { receivedDeletionError in
			deletionError = receivedDeletionError
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)

		return deletionError

	}

	private func expect(
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

	private func expect(
		_ sut: FeedStore,
		toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}

	private func setupEmptyStoreState() {
		deleteStoreArtifacts()
	}

	private func undoStoreSideEffects() {
		deleteStoreArtifacts()
	}

	private func deleteStoreArtifacts() {
		try? FileManager.default.removeItem(at: testSpecificStoreURL())
	}

	private func testSpecificStoreURL() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
	}

	private func noAccessDirectory() -> URL {
		return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
	}
}
