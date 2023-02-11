//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 09.02.2023.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
	private let session: URLSession

	init(session: URLSession = .shared) {
		self.session = session
	}

	struct UnexpectedResultRepresentation: Error { }

	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
		session.dataTask(with: url) { _, _, error in
			if let error = error {
				completion(.failure(error))
			} else {
				completion(.failure(UnexpectedResultRepresentation()))
			}
		}.resume()
	}
}

final class URLSessionHTTPClientTests: XCTestCase {
	func test_getFromURL_performsGetRequestWithURL() {
		URLProtocolStub.startInterceptingRequests()
		let url = anyURL()

		let exp = expectation(description: "Wait for request")
		URLProtocolStub.observeRequests { request in
			XCTAssertEqual(request.url, url)
			XCTAssertEqual(request.httpMethod, "GET")
			exp.fulfill()
		}

		makeSUT().get(from: url) { _ in }

		wait(for: [exp], timeout: 1.0)
		URLProtocolStub.stopInterceptingRequests()
	}

	func test_getFromURL_failsOnRequestError() {
		URLProtocolStub.startInterceptingRequests()
		let requestError = NSError(domain: "any error", code: 1)

		let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as? NSError
		XCTAssertEqual(receivedError?.code, requestError.code)
		XCTAssertEqual(receivedError?.domain, requestError.domain)

		URLProtocolStub.stopInterceptingRequests()
	}

	func test_getFromURL_failsOnInvalidRepresentationCase() {
		URLProtocolStub.startInterceptingRequests()

		XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))

		URLProtocolStub.stopInterceptingRequests()
	}

	// MARK: - Helpers
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
		let sut = URLSessionHTTPClient()

		trackForMemoryLeaks(sut, file: file, line: line)

		return sut
	}

	private func resultErrorFor(
		data: Data?,
		response: URLResponse?,
		error: Error?,
		file: StaticString = #filePath,
		line: UInt = #line
	) -> Error? {
		URLProtocolStub.stub(data: data, response: response, error: error)
		let sut = makeSUT(file: file, line: line)
		let exp = expectation(description: "Wait for completion")

		var receivedError: Error?
		sut.get(from: anyURL()) { result in
			switch result {
			case let .failure(error):
				receivedError = error
			default:
				XCTFail("Expected failure, got \(result) instead", file: file, line: line)
			}

			exp.fulfill()
		}

		wait(for: [exp], timeout: 1.0)
		return receivedError
	}

	private func anyURL() -> URL {
		return URL(string: "https://a-url.com")!
	}

	private class URLProtocolStub: URLProtocol {
		private static var stub: Stub?
		private static var requestObserver: ((URLRequest) -> Void)?

		struct Stub {
			let data: Data?
			let response: URLResponse?
			let error: Error?
		}

		static func stub(data: Data?, response: URLResponse?, error: Error?) {
			stub = Stub(data: data, response: response, error: error)
		}

		static func observeRequests(_ observer: ((URLRequest) -> Void)?) {
			requestObserver = observer
		}

		static func startInterceptingRequests() {
			URLProtocol.registerClass(self)
		}

		static func stopInterceptingRequests() {
			URLProtocol.unregisterClass(self)
			stub = nil
			requestObserver = nil
		}

		override class func canInit(with request: URLRequest) -> Bool {
			requestObserver?(request)

			return true
		}

		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			return request
		}

		override func startLoading() {
			guard let stub = URLProtocolStub.stub else { return }

			if let data = stub.data {
				client?.urlProtocol(self, didLoad: data)
			}

			if let response = stub.response {
				client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			}

			if let error = stub.error {
				client?.urlProtocol(self, didFailWithError: error)
			}

			client?.urlProtocolDidFinishLoading(self)
		}

		override func stopLoading() { }
	}
}
