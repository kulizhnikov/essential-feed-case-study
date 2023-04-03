//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 08.03.2023.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
	private init() { }

	public static func feedComposedWith(
		feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
		imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
		selection: @escaping (FeedImage) -> Void = { _ in }
	) -> ListViewController {
		let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(
			loader: { feedLoader().dispatchOnMainQueue() }
		)

		let feedController = ListViewController.makeWith(title: FeedPresenter.title)
		feedController.onRefresh = presentationAdapter.loadResource

		let presenter = LoadResourcePresenter(
			resourceView: FeedViewAdapter(
				controller: feedController,
				imageLoader: { imageLoader($0).dispatchOnMainQueue() },
				selection: selection
			),
			loadingView: WeakRefVirtualProxy(feedController),
			errorView: WeakRefVirtualProxy(feedController),
			mapper: FeedPresenter.map
		)
		presentationAdapter.presenter = presenter

		return feedController
	}
}

private extension ListViewController {
	static func makeWith(title: String) -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let feedController = storyboard.instantiateInitialViewController() as! ListViewController
		feedController.title = title

		return feedController
	}
}
