//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 22.03.2023.
//

import Foundation
import EssentialFeed
import UIKit

final class WeakRefVirtualProxy<T: AnyObject> {
	private weak var object: T?

	init(_ object: T) {
		self.object = object
	}
}

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
	func display(_ viewModel: ResourceLoadingViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
	func display(_ model: FeedImageViewModel<UIImage>) {
		object?.display(model)
	}
}

extension WeakRefVirtualProxy: ResourceErrorView where T: ResourceErrorView {
	func display(_ viewModel: ResourceErrorViewModel) {
		object?.display(viewModel)
	}
}
