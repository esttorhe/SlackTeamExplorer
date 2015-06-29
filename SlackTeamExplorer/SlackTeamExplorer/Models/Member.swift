
// Native Frameworks
import CoreData
import Foundation

/// Member `NSManagedObject` model.
@objc(Member)
class Member : NSManagedObject {
    // Basic properties
    @NSManaged var membersIdentifier: String?
    @NSManaged var realName: String?
    @NSManaged var color: String?
    @NSManaged var name: String
    
    // Timezones
    @NSManaged var tzLabel: String
    @NSManaged var tz: String
    @NSManaged var tzOffset: Int32
    
    // Customization Flags
    @NSManaged var isUltraRestricted: Bool
    @NSManaged var isOwner: Bool
    @NSManaged var isPrimaryOwner: Bool
    @NSManaged var isRestricted: Bool
    @NSManaged var has2FA: Bool
    @NSManaged var hasFiles: Bool
    @NSManaged var devared: Bool
    @NSManaged var isNot: Bool
    @NSManaged var isAdmin: Bool
    
    // Relations
    @NSManaged var profile: Profile?
    
    /**
    Inserts a new `Member` entity to the `context` provided initialized with the `json`.
    
    - :param: context   The `NSManagedObjectContext` where the new `Member` entity will be inserted.
    
    - :param: json      A `[NSObject:AnyObject?]` dictionary with the `JSON` schema used to seed the `Member` instance
    
    - :returns: A fully initialized `Member` instance with the values read from the `json` provided.
    */
    static func memberInContext(context: NSManagedObjectContext, json:[NSObject:AnyObject?]) -> Member? {
        if let member = NSEntityDescription.insertNewObjectForEntityForName("Member", inManagedObjectContext: context) as? Member {
            if let id = json["id"] as? String {
                member.membersIdentifier = id
            }
            
            if let isUltraRestricted = json["is_ultra_restricted"] as? Bool {
                member.isUltraRestricted = isUltraRestricted
            }
            
            if let realName = json["real_name"] as? String {
                member.realName = realName
            }
            
            if let isOwner = json["is_owner"] as? Bool {
                member.isOwner = isOwner
            }
            
            if let tzLabel = json["tz_label"] as? String {
                member.tzLabel = tzLabel
            }
            
            if let tz = json["tz"] as? String {
                member.tz = tz
            }
            
            if let isRestricted = json["is_restricted"] as? Bool {
                member.isRestricted = isRestricted
            }
            
            if let has2FA = json["has2fa"] as? Bool {
                member.has2FA = has2FA
            }
            
            if let hasFiles = json["has_files"] as? Bool {
                member.hasFiles = hasFiles
            }
            
            if let color = json["color"] as? String {
                member.color = color
            }
            
            if let devared = json["devared"] as? Bool {
                member.devared = devared
            }
            
            if let tzOffset = json["tz_offset"] as? Int32 {
                member.tzOffset = tzOffset
            }
            
            if let isNot = json["is_not"] as? Bool {
                member.isNot = isNot
            }
            
            if let isAdmin = json["is_admin"] as? Bool {
                member.isAdmin = isAdmin
            }
            
            if let name = json["name"] as? String {
                member.name = name
            }
            
            if let jsonProfile = json["profile"] as? Dictionary<NSObject, AnyObject> {
                member.profile = Profile.profileInContext(context, json: jsonProfile)
            }
            
            return member
        }
        
        return nil
    }
}