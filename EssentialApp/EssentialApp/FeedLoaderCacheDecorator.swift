//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Dmitry Kulizhnikov on 21.03.2023.
//

import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
	private let decoratee: FeedLoader
	private let cache: FeedCache

	public init(decoratee: FeedLoader, cache: FeedCache) {
		self.decoratee = decoratee
		self.cache = cache
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		decoratee.load { [weak self] result in
			guard let self = self else { return }

			if case let .success(feed) = result {
				self.cache.saveIgnoringResult(feed)
			}

			completion(result)
		}
	}
}

private extension FeedCache {
	func saveIgnoringResult(_ feed: [FeedImage]) {
		save(feed) { _ in }
	}
}
