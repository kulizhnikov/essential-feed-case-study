//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Dmitry Kulizhnikov on 26.03.2023.
//

import Foundation

internal final class ImageCommentsMapper {
	private struct Root: Decodable {
		let items: [RemoteFeedItem]
	}

	private static let OK_200 = 200

	internal static func map(_ data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItem] {
		guard response.statusCode == OK_200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteImageCommentsLoader.Error.invalidData
		}

		return root.items
	}
}
