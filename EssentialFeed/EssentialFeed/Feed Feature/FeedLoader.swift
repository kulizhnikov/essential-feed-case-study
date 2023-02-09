//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Dmitry Kulizhnikov on 06.02.2023.
//

import Foundation

public typealias LoadFeedResult<Error: Swift.Error> = Result<[FeedItem], Error>

protocol FeedLoader {
	associatedtype Error: Swift.Error

	func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
