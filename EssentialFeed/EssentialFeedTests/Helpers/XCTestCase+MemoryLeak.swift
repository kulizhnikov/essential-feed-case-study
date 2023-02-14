//
//  File.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 11.02.2023.
//

import Foundation
import XCTest

extension XCTestCase {
	func trackForMemoryLeaks(
		_ instance: AnyObject,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(
				instance,
				"Instance should have been deallocated. Potential memory leak",
				file: file,
				line: line
			)
		}
	}
}
