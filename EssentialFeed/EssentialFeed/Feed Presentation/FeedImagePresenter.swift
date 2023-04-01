//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Dmitry Kulizhnikov on 12.03.2023.
//

import Foundation

public final class FeedImagePresenter {
	public static func map(_ image: FeedImage) -> FeedImageViewModel {
		FeedImageViewModel(
			description: image.description,
			location: image.location
		)

	}
}
