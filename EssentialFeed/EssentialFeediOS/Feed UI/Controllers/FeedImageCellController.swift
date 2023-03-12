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
	private var cell: FeedImageCell?

	init(delegate: FeedImageCellControllerDelegate) {
		self.delegate = delegate
	}

	func view(in tableView: UITableView) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") as! FeedImageCell
		self.cell = cell
		delegate.didRequestImage()
		return cell
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
		
		cell.locationContainer.isHidden = !viewModel.hasLocation
		cell.locationLabel.text = viewModel.location
		cell.descriptionLabel.text = viewModel.description

		cell.onRetry = delegate.didRequestImage

		cell.feedImageView.image = viewModel.image
		cell.feedImageContainer.isShimmering = viewModel.isLoading
		cell.feedImageRetryButton.isHidden = !viewModel.shouldRetry
	}

	private func releaseCellForReuse() {
		cell = nil
	}
}
