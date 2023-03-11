//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 08.03.2023.
//

import UIKit

final class FeedImageCellController {
	private let viewModel: FeedImageViewModel<UIImage>

	init(viewModel: FeedImageViewModel<UIImage>) {
		self.viewModel = viewModel
	}

	func view() -> UITableViewCell {
		let cell = FeedImageCell()
		bind(cell)

		viewModel.loadImageData()

		return cell
	}

	func cancelLoad() {
		viewModel.cancelImageDataLoad()
	}

	func preload() {
		viewModel.loadImageData()
	}

	private func bind(_ cell: FeedImageCell) {
		cell.locationContainer.isHidden = !viewModel.hasLocation
		cell.locationLabel.text = viewModel.location
		cell.descriptionLabel.text = viewModel.description
		cell.onRetry = viewModel.loadImageData

		viewModel.onImageLoad = { [weak cell] image in
			cell?.feedImageView.image = image
		}

		viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
			cell?.feedImageContainer.isShimmering = isLoading
		}

		viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
			cell?.feedImageRetryButton.isHidden = !shouldRetry
		}
	}
}
