//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 03.03.2023.
//

import XCTest
import EssentialFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
	func assertThatDeleteHasNoSideEffectsOnFailure(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		deleteCache(from: sut)

		expect(sut, toRetrieve: .success(.none), file: file, line: line)
	}

	func assertThatDeleteDeliversFailureOnDeletionError(
		on sut: FeedStore,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let deletionError = deleteCache(from: sut)

		XCTAssertNotNil(deletionError, "Expected error on deletion for no access directory", file: file, line: line)
	}
}
