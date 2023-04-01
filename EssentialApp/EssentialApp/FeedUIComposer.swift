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
		imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
	) -> ListViewController {
		let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(
			loader: { feedLoader().dispatchOnMainQueue() }
		)

		let feedController = ListViewController.makeWith(delegate: presentationAdapter, title: FeedPresenter.title)

		let presenter = LoadResourcePresenter(
			resourceView: FeedViewAdapter(
				controller: feedController,
				imageLoader: { imageLoader($0).dispatchOnMainQueue() }
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
	static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let feedController = storyboard.instantiateInitialViewController() as! ListViewController
		feedController.delegate = delegate
		feedController.title = title

		return feedController
	}
}
