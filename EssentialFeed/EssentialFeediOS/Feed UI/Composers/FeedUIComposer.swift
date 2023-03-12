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
		let presenter = FeedPresenter()
		let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader, presenter: presenter)
		let refreshController = FeedRefreshViewController(loadFeed: presentationAdapter.loadFeed)
		let feedController = FeedViewController(refreshController: refreshController)

		presenter.loadingView = WeakRefVirtualProxy(refreshController)
		presenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)

		return feedController
	}
}

private final class WeakRefVirtualProxy<T: AnyObject> {
	private weak var object: T?

	init(_ object: T) {
		self.object = object
	}
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
	func display(_ viewModel: FeedLoadingViewModel) {
		object?.display(viewModel)
	}
}

private final class FeedViewAdapter: FeedView {
	private weak var controller: FeedViewController?
	private let imageLoader: FeedImageDataLoader

	init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
		self.controller = controller
		self.imageLoader = imageLoader
	}

	func display(_ viewModel: FeedViewModel) {
		controller?.tableModel = viewModel.feed.map { model in
			let viewModel = FeedImageViewModel(
				model: model,
				imageLoader: self.imageLoader,
				imageTransformer: UIImage.init
			)
			return FeedImageCellController(viewModel: viewModel)
		}
	}
}

private final class FeedLoaderPresentationAdapter {
	private let feedLoader: FeedLoader
	private let presenter: FeedPresenter

	init(feedLoader: FeedLoader, presenter: FeedPresenter) {
		self.feedLoader = feedLoader
		self.presenter = presenter
	}

	func loadFeed() {
		presenter.didStartLoadingFeed()

		feedLoader.load { [weak self] result in
			switch result {
			case let .success(feed):
				self?.presenter.didFinishLoadingFeed(with: feed)
			case let .failure(error):
				self?.presenter.didFinishLoadingFeed(with: error)
			}
		}
	}
}
