//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 12.03.2023.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
	private let feedLoader: FeedLoader

	init(feedLoader: FeedLoader) {
		self.feedLoader = feedLoader
	}

	private(set) var isLoading = false {
		didSet {
			onChange?(self)
		}
	}

	var onChange: ((FeedViewModel) -> Void)?
	var onFeedLoad: (([FeedImage]) -> Void)?

	func loadFeed() {
		isLoading = true
		feedLoader.load() { [weak self] result in
			if let feed = try? result.get() {
				self?.onFeedLoad?(feed)
			}
			self?.isLoading = false
		}
	}
}
