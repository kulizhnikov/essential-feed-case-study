//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Dmitry Kulizhnikov on 06.02.2023.
//

import Foundation

struct FeedItem {
	let id: UUID
	let description: String?
	let location: String?
	let imageURL: URL
}
