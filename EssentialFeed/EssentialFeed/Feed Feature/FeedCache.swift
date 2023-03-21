//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Dmitry Kulizhnikov on 21.03.2023.
//

public protocol FeedCache {
	typealias SaveResult = Result<Void, Error>

	func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
