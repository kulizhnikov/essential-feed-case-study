//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 12.03.2023.
//

import Foundation
import EssentialFeed

struct FeedImageViewModel<Image> {
	let description: String?
	let location: String?
	let image: Image?
	let isLoading: Bool
	let shouldRetry: Bool

	var hasLocation: Bool {
		location != nil
	}
}
