//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Dmitry Kulizhnikov on 08.03.2023.
//

import UIKit

extension UIButton {
	func simulateTap() {
		allTargets.forEach { target in
			actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach { action in
				(target as NSObject).perform(Selector(action))
			}
		}
	}
}
