//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Dmitry Kulizhnikov on 03.04.2023.
//

import XCTest
import Combine
import UIKit
import EssentialFeed
import EssentialFeediOS
import EssentialApp

final class CommentsUIIntegrationTests: FeedUIIntegrationTests {

	func test_commentsView_hasTitle() {
		let (sut, _) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.title, commentsTitle)
	}

	func test_loadCommentsActions_requestCommentsFromLoader() {
		let (sut, loader) = makeSUT()

		XCTAssertEqual(loader.loadCommentsCallCount, 0, "Exptected no loading requests before view is loaded")

		sut.loadViewIfNeeded()
		XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a load")

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(loader.loadCommentsCallCount, 3, "Exptected a third loading request once user initiates another load")
	}

	func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

		loader.completeCommentsLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

		sut.simulateUserInitiatedReload()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")

		loader.completeCommentsLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
	}

	override func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
		let image0 = makeImage(description: "a description", location: "a location")
		let image1 = makeImage(description: nil, location: "another location")
		let image2 = makeImage(description: "another description", location: nil)
		let image3 = makeImage(description: nil, location: nil)
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: [])

		loader.completeCommentsLoading(with: [image0], at: 0)
		assertThat(sut, isRendering: [image0])

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoading(with: [image0, image1, image2, image3], at: 1)
		assertThat(sut, isRendering: [image0, image1, image2, image3])
	}

	override func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
		let image0 = makeImage()
		let image1 = makeImage()
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [image0, image1], at: 0)
		assertThat(sut, isRendering: [image0, image1])

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoading(with: [], at: 1)
		assertThat(sut, isRendering: [])
	}

	override func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
		let image0 = makeImage(description: "a description", location: "a location")
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		loader.completeCommentsLoading(with: [image0], at: 0)
		assertThat(sut, isRendering: [image0])

		sut.simulateUserInitiatedReload()
		loader.completeCommentsLoadingWithError(at: 1)
		assertThat(sut, isRendering: [image0])
	}

	override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, loadError)

		sut.simulateUserInitiatedReload()
		XCTAssertEqual(sut.errorMessage, nil)
	}

	override func test_tapOnErrorView_hidesErrorMessage() {
		let (sut, loader) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertEqual(sut.errorMessage, nil)

		loader.completeCommentsLoadingWithError(at: 0)
		XCTAssertEqual(sut.errorMessage, loadError)

		sut.simulateErrorViewTap()
		XCTAssertEqual(sut.errorMessage, nil)
	}

	override func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
		let (sut, loader) = makeSUT()
		sut.loadViewIfNeeded()

		let exp = expectation(description: "Wait for background queue")
		DispatchQueue.global().async {
			loader.completeCommentsLoading(at: 0)
			exp.fulfill()
		}

		wait(for: [exp], timeout: 1.0)
	}

	// MARK: - Helpers
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: ListViewController, loader: LoaderSpy) {
		let loader = LoaderSpy()
		let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)

		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)

		return (sut, loader)
	}

	private func assertThat(
		_ sut: ListViewController,
		isRendering feed: [FeedImage],
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		sut.tableView.layoutIfNeeded()
		RunLoop.main.run(until: Date())

		guard sut.numberOfRenderedFeedImageViews() == feed.count else {
			XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews())" , file: file, line: line)
			return
		}

		for i in 0..<feed.count {
			assertThat(sut, hasViewConfiguredFor: feed[i], at: i, file: file, line: line)
		}
	}

	private func assertThat(
		_ sut: ListViewController,
		hasViewConfiguredFor image: FeedImage,
		at index: Int,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let view = sut.feedImageView(at: index)

		guard let cell = view as? FeedImageCell else {
			XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
			return
		}

		let shouldLocationBeVisible = (image.location != nil)
		XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image at \(index)", file: file, line: line)

		XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image at \(index)", file: file, line: line)

		XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image at \(index)", file: file, line: line)
	}

	private func makeImage(
		description: String? = nil,
		location: String? = nil,
		url: URL = URL(string: "http://any-url.com")!
	) -> FeedImage {
		return FeedImage(id: UUID(), description: description, location: location, url: url)
	}

	private class LoaderSpy {
		private var requests = [PassthroughSubject<[FeedImage], Error>]()

		var loadCommentsCallCount: Int {
			return requests.count
		}

		func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
			let publisher = PassthroughSubject<[FeedImage], Error>()
			requests.append(publisher)
			return publisher.eraseToAnyPublisher()
		}

		func completeCommentsLoading(with feed: [FeedImage] = [], at index: Int = 0) {
			requests[index].send(feed)
		}

		func completeCommentsLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			requests[index].send(completion: .failure(error))
		}
	}
}
