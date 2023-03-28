//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Dmitry Kulizhnikov on 27.03.2023.
//

import Foundation

public protocol ResourceView {
	associatedtype ResourceViewModel

	func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
	public typealias Mapper = (Resource) -> View.ResourceViewModel

	private let resourceView: View
	private let loadingView: ResourceLoadingView
	private let errorView: ResourceErrorView
	private let mapper: Mapper

	public static var loadError: String {
		return NSLocalizedString(
			"GENERIC_CONNECTION_ERROR",
			tableName: "Shared",
			bundle: Bundle(for: Self.self),
			comment: "Error message displayed when we can't load the resource from the server"
		)
	}

	public init(resourceView: View, loadingView: ResourceLoadingView, errorView: ResourceErrorView, mapper: @escaping Mapper) {
		self.resourceView = resourceView
		self.loadingView = loadingView
		self.errorView = errorView
		self.mapper = mapper
	}

	public func didStartLoading() {
		errorView.display(.noError)
		loadingView.display(ResourceLoadingViewModel(isLoading: true))
	}

	public func didFinishLoading(with resource: Resource) {
		resourceView.display(mapper(resource))
		loadingView.display(ResourceLoadingViewModel(isLoading: false))
	}

	public func didFinishLoading(with error: Error) {
		errorView.display(.error(message: Self.loadError))
		loadingView.display(ResourceLoadingViewModel(isLoading: false))
	}
}
