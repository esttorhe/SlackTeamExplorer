
// Native Frameworks
import CoreData
import Foundation

/// Profile `NSManagedObject` model.
@objc(Profile)
public class Profile: NSManagedObject {
    // Images
    @NSManaged var image24: String?
    @NSManaged var image32: String?
    @NSManaged var image48: String?
    @NSManaged var image72: String?
    @NSManaged var image192: String?
    @NSManaged var imageOriginal: String?
    
    // Name
    @NSManaged var realName: String?
    @NSManaged var realNameNormalized: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    
    // Contact
    @NSManaged var phone: String?
    @NSManaged var skype: String?
    @NSManaged var email: String?
    
    // Misc
    @NSManaged var title: String?
    
    // Relations
    @NSManaged var member: Member?
    
    /**
    Inserts a new `Profile` entity to the `context` provided initialized with the `json`.
    
    - :param: context   The `NSManagedObjectContext` where the new `Profile` entity will be inserted.
    
    - :param: json      A `[NSObject:AnyObject?]` dictionary with the `JSON` schema used to seed the `Profile` instance
    
    - :returns: A fully initialized `Profile` instance with the values read from the `json` provided.
    */
    static func profileInContext(context: NSManagedObjectContext, json: [NSObject:AnyObject?]) -> Profile? {
        if let profile = NSEntityDescription.insertNewObjectForEntityForName("Profile", inManagedObjectContext: context) as? Profile {
            // Images
            if let image24 = json["image_24"] as? String {
                profile.image24 = image24
            }
            
            if let image32 = json["image_32"] as? String {
                profile.image32 = image32
            }
            
            if let image48 = json["image_48"] as? String {
                profile.image48 = image48
            }
            
            if let image72 = json["image_72"] as? String {
                profile.image72 = image72
            }
            
            if let image192 = json["image_192"] as? String {
                profile.image192 = image192
            }
            
            if let imageOriginal = json["image_original"] as? String {
                profile.imageOriginal = imageOriginal
            }
            
            // Name
            if let realName = json["real_name"] as? String {
                profile.realName = realName
            }
            
            if let realNameNormalized = json["real_name_normalized"] as? String {
                profile.realNameNormalized = realNameNormalized
            }
            
            if let firstName = json["first_name"] as? String {
                profile.firstName = firstName
            }
            
            if let lastName = json["last_name"] as? String {
                profile.lastName = lastName
            }
            
            // Contact
            if let phone = json["phone"] as? String {
                profile.phone = phone
            }
            
            if let skype = json["skype"] as? String {
                profile.skype = skype
            }
            
            if let email = json["email"] as? String {
                profile.email = email
            }
            
            // Misc
            if let title = json["title"] as? String {
                profile.title = title
            }
            
            return profile
        }
     
        return nil
    }
}