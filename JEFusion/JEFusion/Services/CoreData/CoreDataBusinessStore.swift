//
//  CoreDataBusinessStore.swift
//  JEFusion
//
//  Created by Tan Tan on 6/30/22.
//

import Foundation
import CoreData
import Combine

class CoreDataBusinessStore {
    private static let modelName = "JEFusion"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataBusinessStore.self))
    
    private var container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum StoreError: Swift.Error {
        
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    init(storeURL: URL) throws {
        guard let model = CoreDataBusinessStore.model else { throw StoreError.modelNotFound }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataBusinessStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error as! Error)
        }
    }
}

extension CoreDataBusinessStore: BusinessStore {
    func insertLikeModel(_ model: LikeModel) -> AnyPublisher<Bool, Error> {
        let context = self.context
        
        return Deferred {
            Future { promise in
                context.perform {
                    let likeModel = ManagedLike(context: context)
                    likeModel.id = likeModel.id
                    likeModel.isLiked = likeModel.isLiked
                    try? context.save()
                    promise(.success(true))
                }
            }
            
        }
        .eraseToAnyPublisher()
    }
    
    func retrieveBusinessLike() -> AnyPublisher<[LikeModel], Error> {
        let context = self.context
        return Deferred {
            Future { promise in
                context.perform {
                    do {
                        let request = NSFetchRequest<ManagedLike>(entityName: ManagedLike.entity().name!)
                        let result = try context.fetch(request)
                        
                        try? context.save()
                        promise(.success(result.map {$0.model} ))
                    } catch {
                        debugPrint("Retrive data failed \(error)")
                    }
                }
            }
            
        }
        .eraseToAnyPublisher()
    }
}

extension NSPersistentContainer {
    
    static func load(name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores(completionHandler: { loadError = $1 })
        try loadError.map { throw $0 }
        
        return container
    }
}

extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle.url(forResource: name, withExtension: "momd")
            .flatMap({ NSManagedObjectModel(contentsOf: $0) })
    }
}
