//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 07.03.2023.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
	private var refreshController: FeedRefreshViewController?
	private var imageLoader: FeedImageDataLoader?
	private var tableModel: [FeedImage] = [] {
		didSet {
			tableView.reloadData()
		}
	}
	private var cellControllers: [IndexPath: FeedImageCellController] = [:]

	public convenience init(
		feedLoader: FeedLoader,
		imageLoader: FeedImageDataLoader
	) {
		self.init()

		self.refreshController = FeedRefreshViewController(feedLoader: feedLoader)
		self.imageLoader = imageLoader
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		refreshControl = refreshController?.view
		refreshController?.onRefresh = { [weak self] feed in
			self?.tableModel = feed
		}
		tableView.prefetchDataSource = self

		refreshController?.refresh()
	}

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}

	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellController = cellController(forRowAt: indexPath)
		return cellController.view()
	}

	public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		removeCellController(forRowAt: indexPath)
	}

	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			let cellController = cellController(forRowAt: indexPath)
			cellController.preload()
		}
	}

	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			removeCellController(forRowAt: indexPath)
		}
	}

	private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
		let cellModel = tableModel[indexPath.row]
		let cellController = FeedImageCellController(model: cellModel, imageLoader: imageLoader!)
		cellControllers[indexPath] = cellController

		return cellController
	}

	private func removeCellController(forRowAt indexPath: IndexPath) {
		cellControllers[indexPath] = nil
	}
}