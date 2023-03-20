//
//  fds.swift
//  EssentialApp
//
//  Created by Dmitry Kulizhnikov on 20.03.2023.
//

import Foundation
import EssentialFeed

public class FeedLoaderWithFallbackComposite: FeedLoader {
	private let primary: FeedLoader
	private let fallback: FeedLoader

	public init(primary: FeedLoader, fallback: FeedLoader) {
		self.primary = primary
		self.fallback = fallback
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		primary.load() { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success:
				completion(result)

			case .failure:
				self.fallback.load(completion: completion)
			}
		}
	}
}
