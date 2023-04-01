//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 22.03.2023.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import UIKit

final class FeedViewAdapter: ResourceView {
	private weak var controller: FeedViewController?
	private let imageLoader: (URL) -> FeedImageDataLoader.Publisher

	init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
		self.controller = controller
		self.imageLoader = imageLoader
	}

	func display(_ viewModel: FeedViewModel) {
		controller?.display(viewModel.feed.map { model in
			let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(loader: { [imageLoader] in
				imageLoader(model.url)
			})

			let view = FeedImageCellController(
				viewModel: FeedImagePresenter.map(model),
				delegate: adapter
			)

			adapter.presenter = LoadResourcePresenter(
				resourceView: WeakRefVirtualProxy(view),
				loadingView: WeakRefVirtualProxy(view),
				errorView: WeakRefVirtualProxy(view),
				mapper: { data in
					guard let image = UIImage.init(data: data) else {
						throw InvalidImageData()
					}

					return image
				}
			)

			return view
		})
	}
}

private struct InvalidImageData: Error { }
