//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 08.03.2023.
//

import UIKit

protocol FeedImageCellControllerDelegate {
	func didRequestImage()
	func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
	private let delegate: FeedImageCellControllerDelegate
	private lazy var cell = FeedImageCell()

	init(delegate: FeedImageCellControllerDelegate) {
		self.delegate = delegate
	}

	func view() -> UITableViewCell {
		delegate.didRequestImage()
		return cell
	}

	func cancelLoad() {
		delegate.didCancelImageRequest()
	}

	func preload() {
		delegate.didRequestImage()
	}

	func display(_ viewModel: FeedImageViewModel<UIImage>) {
		cell.locationContainer.isHidden = !viewModel.hasLocation
		cell.locationLabel.text = viewModel.location
		cell.descriptionLabel.text = viewModel.description

		cell.onRetry = delegate.didRequestImage

		cell.feedImageView.image = viewModel.image
		cell.feedImageContainer.isShimmering = viewModel.isLoading
		cell.feedImageRetryButton.isHidden = !viewModel.shouldRetry
	}
}
