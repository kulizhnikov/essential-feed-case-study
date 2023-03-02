//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 03.03.2023.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
	func assertThatInsertHasNoSideEffectsOnFailure(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		insert((uniqueImageFeed().local, Date()), to: sut)

		expect(sut, toRetrieve: .empty, file: file, line: line)
	}

	func assertThatInsertDeliversFailureOnInsertionError(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
		
		XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
	}
}
