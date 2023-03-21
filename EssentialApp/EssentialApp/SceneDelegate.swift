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


	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let _ = (scene as? UIWindowScene) else { return }

		let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
		let session = URLSession(configuration: .ephemeral)
		let remoteClient = URLSessionHTTPClient(session: session)
		let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
		let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)

//		let localStoreURL = NSPersistentContainer
//			.defaultDirectoryURL()
//			.appending(path: "feed-store.sqlite")
//
//		let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
//		let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
//		let localImageLoader = LocalFeedImageDataLoader(store: localStore)
//
//		let finalFeedLoader = FeedLoaderWithFallbackComposite(
//			primary: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader),
//			fallback: localFeedLoader
//		)
//
//		let finalImageLoader = FeedImageDataLoaderWithFallbackComposite(
//			primary: localImageLoader,
//			fallback: FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader, cache: localImageLoader)
//		)
		let feedViewController = FeedUIComposer.feedComposedWith(
			feedLoader: remoteFeedLoader,
			imageLoader: remoteImageLoader
		)

		window?.rootViewController = feedViewController
	}

}

