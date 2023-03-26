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
		let feedViewController = UINavigationController(
			rootViewController: FeedUIComposer.feedComposedWith(
				feedLoader: makeRemoteFeedLoaderWithLocalFallback,
				imageLoader: makeLocalImageLoaderWithRemoteFallback
			)
		)

		window?.rootViewController = feedViewController

		window?.makeKeyAndVisible()
	}

	func sceneWillResignActive(_ scene: UIScene) {
		localFeedLoader.validateCache { _ in }
	}

	private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
		let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!

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

extension RemoteLoader: FeedLoader where Resource == [FeedImage] { }
