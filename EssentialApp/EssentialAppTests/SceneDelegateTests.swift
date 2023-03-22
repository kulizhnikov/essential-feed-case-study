//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Dmitry Kulizhnikov on 22.03.2023.
//

import XCTest
import EssentialFeediOS
@testable import EssentialApp

final class SceneDelegateTests: XCTestCase {

	func test_sceneWillConnectTo_configuresRootViewController() {
		let sut = SceneDelegate()
		sut.window = UIWindow()

		sut.configureWindow()

		let root = sut.window?.rootViewController
		let rootNavigator = root as? UINavigationController
		let topController = rootNavigator?.topViewController

		XCTAssertNotNil(rootNavigator, "Expected a navigation controller as a root, got \(String(describing: root)) instead")
		XCTAssertTrue(topController is FeedViewController, "Expected a feed view controller as top view controller, got \(String(describing: topController)) instead")
	}

}
