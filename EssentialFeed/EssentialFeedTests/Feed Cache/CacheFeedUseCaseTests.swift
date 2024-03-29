//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 14.02.2023.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {

	func test_init_doesNotMessageStorageUponCreation() {
		let (_, store) = makeSUT()

		XCTAssertEqual(store.receivedMessages, [])
	}

	func test_save_requestsCacheDeletion() {
		let (sut, store) = makeSUT()

		sut.save(uniqueImageFeed().models) { _ in }

		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
	}

	func test_save_doesNotRequestCacheInsertionOnDeletionError() {
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()

		sut.save(uniqueImageFeed().models) { _ in }
		store.completeDeletion(with: deletionError)

		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
	}

	func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
		let timestamp = Date()
		let (sut, store) = makeSUT(currentDate: { timestamp })
		let feed = uniqueImageFeed()

		sut.save(feed.models) { _ in }
		store.completeDeletionSuccessfully()

		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timestamp)])
	}

	func test_save_failsOnDeletionError() {
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()

		expect(sut, toCompleteWithError: deletionError, when: {
			store.completeDeletion(with: deletionError)
		})
	}

	func test_save_failsOnInsertionError() {
		let (sut, store) = makeSUT()
		let insertionError = anyNSError()

		expect(sut, toCompleteWithError: insertionError, when: {
			store.completeDeletionSuccessfully()
			store.completeInsertion(with: insertionError)
		})
	}

	func test_save_succeedsOnSuccessfulCacheInsertion() {
		let (sut, store) = makeSUT()

		expect(sut, toCompleteWithError: nil, when: {
			store.completeDeletionSuccessfully()
			store.completeInsertionSuccessfully()
		})
	}

	func test_save_doesNotCallCompletionWithDeletionErrorAfterDeallocation() {
		var (sut, store): (LocalFeedLoader?, FeedStoreSpy?) = makeSUT()

		var receivedResults: [LocalFeedLoader.SaveResult] = []
		sut?.save(uniqueImageFeed().models, completion: { error in
			receivedResults.append(error)
		})

		sut = nil
		store?.completeDeletion(with: anyNSError())

		XCTAssertTrue(receivedResults.isEmpty)
	}

	func test_save_doesNotCallCompletionWithInsertionErrorAfterDeallocation() {
		var (sut, store): (LocalFeedLoader?, FeedStoreSpy?) = makeSUT()

		var receivedResults: [LocalFeedLoader.SaveResult] = []
		sut?.save(uniqueImageFeed().models, completion: { error in
			receivedResults.append(error)
		})

		store?.completeDeletionSuccessfully()
		sut = nil
		store?.completeInsertion(with: anyNSError())

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
		toCompleteWithError expectedError: NSError?,
		when action: () -> Void,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		var receivedError: Error?
		let exp = expectation(description: "Waiting for completion")
		sut.save(uniqueImageFeed().models) { saveResult in
			if case let Result.failure(error) = saveResult {
				receivedError = error
			}
			exp.fulfill()
		}

		action()
		wait(for: [exp], timeout: 1)

		XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
	}
}
