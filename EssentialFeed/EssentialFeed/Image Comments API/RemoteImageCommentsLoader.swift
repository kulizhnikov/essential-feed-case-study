//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Dmitry Kulizhnikov on 26.03.2023.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
	convenience init(url: URL, client: HTTPClient) {
		self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
	}
}
