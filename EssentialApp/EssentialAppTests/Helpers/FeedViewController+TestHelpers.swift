//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Dmitry Kulizhnikov on 08.03.2023.
//

import UIKit
import EssentialFeediOS

extension ListViewController {
	func simulateUserInitiatedFeedReload() {
		refreshControl?.simulatePullToRefresh()
	}

	func simulateFeedImageViewNearVisible(at row: Int) {
		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: feedImagesSection)
		ds?.tableView(tableView, prefetchRowsAt: [index])
	}

	func simulateFeedImageViewNotNearVisible(at row: Int) {
		simulateFeedImageViewVisible(at: row)

		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: feedImagesSection)
		ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
	}

	@discardableResult
	func simulateFeedImageViewVisible(at row: Int) -> FeedImageCell? {
		return feedImageView(at: row) as? FeedImageCell
	}

	@discardableResult
	func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
		let view = simulateFeedImageViewVisible(at: row)

		let delegate = tableView.delegate
		let index = IndexPath(row: row, section: feedImagesSection)
		delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)

		return view
	}

	func simulateErrorViewTap() {
		errorView.simulateTap()
	}

	var errorMessage: String? {
		return errorView.message
	}

	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}

	func numberOfRenderedFeedImageViews() -> Int {
		return tableView.numberOfRows(inSection: feedImagesSection)
	}

	func renderedFeedImageData(at index: Int) -> Data? {
		return simulateFeedImageViewVisible(at: index)?.renderedImage
	}

	func feedImageView(at row: Int) -> UITableViewCell? {
		guard row < numberOfRenderedFeedImageViews() else {
			return nil
		}
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: feedImagesSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}

	private var feedImagesSection: Int {
		return 0
	}
}
