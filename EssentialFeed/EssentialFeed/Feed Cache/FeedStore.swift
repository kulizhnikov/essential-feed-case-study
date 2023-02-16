//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Dmitry Kulizhnikov on 16.02.2023.
//

import Foundation

public enum RetrieveCachedFeedResult {
	case empy
	case found(feed: [LocalFeedImage], timestamp: Date)
	case failure(Error)
}

public protocol FeedStore {
	typealias DeletionCompletion = (Error?) -> Void
	typealias InsertionCompletion = (Error?) -> Void
	typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void

	func deleteCachedFeed(completion: @escaping DeletionCompletion)
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
	func retrieve(completion: @escaping RetrievalCompletion)
}
