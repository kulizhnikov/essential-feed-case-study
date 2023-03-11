//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 08.03.2023.
//

import UIKit

final class FeedRefreshViewController: NSObject {
	private(set) lazy var view: UIRefreshControl = {
		let view = UIRefreshControl()
		bind(view)

		return view
	}()

	private let viewModel: FeedViewModel

	init(viewModel: FeedViewModel) {
		self.viewModel = viewModel
	}

	@objc func refresh() {
		viewModel.loadFeed()
	}

	private func bind(_ view: UIRefreshControl) {
		view.addTarget(self, action: #selector(refresh), for: .valueChanged)

		viewModel.onChange = { [weak self] viewModel in
			if viewModel.isLoading {
				self?.view.beginRefreshing()
			} else {
				self?.view.endRefreshing()
			}
		}
	}
}
