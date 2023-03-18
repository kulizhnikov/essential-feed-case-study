//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Dmitry Kulizhnikov on 19.03.2023.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?


	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let _ = (scene as? UIWindowScene) else { return }

		let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
		let session = URLSession(configuration: .ephemeral)
		let client = URLSessionHTTPClient(session: session)
		let feedLoader = RemoteFeedLoader(url: remoteURL, client: client)
		let imageLoader = RemoteFeedImageDataLoader(client: client)

		let feedViewController = FeedUIComposer.feedComposedWith(
			feedLoader: feedLoader,
			imageLoader: imageLoader
		)

		window?.rootViewController = feedViewController
	}

}

