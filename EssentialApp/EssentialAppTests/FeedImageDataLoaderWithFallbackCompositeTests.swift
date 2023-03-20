//
//  EssentialAppTests.swift
//  EssentialAppTests
//
//  Created by Dmitry Kulizhnikov on 19.03.2023.
//

import XCTest
import EssentialFeed

final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
	private let primary: FeedImageDataLoader
	private let fallback: FeedImageDataLoader

	init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
		self.primary = primary
		self.fallback = fallback
	}

	private struct Task: FeedImageDataLoaderTask {
		func cancel() { }
	}

	func loadImageData(
		from url: URL,
		completion: @escaping (FeedImageDataLoader.Result) -> Void
	) -> EssentialFeed.FeedImageDataLoaderTask {
		_ = primary.loadImageData(from: url) { _ in }

		return Task()
	}
}

final class FeedImageLoaderWithFallbackCompositeTests: XCTestCase {

	func test_init_doesNotLoadImageData() {
		let (_, primaryLoader, fallbackLoader) = makeSUT()

		XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
		XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
	}

	func test_loadImageData_loadsFromPrimaryLoaderFirst() {
		let url = anyURL()
		let (sut, primaryLoader, fallbackLoader) = makeSUT()

		_ = sut.loadImageData(from: url) { _ in }

		XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
		XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
	}

	// MARK: - Helpers

	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: FeedImageDataLoader, primary: LoaderSpy, fallback: LoaderSpy) {
		let primaryLoader = LoaderSpy()
		let fallbackLoader = LoaderSpy()
		let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

		trackForMemoryLeaks(primaryLoader, file: file, line: line)
		trackForMemoryLeaks(fallbackLoader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)

		return (sut, primaryLoader, fallbackLoader)
	}

	private func expect(
		_ sut: FeedLoader,
		toCompleteWith expectedResult: FeedLoader.Result,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let exp = expectation(description: "Wait for load completion")
		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {

			case let (.success(receivedFeed), .success(expectedFeed)):
				XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)

			case (.failure, .failure):
				break

			default:
				XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}

		wait(for: [exp], timeout: 1.0)
	}

	private func uniqueFeed() -> [FeedImage] {
		return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "https://any-url.com")!)]
	}

	private func anyURL() -> URL {
		return URL(string: "http://a-url.com")!
	}

	private class LoaderSpy: FeedImageDataLoader {
		private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()

		var loadedURLs: [URL] {
			return messages.map { $0.url }
		}

		private struct Task: FeedImageDataLoaderTask {
			func cancel() {}
		}

		func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
			messages.append((url, completion))
			return Task()
		}
	}

}
