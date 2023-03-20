//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Dmitry Kulizhnikov on 20.03.2023.
//

import Foundation
import EssentialFeed

public final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {

	private let primary: FeedImageDataLoader
	private let fallback: FeedImageDataLoader

	public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
		self.primary = primary
		self.fallback = fallback
	}

	private class TaskWrapper: FeedImageDataLoaderTask {
		var wrapped: FeedImageDataLoaderTask?

		func cancel() {
			wrapped?.cancel()
		}
	}

	public func loadImageData(
		from url: URL,
		completion: @escaping (FeedImageDataLoader.Result) -> Void
	) -> EssentialFeed.FeedImageDataLoaderTask {
		let task = TaskWrapper()

		task.wrapped = primary.loadImageData(from: url) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success:
				completion(result)

			case .failure:
				task.wrapped = self.fallback.loadImageData(from: url, completion: completion)
			}
		}

		return task
	}
}
