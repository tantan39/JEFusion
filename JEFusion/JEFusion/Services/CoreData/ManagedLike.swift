//
//  ManagedLike+CoreDataClass.swift
//  JEFusion
//
//  Created by Tan Tan on 6/30/22.
//
//

import Foundation
import CoreData

@objc(ManagedLike)
public class ManagedLike: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedLike> {
        return NSFetchRequest<ManagedLike>(entityName: "ManagedLike")
    }

    @NSManaged public var id: String
    @NSManaged public var isLiked: Bool
    
    var model: LikeModel {
        LikeModel(businessId: id, isLiked: isLiked)
    }
}
