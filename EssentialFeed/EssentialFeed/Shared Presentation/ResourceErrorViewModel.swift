//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by Dmitry Kulizhnikov on 17.03.2023.
//

import Foundation

public struct ResourceErrorViewModel {
	public let message: String?

	static var noError: ResourceErrorViewModel {
		return ResourceErrorViewModel(message: nil)
	}

	static func error(message: String) -> ResourceErrorViewModel {
		ResourceErrorViewModel(message: message)
	}
}
