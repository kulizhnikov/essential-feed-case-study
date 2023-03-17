//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 08.03.2023.
//

import UIKit
import EssentialFeed

protocol FeedImageCellControllerDelegate {
	func didRequestImage()
	func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
	private let delegate: FeedImageCellControllerDelegate
	private var cell: FeedImageCell?

	init(delegate: FeedImageCellControllerDelegate) {
		self.delegate = delegate
	}

	func view(in tableView: UITableView) -> UITableViewCell {
		cell = tableView.dequeueReusableCell()
		delegate.didRequestImage()
		return cell!
	}

	func cancelLoad() {
		releaseCellForReuse()
		delegate.didCancelImageRequest()
	}

	func preload() {
		delegate.didRequestImage()
	}

	func display(_ viewModel: FeedImageViewModel<UIImage>) {
		guard let cell else { return }

		cell.onRetry = delegate.didRequestImage
		cell.onReuse = { [weak self] in
			self?.releaseCellForReuse()
		}
		
		cell.locationContainer.isHidden = !viewModel.hasLocation
		cell.locationLabel.text = viewModel.location
		cell.descriptionLabel.text = viewModel.description
		cell.feedImageContainer.isShimmering = viewModel.isLoading
		cell.feedImageRetryButton.isHidden = !viewModel.shouldRetry

		cell.feedImageView.setImageAnimated(viewModel.image)
	}

	private func releaseCellForReuse() {
		cell = nil
	}
}


