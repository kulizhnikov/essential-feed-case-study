//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 16.02.2023.
//

import Foundation

func anyNSError() -> NSError {
	NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
	return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
	return Data("any data".utf8)
}

func makeItemsJSON(_ items: [[String: Any]]) -> Data {
	let json = ["items": items]
	return try! JSONSerialization.data(withJSONObject: json)
}

extension Date {
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}

	func adding(minutes: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .minute, value: minutes, to: self)!
	}

	func adding(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}
}
