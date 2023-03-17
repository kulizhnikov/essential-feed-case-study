//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 17.03.2023.
//

import XCTest
import EssentialFeed

public final class RemoteFeedImageDataLoader {
	private let client: HTTPClient

	public init(client: HTTPClient) {
		self.client = client
	}
}


final class RemoteFeedImageDataLoaderTests: XCTestCase {

	func test_init_doesNotPerformAnyRequest() {
		let (_, client) = makeSUT()

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

	// MARK: - Helpers
	private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
			let client = HTTPClientSpy()
			let sut = RemoteFeedImageDataLoader(client: client)
			trackForMemoryLeaks(sut, file: file, line: line)
			trackForMemoryLeaks(client, file: file, line: line)
			return (sut, client)
		}

	private class HTTPClientSpy: HTTPClient {
		var requestedURLs: [URL] = []

		func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
			requestedURLs.append(url)
		}
	}
}
