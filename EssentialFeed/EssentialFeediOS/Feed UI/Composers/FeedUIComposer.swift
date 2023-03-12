//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 08.03.2023.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
	private init() { }

	public static func feedComposedWith(
		feedLoader: FeedLoader,
		imageLoader: FeedImageDataLoader
	) -> FeedViewController {
		let presenter = FeedPresenter(feedLoader: feedLoader)
		let refreshController = FeedRefreshViewController(presenter: presenter)
		let feedController = FeedViewController(refreshController: refreshController)

		presenter.loadingView = refreshController
		presenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)

		return feedController
	}
}

private final class FeedViewAdapter: FeedView {
	private weak var controller: FeedViewController?
	private let imageLoader: FeedImageDataLoader

	init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
		self.controller = controller
		self.imageLoader = imageLoader
	}

	func display(feed: [FeedImage]) {
		controller?.tableModel = feed.map { model in
			let viewModel = FeedImageViewModel(
				model: model,
				imageLoader: self.imageLoader,
				imageTransformer: UIImage.init
			)
			return FeedImageCellController(viewModel: viewModel)
		}
	}
}
