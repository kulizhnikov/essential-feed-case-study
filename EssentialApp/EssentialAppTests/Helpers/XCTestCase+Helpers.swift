//
//  dfs.swift
//  EssentialAppTests
//
//  Created by Dmitry Kulizhnikov on 20.03.2023.
//

import XCTest

extension XCTestCase {

	func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}

	func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
		}
	}

}
