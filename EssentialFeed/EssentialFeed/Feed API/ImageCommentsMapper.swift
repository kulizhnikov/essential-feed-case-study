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

	internal static func map(_ data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItem] {
		guard isOK(response),
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			throw RemoteImageCommentsLoader.Error.invalidData
		}

		return root.items
	}

	private static func isOK(_ response: HTTPURLResponse) -> Bool {
		(200...299).contains(response.statusCode)
	}
}
