//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 26.03.2023.
//

import Foundation

extension HTTPURLResponse {
	convenience init(statusCode: Int) {
		self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
	}
}
