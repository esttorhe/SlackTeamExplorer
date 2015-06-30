//
//  ProfileTests.swift
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

class ProfileTests: XCTestCase {
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
        if let filePath = OHPathForFile("members.json", ProfileTests.self),
            data = NSData(contentsOfFile: filePath),
            json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &error) as? Dictionary<String, AnyObject> {
            XCTAssertNotNil(json["members"], "Couldn't find `members` leaf on fixture.")
            XCTAssertNotNil(json["members"]![0]!["profile"], "Couldn't find `profile` leaf on `members` fixture.")
            
            if let jsonMembers = json["members"] as? Array<Dictionary<String, AnyObject>>,
                jsonProfile = json["members"]!["profile"] as? Dictionary<String, AnyObject>,
                context = coreDataProxy.managedObjectContext {
                let profile = Profile.profileInContext(context, json: jsonProfile)
                XCTAssertNotNil(profile, "Unable to successfully parse the `JSON` to a valid `Profile` instance.")
            }
        }
        
        XCTAssertNil(error, "Unable to read fixtures file.")
    }
}
