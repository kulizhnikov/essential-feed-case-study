//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 07.03.2023.
//

import Foundation
import UIKit
import EssentialFeed

public protocol FeedViewControllerDelegate {
	func didRequestFeedRefresh()
}

public protocol CellController {
	func view(in tableView: UITableView) -> UITableViewCell
	func preload()
	func cancelLoad()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
	public var delegate: FeedViewControllerDelegate?
	@IBOutlet private(set) public var errorView: ErrorView?

	private var loadingControllers: [IndexPath: CellController] = [:]
	
	private var tableModel: [CellController] = [] {
		didSet {
			tableView.reloadData()
		}
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		refresh()
	}

	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		tableView.sizeTableHeaderToFit()
	}

	@IBAction private func refresh() {
		delegate?.didRequestFeedRefresh()
	}

	public func display(_ cellControllers: [CellController]) {
		loadingControllers = [:]
		tableModel = cellControllers
	}

	public func display(_ viewModel: ResourceLoadingViewModel) {		
		if viewModel.isLoading {
			refreshControl?.beginRefreshing()
		} else {
			refreshControl?.endRefreshing()
		}
	}

	public func display(_ viewModel: ResourceErrorViewModel) {
		errorView?.message = viewModel.message
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

	private func cellController(forRowAt indexPath: IndexPath) -> CellController {
		let controller = tableModel[indexPath.row]
		loadingControllers[indexPath] = controller
		return controller
	}

	private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
		loadingControllers[indexPath]?.cancelLoad()
		loadingControllers[indexPath] = nil
	}
}
