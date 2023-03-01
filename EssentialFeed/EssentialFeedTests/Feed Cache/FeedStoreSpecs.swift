//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Dmitry Kulizhnikov on 02.03.2023.
//

import Foundation

protocol FeedStoreSpecs {
	func test_retrieve_deliversEmptyOnEmptyCache()
	func test_retrieve_hasNoSideEffectsOnEmptyCache()
	func test_retrieve_deliversFoundValuesOnNonEmptyCache()
	func test_retrieve_hasNoSideEffectsOnNonEmptyCache()

	func test_insert_overridePreviouslyInsertedCacheValues()

	func test_delete_hasNoSideEffectsOnEmptyCache()
	func test_delete_emptiesPreviouslyInsertedCache()

	func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
	func test_retrive_deliversFailureOnRetrievalError()
	func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
	func test_insert_deliversErrorOnInsertionError()
	func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
	func test_delete_deliversErrorOnDelitionError()
	func test_delete_hasNoSideEffectsOnDelitionError()
}

typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
