//
//  MembersViewModel.swift
//  SlackTeamExplorer
//
//  Created by Esteban Torres on 29/6/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

// Native Frameworks
import CoreData

// Pods
import ReactiveViewModel
import ReactiveCocoa
import ReachabilitySwift

public class MembersViewModel: RVMViewModel {
    private var members = [Member]()
    let beginLoadingSignal: RACSignal = RACSubject()
    let endLoadingSignal: RACSignal = RACSubject()
    let updateContentSignal: RACSignal = RACSubject()
    let reachability = Reachability.reachabilityForInternetConnection()
    
    var numberOfSections: Int {
        get { return 1 }
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return self.members.count
    }
    
    func memberAtIndexPath(indexPath: NSIndexPath) -> Member {
        return self.members[indexPath.item]
    }
    
    override init() {
        super.init()
        
        reachability.startNotifier()
        self.didBecomeActiveSignal.subscribeNext { [unowned self] active in
            self.active = false
            // Notify caller that network request is about to begin
            if let beginSignal = self.beginLoadingSignal as? RACSubject { beginSignal.sendNext(nil) }
        
            // Check if we have connectivity or not and retrieve the data depending
            // on this.
            if self.reachability.isReachable() {
                self.loadDataFromWeb()
            } else {
                self.loadDataFromDB()
            }
        }
    }
    
    // MARK: - Internal Helpers
    
    /**
    Executes a REST request to Slack's API retrieving all the members of the team associated to the
    provided auth token.
    
    Once successfully retrieved the data checks for existing members in the DB and only inserts the
    new ones.
    
    Assigns a union of both lists as `self.members` for later usage.
    */
    internal func loadDataFromWeb() {
        SlackProvider.request(.TeamUsersList) { (data, status, response, error) -> () in
            // Notify caller that network request ended
            if let endSignal = self.endLoadingSignal as? RACSubject { endSignal.sendNext(nil) }
            
            // Check if there was a network error, and if so notify back and cancel processing
            // data.
            if let err = error where err.code != 0 {
                if let updateSignal = self.updateContentSignal as? RACSubject {
                    updateSignal.sendError(err)
                }
                
                return
            }
            
            // Parse data
            if let data = data {
                var localError: NSError?
                if let json: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &localError) {
                    if let members = json["members"] as? Array<Dictionary<NSObject, AnyObject>>,
                        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
                        context = appDelegate.managedObjectContext {
                            // Map the array of dictionaries into Member models removing possible `nil`s.
                            self.findOrCreate(members: members)
                            
                            // Report back the new data.
                            if let updateSignal = self.updateContentSignal as? RACSubject {
                                updateSignal.sendNext(self.members)
                            }
                    }
                } else {
                    if let updateSignal = self.updateContentSignal as? RACSubject {
                        updateSignal.sendError(localError)
                    }
                }
            }
        }
    }
    
    /**
    Retrieves the list of members from the team associated to the auth token previously retrieved
    from the Web.
    
    If no local data is found (meaning we never ran the app connected to the internet before) we 
    would have an empty set of data.
    */
    internal func loadDataFromDB() {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
            context = appDelegate.managedObjectContext {
                let fetch = NSFetchRequest(entityName: "Member")
                var innerError: NSError?
                if let currentMembers = context.executeFetchRequest(fetch, error: &innerError) as? Array<Member> {
                    // Notify caller that network request ended
                    if let endSignal = self.endLoadingSignal as? RACSubject { endSignal.sendNext(nil) }
                    
                    // Check if there was a network error, and if so notify back and cancel processing
                    // data.
                    if let err = innerError where err.code != 0 {
                        if let updateSignal = self.updateContentSignal as? RACSubject {
                            updateSignal.sendError(err)
                        }
                        
                        return
                    }
                    
                    self.members = currentMembers
                    
                    // Report back the new data.
                    if let updateSignal = self.updateContentSignal as? RACSubject {
                        updateSignal.sendNext(self.members)
                    }
                } else {
                    if let updateSignal = self.updateContentSignal as? RACSubject {
                        let err = NSError(domain: "es.estebantorr.SlackTeamExplorer.MembersViewModel",
                            code: -667,
                            userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve `Member` models from the database"])
                        updateSignal.sendError(err)
                    }
                }
        }
    }
    
    /**
    Following Apple's suggestions ( https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdImporting.html )
    we try to match existing members in one single fetch and then only insert missing records from the DB.
    
    For the sake's of this demo we are not updating matching data and only fetching to insert missing records.
    */
    internal func findOrCreate(#members: Array<Dictionary<NSObject, AnyObject>>) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
            context = appDelegate.managedObjectContext {
                var membersArray = Array<Member>()
                
                // Extract & sort the ids of the JSON members
                let sortedMembers = members.map{ $0["id"] as! String }.sorted{ $0 < $1 }
                
                // Fetch all the existing members that match the ids provided
                var error: NSError?
                let fetchRequest = NSFetchRequest(entityName: "Member")
                fetchRequest.predicate = NSPredicate(format: "(membersIdentifier IN %@)", sortedMembers)
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "membersIdentifier", ascending: true)]
                if let matchingMembers = context.executeFetchRequest(fetchRequest, error: &error) as? Array<Member> {
                    membersArray += matchingMembers
                    
                    let fetchedIds = matchingMembers.map { $0.membersIdentifier }.sorted{ $0 < $1 }.map{ $0! }
                    // We have all the matching IDs, now filter the data that should be inserted
                    let predicate = NSPredicate(format: "NOT (SELF[\"id\"] IN %@)", fetchedIds)
                    if let memberIDsToInsert = (members as NSArray).filteredArrayUsingPredicate(predicate) as? Array<Dictionary<String, AnyObject>> {
                        // Map the data not present in the DB into `Member` objects
                        let membersToInsert = memberIDsToInsert.map { Member.memberInContext(context, json: $0) }.filter{ $0 != nil }.map{ $0! }
                        membersArray += membersToInsert
                    }
                } else {
                    let newMembers = members.map { Member.memberInContext(context, json: $0) }.filter{ $0 != nil }.map{ $0! }
                    membersArray += newMembers
                }
                
                self.members = membersArray
                
                dispatch_async(dispatch_get_main_queue()) {
                    appDelegate.saveContext()
                }
        }
    }
}
