//
//  SlackTeamCoreDataProxy.swift
//  SlackTeamExplorer
//
//  Created by Esteban Torres on 29/6/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

// Native Frameworks
import Foundation
import CoreData

/// Shared framework that abstracts use of CoreData, ViewModels and its Models.
public class SlackTeamCoreDataProxy: NSObject {
    /// Internal class that holds access to the basic configuration of the shared code.
    public class AppConfiguration {
        /// Reads the prefix from the running bundle.
        public struct Bundle {
            public static var prefix = NSBundle.mainBundle().objectForInfoDictionaryKey("AAPLSlackExplorerBundlePrefix") as! String
        }
        
        /// Appends the required group information to the `Bundle.prefix`
        public struct ApplicationGroups {
            public static let primary = "group.\(Bundle.prefix).SlackExplorer.Data"
        }
        
        static var DatabaseName: String { get { return "SlackTeamExplorer" } }
    }
    
    public lazy var managedObjectModel: NSManagedObjectModel = {
        let proxyBundle = NSBundle(identifier: "\(AppConfiguration.Bundle.prefix).SlackTeamCoreDataProxy")
        
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = proxyBundle?.URLForResource(AppConfiguration.DatabaseName, withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOfURL: modelURL!)!
        }()
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        
        var error: NSError? = nil
        
        var sharedContainerURL: NSURL? = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(AppConfiguration.ApplicationGroups.primary)
        if let sharedContainerURL = sharedContainerURL {
            let storeURL = sharedContainerURL.URLByAppendingPathComponent("\(AppConfiguration.DatabaseName).sqlite")
            var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) == nil {
                // error handling goes here
                abort()
            }
            return coordinator
        }
        
        return nil
        }()
    
    public lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    public func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}