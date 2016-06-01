//
//  Models.swift
//  DemoApp
//
//  Created by Federico Paliotta on 5/25/16.
//  Copyright © 2016 FPC. All rights reserved.
//

import Foundation
//import MapKit
import Contacts


// MARK: Location Class
class Location : NSObject
{
    let publicId: String
    let locality: String
    let region: String
    let postalCode: String
    let country: String
    
    var services: [Service]?
    
    override var description: String
    {
        var descr = "•" + locality + " " + region + ", "
                    + postalCode + " " + country + "\n"
        
        if let services = services where services.count > 0
        {
            descr += "•Services:\n"
            for s in services
            {
                descr += "\(s.description)\n"
            }
        }
        return descr
    }
    
    init(pubId: String, locality: String, region: String,
         postalCode: String, country: String, services: [Service]? = nil)
    {
        self.publicId = pubId
        self.locality = locality
        self.region = region
        self.postalCode = postalCode
        self.country = country
        self.services = services
    }
    
    convenience init?(with dict: NSDictionary)
    {
        guard let publicId: String = getVaule(dict, fieldName: "public_id")
            else { print("Error: public_id"); return nil }
        
        guard let location: String = getVaule(dict, fieldName: "locality")
            else { print("Error: locality"); return nil }
        
        guard let region: String = getVaule(dict, fieldName: "region")
            else { print("Error: region"); return nil }
        
        guard let postalCode: String = getVaule(dict, fieldName: "postal_code")
            else { print("Error: postal_code"); return nil }
        
        guard let country: String = getVaule(dict, fieldName: "country")
            else { print("Error: country"); return nil }

        var services: [Service]! = nil
        
        if let jsonServices: NSArray = getVaule(dict, fieldName: "services")
            where jsonServices.count > 0
        {
            services = [Service]()
            
            for item in jsonServices
            {
                if let dict = item as? NSDictionary
                {
                    if let service = Service(with: dict)
                    {
                        services.append(service)
                    }
                    
                }
            }
        }
        
        self.init(pubId: publicId, locality: location, region: region,
                postalCode: postalCode, country: country, services: services)
    }
}


// MARK: Service Struct
struct Service : CustomStringConvertible
{
    let platform: Platform
    let programmers: [Programmer]
    
    var description: String
    {
        var descr = "\t•Platform: " + platform.rawValue + "\n"
        
        if programmers.count > 0 {
            descr += "\t•Programmers:\n"
        }
        for p in programmers
        {
            descr += "\(p.description)\n"
        }
        
        return descr
    }
    
    init?(with dict: NSDictionary)
    {
        guard let platform = Platform(rawValue: getVaule(dict, fieldName: "platform")!)
            else { print("Error: platform"); return nil }
      
        guard let jsonProgrammers: NSArray = getVaule(dict, fieldName: "programmers")
            else { print("Error: programmers"); return nil }
        
        var programmers = [Programmer]()
        
        for item in jsonProgrammers
        {
            if let dict = item as? NSDictionary
            {
                if let programmer = Programmer(with: dict)
                {
                    programmers.append(programmer)
                }
            }
        }
        
        self.platform = platform
        self.programmers = programmers
    }
}


// MARK: Programmer Class
final class Programmer: CNMutableContact
{
    override var jobTitle: String
    {
        get { return "Programmer" }
        
        set { print("Nope! I'm a programmer!") }
    }
    
    override var description: String
    {
        let phoneDescr = (phoneNumbers.first!.value as! CNPhoneNumber).stringValue
        
        let descr = "\t\t・\(name)\n"
                  + "\t\t・Favorite color: \(favoriteColor)\n"
                  + "\t\t・Age: \(age) y.o.\n"
                  + "\t\t・Weight: \(weight)\n"
                  + "\t\t・Phone: \(phoneDescr)\n"
                  + "\t\t・Is also an artist: \(isArtist ? "✓" : "✗")\n"
        
        return descr
    }
    
    var name: String { return givenName }
    
    var favoriteColor: String
    
    var age: UInt
    
    var weight: Double
    
    var isArtist: Bool
    
    init(name: String, favoriteColor: String, age: UInt,
         weight: Double, phone: String, isArtist:Bool)
    {
        
        self.age = age
        self.favoriteColor = favoriteColor
        self.weight = weight
        self.isArtist = isArtist
        
        super.init()
        
        givenName = name
        
        let phoneNumber = CNPhoneNumber(stringValue: phone)
        phoneNumbers.append(CNLabeledValue(label: "phone", value: phoneNumber))
    }
    
    convenience init?(with dict: NSDictionary)
    {
        guard let name: String = getVaule(dict, fieldName: "name")
            else { print("Error: name"); return nil }
        
        guard let favoriteColor: String = getVaule(dict, fieldName: "favorite_color")
            else { print("Error: favorite_color"); return nil }

        guard let age: UInt = getVaule(dict, fieldName: "age")
            else { print("Error: age"); return nil }
        
        guard let weight: Double = getVaule(dict, fieldName: "weight")
            else { print("Error: weight"); return nil }

        guard let phone: String = getVaule(dict, fieldName: "phone")
            else { print("Error: phone"); return nil }

        guard let isArtist: Bool = getVaule(dict, fieldName: "is_artist")
            else { print("Error: is_artist"); return nil }
        
        self.init(name: name, favoriteColor: favoriteColor, age: age,
                  weight: weight, phone: phone, isArtist: isArtist)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        print("No init with coder for now...")
        return nil
    }
}


// MARK: Platform Enum
enum Platform : String
{
    case Android = "Android"
    case iOS = "iOS"
}


// MARK: Some Experiments

//        lazy var placeMark: MKPlacemark? = self.fetchCoordinate()
//        
//        var coordinate: CLLocationCoordinate2D {
//            if let coord = self.placeMark?.coordinate {
//                return coord
//            } else {
//                print("Unable to lookup coordinates. "
//                    + "Check the address is correct. "
//                    + "A (latitude: 0 ,longitude: 0) coordinate will be returned")
//                
//                return CLLocationCoordinate2DMake(0, 0)
//            }
//        }



//private func fetchCoordinate() -> MKPlacemark?
//{
//    let address = "\(locality) \(region), \(postalCode) \(country)"
//    var result: MKPlacemark? = nil
//    
//    CLGeocoder().geocodeAddressString(address)
//    {
//        (placeMarks, error)
//        in
//        guard error == nil && placeMarks?.count > 0
//            else { return }
//        
//        result = MKPlacemark(placemark:(placeMarks?.first)!)
//        print(result)
//    }
//    
//    return result
//}



//extension Location : MKAnnotation
//{
////    private var iCoordinates: CLLocationCoordinate2D?
//    
//    var coordinates: CLLocationCoordinate2D {
//       let geocoder = CLGeocoder()
//        return geocoder.geo
//    }
//}



//extension CLPlacemark {
//    
//    typealias PublicId = String
//    
//    private struct AssociatedKeys {
//        static var kPublicId = "fpc_kPublicId_associatedKey" as PublicId
//    }
//    
//    var publicId: PublicId? {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.kPublicId) as? PublicId
//        }
//        set {
//            guard (newValue != nil) else { return }
//            
//            objc_setAssociatedObject(self, &AssociatedKeys.kPublicId, newValue as PublicId?,
//                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//}
