
// Native Frameworks
import CoreData
import Foundation

/// Member `NSManagedObject` model.
@objc(Member)
public class Member : NSManagedObject {
    // Basic properties
    @NSManaged public var membersIdentifier: String?
    @NSManaged public var realName: String?
    @NSManaged public var color: String?
    @NSManaged public var name: String
    
    // Timezones
    @NSManaged public var tzLabel: String
    @NSManaged public var tz: String
    @NSManaged public var tzOffset: Int32
    
    // Customization Flags
    @NSManaged public var isUltraRestricted: Bool
    @NSManaged public var isOwner: Bool
    @NSManaged public var isPrimaryOwner: Bool
    @NSManaged public var isRestricted: Bool
    @NSManaged public var has2FA: Bool
    @NSManaged public var hasFiles: Bool
    @NSManaged public var devared: Bool
    @NSManaged public var isNot: Bool
    @NSManaged public var isAdmin: Bool
    
    // Relations
    @NSManaged public var profile: Profile?
    
    /**
    Inserts a new `Member` entity to the `context` provided initialized with the `json`.
    
    - :param: context   The `NSManagedObjectContext` where the new `Member` entity will be inserted.
    
    - :param: json      A `[NSObject:AnyObject?]` dictionary with the `JSON` schema used to seed the `Member` instance
    
    - :returns: A fully initialized `Member` instance with the values read from the `json` provided.
    */
    public static func memberInContext(context: NSManagedObjectContext, json:[NSObject:AnyObject?]) -> Member? {
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