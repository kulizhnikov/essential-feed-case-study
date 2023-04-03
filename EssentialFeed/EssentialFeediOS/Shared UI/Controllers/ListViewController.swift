//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 07.03.2023.
//

import Foundation
import UIKit
import EssentialFeed

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
	public var onRefresh: (() -> Void)?
	private(set) public var errorView = ErrorView()
	
	private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
		.init(tableView: tableView) { (tableView, indexPath, controller) in
			controller.dataSource.tableView(tableView, cellForRowAt: indexPath)
		}
	}()

	public override func viewDidLoad() {
		super.viewDidLoad()

		dataSource.defaultRowAnimation = .fade
		tableView.dataSource = dataSource
		configureErrorView()
		refresh()
	}

	private func configureErrorView() {
		let container = UIView()
		container.backgroundColor = .clear
		container.addSubview(errorView)

		errorView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			container.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
			errorView.topAnchor.constraint(equalTo: container.topAnchor),
			container.bottomAnchor.constraint(equalTo: errorView.bottomAnchor),
		])

		tableView.tableHeaderView = container

		errorView.onHide = { [weak self] in
			self?.tableView.beginUpdates()
			self?.tableView.sizeTableHeaderToFit()
			self?.tableView.endUpdates()
		}
	}

	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		tableView.sizeTableHeaderToFit()
	}

	public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
			tableView.reloadData()
		}
	}

	@IBAction private func refresh() {
		onRefresh?()
	}

	public func display(_ cellControllers: [CellController]) {
		var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
		snapshot.appendSections([0])
		snapshot.appendItems(cellControllers, toSection: 0)
		dataSource.apply(snapshot)
	}

	public func display(_ viewModel: ResourceLoadingViewModel) {		
		if viewModel.isLoading {
			refreshControl?.beginRefreshing()
		} else {
			refreshControl?.endRefreshing()
		}
	}

	public func display(_ viewModel: ResourceErrorViewModel) {
		errorView.message = viewModel.message
	}

	public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let delegate = cellController(at: indexPath)?.delegate
		delegate?.tableView?(tableView, didSelectRowAt: indexPath)
	}

	public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let delegate = cellController(at: indexPath)?.delegate
		delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
	}

	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			let dataSourcePrefetching = cellController(at: indexPath)?.dataSourcePrefetching
			dataSourcePrefetching?.tableView(tableView, prefetchRowsAt: [indexPath])
		}
	}

	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			let dataSourcePrefetching = cellController(at: indexPath)?.dataSourcePrefetching
			dataSourcePrefetching?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
		}
	}

	private func cellController(at indexPath: IndexPath) -> CellController? {
		dataSource.itemIdentifier(for: indexPath)
	}

}
