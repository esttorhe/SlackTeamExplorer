
// Native Frameworks
import CoreData
import Foundation

/// Profile `NSManagedObject` model.
@objc(Profile)
public class Profile: NSManagedObject {
    // Images
    @NSManaged public var image24: String?
    @NSManaged public var image32: String?
    @NSManaged public var image48: String?
    @NSManaged public var image72: String?
    @NSManaged public var image192: String?
    @NSManaged public var imageOriginal: String?
    
    // Name
    @NSManaged public var realName: String?
    @NSManaged public var realNameNormalized: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    
    // Contact
    @NSManaged public var phone: String?
    @NSManaged public var skype: String?
    @NSManaged public var email: String?
    
    // Misc
    @NSManaged public var title: String?
    
    // Relations
    @NSManaged public var member: Member?
    
    // Computed Variables
    public var fallBackImageURL: NSURL? {
        get {
            // SDWebImage sometimes fails to render the Gravatar URL
            // hence we need to extract the underlying URL in order to use it.
            // Gravatar URL ->
            // e.g.: https://secure.gravatar.com/avatar/bbbca62a1ddf20311d32c1bd5bcc5d90.jpg?s=192&d=https://slack.global.ssl.fastly.net/3654/img/avatars/ava_0003.png
            if let strURL = self.image192,
                url = NSURL(string: strURL),
                urlComp = NSURLComponents(URL: url, resolvingAgainstBaseURL: false), items = urlComp.queryItems as? [NSURLQueryItem], urlStr = (items.filter { element -> Bool in
                return element.name == "d" // Only filter the «d» query parameter
                }.map { $0.value }.first), realStr = urlStr {
                    return NSURL(string: realStr)! // We successfully unwrapped the url from the «d» query parameter
            }
            
            return nil
        }
    }
    
    /**
    Inserts a new `Profile` entity to the `context` provided initialized with the `json`.
    
    - :param: context   The `NSManagedObjectContext` where the new `Profile` entity will be inserted.
    
    - :param: json      A `[NSObject:AnyObject?]` dictionary with the `JSON` schema used to seed the `Profile` instance
    
    - :returns: A fully initialized `Profile` instance with the values read from the `json` provided.
    */
    public static func profileInContext(context: NSManagedObjectContext, json: [NSObject:AnyObject?]) -> Profile? {
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