//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Dmitry Kulizhnikov on 16.02.2023.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
	internal let id: UUID
	internal let description: String?
	internal let location: String?
	internal let image: URL
}
