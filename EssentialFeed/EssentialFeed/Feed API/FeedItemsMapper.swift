//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Dmitry Kulizhnikov on 09.02.2023.
//

import Foundation

public final class FeedItemsMapper {
	private struct RemoteFeedItem: Decodable {
		internal let id: UUID
		internal let description: String?
		internal let location: String?
		internal let image: URL
	}

	private struct Root: Decodable {
		private let items: [RemoteFeedItem]

		var images: [FeedImage] {
			items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
		}
	}

	public enum Error: Swift.Error {
		case invalidData
	}

	private static let OK_200 = 200

	public static func map(_ data: Data, response: HTTPURLResponse) throws -> [FeedImage] {
		guard response.statusCode == OK_200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw Error.invalidData
		}

		return root.images
	}
}
