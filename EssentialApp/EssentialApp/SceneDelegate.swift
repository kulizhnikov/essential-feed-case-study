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
		let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
		let localImageLoader = LocalFeedImageDataLoader(store: store)

		let feedViewController = UINavigationController(
			rootViewController: FeedUIComposer.feedComposedWith(
				feedLoader: makeRemoteFeedLoaderWithLocalFallback,
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

	private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
		let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!

		let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)

		return remoteFeedLoader
			.loadPublisher()
			.caching(to: localFeedLoader)
			.fallback(to: localFeedLoader.loadPublisher)
	}


}

public extension FeedLoader {
	typealias Publisher = AnyPublisher<[FeedImage], Error>

	func loadPublisher() -> Publisher {
		Deferred {
			Future(self.load)
		}
		.eraseToAnyPublisher()
	}
}

extension Publisher where Output == [FeedImage] {
	func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
		handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
	}
}

private extension FeedCache {
	func saveIgnoringResult(_ feed: [FeedImage]) {
		save(feed) { _ in }
	}
}

extension Publisher {
	func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
		self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
	}
}

extension Publisher {
	func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
		receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
	}
}

extension DispatchQueue {

	static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
		ImmediateWhenOnMainQueueScheduler()
	}

	struct ImmediateWhenOnMainQueueScheduler: Scheduler {
		typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
		typealias SchedulerOptions = DispatchQueue.SchedulerOptions

		var now: DispatchQueue.SchedulerTimeType {
			DispatchQueue.main.now
		}

		var minimumTolerance: DispatchQueue.SchedulerTimeType.Stride {
			DispatchQueue.main.minimumTolerance
		}

		func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
			guard Thread.isMainThread else {
				return DispatchQueue.main.schedule(options: options, action)
			}

			action()
		}

		func schedule(after date: DispatchQueue.SchedulerTimeType, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
			DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
		}

		func schedule(after date: DispatchQueue.SchedulerTimeType, interval: DispatchQueue.SchedulerTimeType.Stride, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
			DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
		}

	}
}
