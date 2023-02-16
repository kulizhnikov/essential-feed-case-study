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

		sut.save(uniqueItems().models) { _ in }

		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
	}

	func test_save_doesNotRequestCacheInsertionOnDeletionError() {
		let (sut, store) = makeSUT()
		let deletionError = anyNSError()

		sut.save(uniqueItems().models) { _ in }
		store.completeDeletion(with: deletionError)

		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
	}

	func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
		let timestamp = Date()
		let (sut, store) = makeSUT(currentDate: { timestamp })
		let items = uniqueItems()

		sut.save(items.models) { _ in }
		store.completeDeletionSuccessfully()

		XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items.local, timestamp)])
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
		sut?.save(uniqueItems().models, completion: { error in
			receivedResults.append(error)
		})

		sut = nil
		store?.completeDeletion(with: anyNSError())

		XCTAssertTrue(receivedResults.isEmpty)
	}

	func test_save_doesNotCallCompletionWithInsertionErrorAfterDeallocation() {
		var (sut, store): (LocalFeedLoader?, FeedStoreSpy?) = makeSUT()

		var receivedResults: [LocalFeedLoader.SaveResult] = []
		sut?.save(uniqueItems().models, completion: { error in
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
		sut.save(uniqueItems().models) { error in
			receivedError = error
			exp.fulfill()
		}

		action()
		wait(for: [exp], timeout: 1)

		XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
	}

	private class FeedStoreSpy: FeedStore {
		enum ReceivedMessage: Equatable {
		 case deleteCachedFeed
		 case insert([LocalFeedItem], Date)
	 }

	 private(set) var receivedMessages: [ReceivedMessage] = []

	 private var deletionCompletions: [DeletionCompletion] = []
	 private var insertionCompletions: [InsertionCompletion] = []

	 func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		 deletionCompletions.append(completion)
		 receivedMessages.append(.deleteCachedFeed)
	 }

	 func completeDeletion(with error: Error, at index: Int = 0) {
		 deletionCompletions[index](error)
	 }

	 func completeDeletionSuccessfully(at index: Int = 0) {
		 deletionCompletions[index](nil)
	 }

	 func completeInsertion(with error: Error, at index: Int = 0) {
		 insertionCompletions[index](error)
	 }

	 func completeInsertionSuccessfully(at index: Int = 0) {
		 insertionCompletions[index](nil)
	 }

	 func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
		 insertionCompletions.append(completion)
		 receivedMessages.append(.insert(items, timestamp))
	 }
 }

	private func anyNSError() -> NSError {
		NSError(domain: "any error", code: 0)
	}

	private func uniqueItem() -> FeedItem {
		return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
	}

	private func uniqueItems() -> (models: [FeedItem], local: [LocalFeedItem]) {
		let models = [uniqueItem(), uniqueItem()]
		let local = models.map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }

		return (models, local)
	}

	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}
}
