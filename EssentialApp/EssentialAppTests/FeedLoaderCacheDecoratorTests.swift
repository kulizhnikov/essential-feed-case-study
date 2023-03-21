//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Dmitry Kulizhnikov on 21.03.2023.
//

import XCTest
import EssentialFeed
import EssentialApp

final class FeedLoaderCacheDecoratorTest: XCTestCase, FeedLoaderTestCase {
	func test_load_deliversFeedOnLoaderSuccess() {
		let feed = uniqueFeed()
		let sut = makeSUT(loaderResult: .success(feed))

		expect(sut, toCompleteWith: .success(feed))
	}

	func test_load_deliversErrorOnLoaderFailure() {
		let sut = makeSUT(loaderResult: .failure(anyNSError()))

		expect(sut, toCompleteWith: .failure(anyNSError()))
	}

	func test_load_cachesLoaderFeedOnLoaderSuccess() {
		let cache = CacheSpy()
		let feed = uniqueFeed()
		let sut = makeSUT(loaderResult: .success(feed), cache: cache)

		sut.load { _ in }
		XCTAssertEqual(cache.messages, [.save(feed)])
	}

	func test_load_doesNotCacheOnLoaderFailure() {
		let cache = CacheSpy()
		let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cache)

		sut.load { _ in }
		XCTAssertTrue(cache.messages.isEmpty)
	}

	// MARK: - Helpers
	private func makeSUT(
		loaderResult: FeedLoader.Result,
		cache: CacheSpy = .init(),
		file: StaticString = #file,
		line: UInt = #line
	) -> FeedLoader {
		let loader = FeedLoaderStub (result: loaderResult)
		let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
		trackForMemoryLeaks (loader, file: file, line: line)
		trackForMemoryLeaks (sut, file: file, line: line)
		return sut
	}

	private final class CacheSpy: FeedCache {
		enum Message: Equatable {
			case save([FeedImage])
		}

		var messages: [Message] = []

		func save(_ feed: [EssentialFeed.FeedImage], completion: @escaping (SaveResult) -> Void) {
			messages.append(.save(feed))
			completion(.success(()))
		}
	}
}
