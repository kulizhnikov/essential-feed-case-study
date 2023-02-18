//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 17.02.2023.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
	private struct Cache: Codable {
		let feed: [CodableFeedImage]
		let timestamp: Date

		var localFeed: [LocalFeedImage] {
			return feed.map { $0.local }
		}
	}

	private struct CodableFeedImage: Codable {
		private let id: UUID
		private let description: String?
		private let location: String?
		private let url: URL

		init(_ image: LocalFeedImage) {
			id = image.id
			description = image.description
			location = image.location
			url = image.url
		}

		var local: LocalFeedImage {
			LocalFeedImage(id: id, description: description, location: location, url: url)
		}
	}

	private let storeURL: URL

	init(storeURL: URL) {
		self.storeURL = storeURL
	}

	func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
		guard let data = try? Data(contentsOf: storeURL) else {
			completion(.empty)
			return
		}


		do {
			let decoder = JSONDecoder()
			let cache = try decoder.decode(Cache.self, from: data)
			completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
		} catch {
			completion(.failure(error))
		}
	}

	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
		let encoder = JSONEncoder()
		let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
		let encoded = try! encoder.encode(cache)
		try! encoded.write(to: storeURL)
		completion(nil)
	}
}

final class CodableFeedStoreTests: XCTestCase {

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
		let sut = makeSUT()

		try! "Invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)

		expect(sut, toRetrieve: .failure(anyNSError()))
	}

	// MARK: - Helpers
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> CodableFeedStore {
		let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
		trackForMemoryLeaks(sut)

		return sut
	}

	private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore) {
		let exp = expectation(description: "Wait for cache insertion")
		sut.insert(cache.feed, timestamp: cache.timestamp) { insertionError in
			XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}

	private func expect(
		_ sut: CodableFeedStore,
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
		_ sut: CodableFeedStore,
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
}