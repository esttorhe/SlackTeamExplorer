//
//  SlackTeamCoredataProxy_Test.swift
//  SlackTeamExplorer
//
//  Created by Esteban Torres on 30/6/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

// Native Frameworks
import CoreData

// Framework to be tested
import SlackTeamCoreDataProxy

extension SlackTeamCoreDataProxy {
    func testManagedContext() -> NSManagedObjectContext? {
        let managedObjectModel = self.managedObjectModel
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)
        
        let managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }
}