//
//  SlackAPI.swift
//  SlackTeamExplorer
//
//  Created by Esteban Torres on 29/6/15.
//  Copyright (c) 2015 Esteban Torres. All rights reserved.
//

// Native Frameworks
import Foundation

// Pods
import Moya
import Keys

// MARK: - Provider setup

let SlackProvider = MoyaProvider<Slack>()

// MARK: - Provider support

private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
}

public enum Slack {
    case TeamUsersList
}

extension Slack : MoyaTarget {
    public var baseURL: NSURL { return NSURL(string: "https://slack.com/api")! }
    public var path: String {
        switch self {
        case .TeamUsersList:
            return "/users.list"
        }
    }
    
    public var method: Moya.Method {
        return .GET
    }
    
    public var parameters: [String: AnyObject] {
        switch self {
        case .TeamUsersList:
            let keys = SlackTeamExplorerKeys()
            
            return ["token": keys.slackToken()]
        default:
            return [:]
        }
    }
    
    public var sampleData: NSData {
        switch self {
        case .TeamUsersList:
            return "{\"ok\": true,\"members\": [{\"id\": \"U023BECGF\",\"name\": \"bobby\",\"deleted\": false,\"color\": \"9f69e7\",\"profile\": {\"first_name\": \"Bobby\",\"last_name\": \"Tables\",\"real_name\": \"Bobby Tables\",\"email\": \"bobby@slack.com\",\"skype\": \"my-skype-name\",\"phone\": \"+1 (123) 456 7890\",},\"is_admin\": true,\"is_owner\": true,\"has_2fa\": false,\"has_files\": true}]}".dataUsingEncoding(NSUTF8StringEncoding)!
        }
    }
}

public func url(route: MoyaTarget) -> String {
    return route.baseURL.URLByAppendingPathComponent(route.path).absoluteString!
}