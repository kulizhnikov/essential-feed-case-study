//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Dmitry Kulizhnikov on 20.03.2023.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
	return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
	return URL(string: "https://any-url.com")!
}

func anyData() -> Data {
	return Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
	return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "https://any-url.com")!)]
}

private class DummyView: ResourceView {
	func display(_ viewModel: Any) { }
}

var loadError: String {
	LoadResourcePresenter<Any, DummyView>.loadError
}

var feedTitle: String {
	FeedPresenter.title
}

var commentsTitle: String {
	ImageCommentsPresenter.title
}
