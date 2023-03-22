//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Dmitry Kulizhnikov on 08.03.2023.
//

import UIKit

extension UIRefreshControl {
	func simulatePullToRefresh() {
		allTargets.forEach { target in
			actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
				(target as NSObject).perform(Selector(action))
			}
		}
	}
}
