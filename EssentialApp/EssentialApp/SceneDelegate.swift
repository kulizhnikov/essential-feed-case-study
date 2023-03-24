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
		let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
		
		let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
		let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
		let localImageLoader = LocalFeedImageDataLoader(store: store)

		let feedViewController = UINavigationController(
			rootViewController: FeedUIComposer.feedComposedWith(
				feedLoader: FeedLoaderWithFallbackComposite(
					primary: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader),
					fallback: localFeedLoader
				),
				imageLoader: FeedImageDataLoaderWithFallbackComposite(
					primary: localImageLoader,
					fallback: FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader, cache: localImageLoader)
				)
			)
		)

		window?.rootViewController = feedViewController

		window?.makeKeyAndVisible()
	}

	func sceneWillResignActive(_ scene: UIScene) {
		localFeedLoader.validateCache { _ in }
	}
}
