//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Dmitry Kulizhnikov on 22.03.2023.
//

import EssentialFeed

public class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
	private let decoratee: FeedImageDataLoader
	private let cache: FeedImageDataCache

	public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
		self.decoratee = decoratee
		self.cache = cache
	}

	public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		return decoratee.loadImageData(from: url) { [weak self] result in
			guard let self = self else { return }

			if case let .success(data) = result {
				self.cache.save(data, for: url) { _ in }
			}

			completion(result)
		}
	}
}
