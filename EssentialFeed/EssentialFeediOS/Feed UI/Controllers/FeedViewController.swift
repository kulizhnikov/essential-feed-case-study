//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 07.03.2023.
//

import UIKit

protocol FeedViewControllerDelegate {
	func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView {
	var delegate: FeedViewControllerDelegate?
	
	var tableModel: [FeedImageCellController] = [] {
		didSet {
			tableView.reloadData()
		}
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		refresh()
	}

	@IBAction private func refresh() {
		delegate?.didRequestFeedRefresh()
	}

	func display(_ viewModel: FeedLoadingViewModel) {
		if viewModel.isLoading {
			refreshControl?.beginRefreshing()
		} else {
			refreshControl?.endRefreshing()
		}
	}

	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}

	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellController = cellController(forRowAt: indexPath)
		return cellController.view(in: tableView)
	}

	public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cancelCellControllerLoad(forRowAt: indexPath)
	}

	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			let cellController = cellController(forRowAt: indexPath)
			cellController.preload()
		}
	}

	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			cancelCellControllerLoad(forRowAt: indexPath)
		}
	}

	private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
		return tableModel[indexPath.row]
	}

	private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
		cellController(forRowAt: indexPath).cancelLoad()
	}
}
