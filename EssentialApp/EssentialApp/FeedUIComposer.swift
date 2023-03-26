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
	) -> FeedViewController {
		let presentationAdapter = FeedLoaderPresentationAdapter(
			feedLoader: { feedLoader().dispatchOnMainQueue() }
		)

		let feedController = FeedViewController.makeWith(delegate: presentationAdapter, title: FeedPresenter.title)

		let presenter = FeedPresenter(
			feedView: FeedViewAdapter(
				controller: feedController,
				imageLoader: { imageLoader($0).dispatchOnMainQueue() }
			),
			loadingView: WeakRefVirtualProxy(feedController),
			errorView: WeakRefVirtualProxy(feedController)
		)
		presentationAdapter.presenter = presenter

		return feedController
	}
}

private extension FeedViewController {
	static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
		feedController.delegate = delegate
		feedController.title = title

		return feedController
	}
}
