//
//  CoreDataStack.swift
//  CDTuturial
//
//  Created by shinisaru on 15/01/16.
//  Copyright © 2016 Avast. All rights reserved.
//

//
//  CoreDataStack.swift
//  WiFiFinder
//
//  Created by Jakub Kleň on 06/08/15.
//  Copyright (c) 2015 avast. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    let mainContext: NSManagedObjectContext
    private let backgroundRootContext: NSManagedObjectContext
    
    private let persistanceStoreURL: NSURL
    private let managedObjectModelURL: NSURL
    
    init(persistanceStoreURL:NSURL, managedObjectModelURL: NSURL)
    {
        self.persistanceStoreURL = persistanceStoreURL
        self.managedObjectModelURL = managedObjectModelURL
        
        backgroundRootContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        backgroundRootContext.persistentStoreCoordinator = persistentStoreCoordinator
        backgroundRootContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        mainContext.parentContext = backgroundRootContext
    }
    
    private lazy var managedObjectModel: NSManagedObjectModel = NSManagedObjectModel(contentsOfURL: self.managedObjectModelURL)!
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        var coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true,
            NSSQLitePragmasOption: ["journal_mode" : "WAL"]]
        
        do {
            try coordinator.addPersistentStoreWithType(
                NSSQLiteStoreType,
                configuration: nil,
                URL: self.persistanceStoreURL,
                options: options)
        } catch {
            fatalError("Unable to create persistent store coordinator")
        }
        
        return coordinator
    }()
    
    func createChildContext() -> NSManagedObjectContext {
        return contextWithParentContext(mainContext)
    }
    
    func saveContextAndPropagateChanges(context: NSManagedObjectContext, completion:((error:NSError?) -> Void)?)
    {
        if !context.hasChanges {
            completion?(error: nil)
            return
        }
        
        context.performBlock { [weak self] in
            var error: NSError? = nil
            
            do {
                try context.save()
            } catch let e as NSError {
                error = e
            }
            
            if nil == error {
                if let parent = context.parentContext {
                    self?.saveContextAndPropagateChanges(parent, completion: completion)
                    return
                }
            }
            
            completion?(error: error)
        }
    }
    
    private func contextWithParentContext(parentContext: NSManagedObjectContext) -> NSManagedObjectContext {
        let ctx = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        ctx.parentContext = parentContext
        return ctx
    }
}
