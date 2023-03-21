//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Dmitry Kulizhnikov on 21.03.2023.
//

import Foundation
import EssentialFeed

class FeedLoaderStub: FeedLoader {
	private let result: FeedLoader.Result

	init(result: FeedLoader.Result) {
		self.result = result
	}

	func load(completion: @escaping (FeedLoader.Result) -> Void) {
		completion(result)
	}
}
