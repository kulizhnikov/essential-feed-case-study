//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Dmitry Kulizhnikov on 03.03.2023.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
	private let container: NSPersistentContainer
	private let context: NSManagedObjectContext

	public init(storeURL: URL, bundle: Bundle = .main) throws {
		container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
		context = container.newBackgroundContext()
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		perform { context in
			do {
				if let cache = try ManagedCache.find(in: context) {
					completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
				} else {
					completion(.empty)
				}
			} catch {
				completion(.failure(error))
			}
		}
	}

	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context in
			do {
				try ManagedCache.deleteIfAny(in: context)
				
				let managedCache = ManagedCache(context: context)
				managedCache.timestamp = timestamp
				managedCache.feed = ManagedFeedImage.images(from: feed, in: context)

				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform { context in
			do {
				try ManagedCache.deleteIfAny(in: context)
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}

	// MARK: - Helpers
	private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
		let context = context
		context.perform {
			action(context)
		}
	}

}
