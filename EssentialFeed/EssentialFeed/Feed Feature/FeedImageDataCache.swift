//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Dmitry Kulizhnikov on 22.03.2023.
//

import Foundation

public protocol FeedImageDataCache {
	typealias Result = Swift.Result<Void, Error>

	func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
