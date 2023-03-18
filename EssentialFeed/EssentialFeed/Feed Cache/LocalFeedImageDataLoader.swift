//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Dmitry Kulizhnikov on 18.03.2023.
//

import Foundation

public final class LocalFeedImageDataLoader: FeedImageDataLoader {
	private final class Task: FeedImageDataLoaderTask {
		var completion: ((FeedImageDataLoader.Result) -> Void)?

		init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
			self.completion = completion
		}

		func complete(with result: FeedImageDataLoader.Result) {
			completion?(result)
		}

		func cancel() {
			preventFutureCompletions()
		}

		private func preventFutureCompletions() {
			completion = nil
		}
	}

	public enum Error: Swift.Error {
		case failed
		case notFound
	}

	private let store: FeedImageDataStore

	public init(store: FeedImageDataStore) {
		self.store = store
	}

	public func loadImageData(
		from url: URL,
		completion: @escaping (FeedImageDataLoader.Result) -> Void
	) -> EssentialFeed.FeedImageDataLoaderTask {
		let task = Task(completion)

		store.retrieve(dataForURL: url) { [weak self] result in
			guard self != nil else { return }

			task.complete(with: result
				.mapError { _ in Error.failed }
				.flatMap { data in
					data.map { .success($0) } ?? .failure(Error.notFound)
				})
		}
		return task
	}
}
