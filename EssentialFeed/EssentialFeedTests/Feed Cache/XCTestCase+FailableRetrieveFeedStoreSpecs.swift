//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 03.03.2023.
//

import XCTest
import EssentialFeed

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
	func assertThatRetriveHasNoSideEffectsOnFailure(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
	}

	func assertThatRetriveDeliversFailureOnRetrievalError(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
	}
}
