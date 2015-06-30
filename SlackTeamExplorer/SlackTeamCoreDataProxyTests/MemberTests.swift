//
//  MemberTests.swift
//  SlackTeamCoreDataProxyTests
//
//  Created by Esteban Torres on 29/6/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

// Native Frameworks
import XCTest
import CoreData

// Framework to be tested
import SlackTeamCoreDataProxy

// Pods
import OHHTTPStubs

class MemberTests: XCTestCase {
    lazy var coreDataProxy: SlackTeamCoreDataProxy = { SlackTeamCoreDataProxy() }()
    override func tearDown() {
        super.tearDown()
        
    }
    
    override func setUp() {
        super.setUp()
        coreDataProxy.useMemoryStorage = true
    }
    
    func testMembersCorrectlyParsed() {
        var error: NSError?
        if let filePath = OHPathForFile("members.json", MemberTests.self),
            data = NSData(contentsOfFile: filePath),
            json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as? Dictionary<String, AnyObject> {
            XCTAssertNotNil(json["members"], "Couldn't find `members` leaf on fixture.")
            
            if let jsonMembers = json["members"] as? Array<Dictionary<String, AnyObject>>,
                context = coreDataProxy.managedObjectContext {
                let members = jsonMembers.map { Member.memberInContext(context, json: $0) }
                
                XCTAssertEqual(members.count, jsonMembers.count, "One or more models were not successfully parsed.")
            }
        }
        
        XCTAssertNil(error, "Unable to read fixtures file.")
    }
}
