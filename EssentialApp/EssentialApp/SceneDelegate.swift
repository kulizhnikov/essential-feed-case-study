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
		let remoteClient = makeRemoteClient()
		let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
		let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)

		let localStoreURL = NSPersistentContainer
			.defaultDirectoryURL()
			.appending(path: "feed-store.sqlite")

		let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
		let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
		let localImageLoader = LocalFeedImageDataLoader(store: localStore)

		let feedViewController = FeedUIComposer.feedComposedWith(
			feedLoader: FeedLoaderWithFallbackComposite(
				primary: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader),
				fallback: localFeedLoader
			),
			imageLoader: FeedImageDataLoaderWithFallbackComposite(
				primary: localImageLoader,
				fallback: FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader, cache: localImageLoader)
			)
		)

		window?.rootViewController = feedViewController
	}

	private func makeRemoteClient() -> HTTPClient {
		switch UserDefaults.standard.string(forKey: "connectivity") {
		case "offline":
			return AlwaysFailingHTTPClient()

		default:
			let session = URLSession(configuration: .ephemeral)
			let remoteClient = URLSessionHTTPClient(session: session)
			return remoteClient
		}
	}
}

private class AlwaysFailingHTTPClient: HTTPClient {
	private class Task: HTTPClientTask {
		func cancel() { }
	}

	func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> EssentialFeed.HTTPClientTask {
		completion(.failure(NSError(domain: "offline", code: 0)))
		return Task()
	}
}
