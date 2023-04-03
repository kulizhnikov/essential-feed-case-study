//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Dmitry Kulizhnikov on 19.03.2023.
//

import UIKit
import CoreData
import EssentialFeed
import EssentialFeediOS
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?

	private lazy var httpClient: HTTPClient = {
		let session = URLSession(configuration: .ephemeral)
		let remoteClient = URLSessionHTTPClient(session: session)
		return remoteClient
	}()
	
	private lazy var store: FeedStore & FeedImageDataStore = {
		let localStoreURL = NSPersistentContainer
			.defaultDirectoryURL()
			.appending(path: "feed-store.sqlite")
		let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
		return localStore
	}()

	private lazy var localFeedLoader: LocalFeedLoader = {
		LocalFeedLoader(store: store, currentDate: Date.init)
	}()

	private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/")!

	private lazy var navigationController = UINavigationController(
		rootViewController: FeedUIComposer.feedComposedWith(
			   feedLoader: makeRemoteFeedLoaderWithLocalFallback,
			   imageLoader: makeLocalImageLoaderWithRemoteFallback,
			   selection: showComments
		   )
	   )

	convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
		self.init()

		self.httpClient = httpClient
		self.store = store
	}

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let scene = (scene as? UIWindowScene) else { return }

		window = UIWindow(windowScene: scene)
		configureWindow()
	}

	func configureWindow() {
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
	}

	func sceneWillResignActive(_ scene: UIScene) {
		localFeedLoader.validateCache { _ in }
	}

	private func showComments(for image: FeedImage) {
		let remoteURL = baseURL.appending(path: "v1/image/\(image.id)/comments")

		let commentsVC = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: remoteURL))
		navigationController.pushViewController(commentsVC, animated: true)
	}

	private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
		return { [httpClient] in
			return httpClient
				.getPublisher(url: url)
				.tryMap(ImageCommentsMapper.map)
				.eraseToAnyPublisher()
		}
	}

	private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<[FeedImage], Error> {
		let remoteURL = baseURL.appending(path: "v1/feed")

		return httpClient
			.getPublisher(url: remoteURL)
			.tryMap(FeedItemsMapper.map)
			.caching(to: localFeedLoader)
			.fallback(to: localFeedLoader.loadPublisher)
	}

	private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
		let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
		let localImageLoader = LocalFeedImageDataLoader(store: store)

		return localImageLoader
			.loadImageDataPublisher(from: url)
			.fallback(to: {
				remoteImageLoader
					.loadImageDataPublisher(from: url)
					.caching(to: localImageLoader, using: url)
			})
	}
}
