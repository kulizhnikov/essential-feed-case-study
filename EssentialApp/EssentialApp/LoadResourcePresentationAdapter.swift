//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 22.03.2023.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
	private let loader: () -> AnyPublisher<Resource, Error>
	private var cancellable: Cancellable?
	var presenter: LoadResourcePresenter<Resource, View>?

	init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
		self.loader = loader
	}

	func loadResource() {
		presenter?.didStartLoading()

		cancellable = loader().sink(receiveCompletion: { [weak self] completion in
			switch completion {
			case .finished: break

			case let .failure(error):
				self?.presenter?.didFinishLoading(with: error)
			}
		}, receiveValue: { [weak self] resource in
			self?.presenter?.didFinishLoading(with: resource)
		})

	}
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
	func didRequestImage() {
		loadResource()
	}
	
	func didCancelImageRequest() {
		cancellable?.cancel()
		cancellable = nil
	}
}
