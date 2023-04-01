//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 12.03.2023.
//

import Foundation

public struct FeedImageViewModel {
	public let description: String?
	public let location: String?

	public var hasLocation: Bool {
		location != nil
	}
}
