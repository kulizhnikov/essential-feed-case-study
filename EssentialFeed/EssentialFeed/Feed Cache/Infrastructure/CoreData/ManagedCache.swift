//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Dmitry Kulizhnikov on 04.03.2023.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet

	var localFeed: [LocalFeedImage] {
		feed
			.compactMap { $0 as? ManagedFeedImage }
			.map { $0.local }
	}

	static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
		let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
		request.returnsObjectsAsFaults = false
		return try context.fetch(request).first
	}

	static func deleteIfAny(in context: NSManagedObjectContext) throws {
		guard let cache = try find(in: context) else { return }

		context.delete(cache)
	}
}
