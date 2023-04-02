//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Dmitry Kulizhnikov on 03.04.2023.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class CommentsUIComposer {
	private init() { }

	public static func commentsComposedWith(
		commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>
	) -> ListViewController {
		let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(
			loader: { commentsLoader().dispatchOnMainQueue() }
		)

		let feedController = ListViewController.makeWith(title: FeedPresenter.title)
		feedController.onRefresh = presentationAdapter.loadResource

		let presenter = LoadResourcePresenter(
			resourceView: FeedViewAdapter(
				controller: feedController,
				imageLoader: { _ in Empty<Data, Error>().eraseToAnyPublisher() }
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

