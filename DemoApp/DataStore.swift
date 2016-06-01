//
//  DataStore.swift
//  DemoApp
//
//  Created by Federico Paliotta on 5/29/16.
//  Copyright © 2016 FPC. All rights reserved.
//

import Foundation

final class DataStore
{
    
    private static let singleton = DataStore()
    
    static func sharedStore() -> DataStore {
        return singleton
    }
    
    func refetchData() {
        fetch_json_block()
    }
    
    private init()
    {
        refetchData()
    }
    
    private var locations: [Location]? {
        return cache_pop_block()
    }
    
    func getLocationsData(completion:(([Location]?)->())? = nil) -> [Location]?
    {
        completion?(locations)
        
        return locations
    }
    
    
    ///////////////////////////////////////////////////////////////////////////
    
    
    private static let cacheFilePath = getDocumentsDirectory().stringByAppendingPathComponent("cache.json")

    
    // MARK: fetch new data
    private let fetch_json_block: () -> Void = {
        
        let session = NSURLSession.sharedSession()
        
        let serverUrl = NSURL(string: "https://script.google.com/macros/s/AKfycbyLeQf5Rg_tTJokB33NcR8ZzbjCASyksyvVMU7aCRCuInO01oRn/exec")!
        
        let dataTask = session.dataTaskWithURL(serverUrl)
        {
            data, response, error in
            
            guard error == nil && data != nil
                else { print("Error: \(error!.localizedDescription)\n\n"); return }
            
            guard let httpResponse = response as? NSHTTPURLResponse
                where httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
                else { print("Error: \(response?.description)\n\n"); return }
            
            cache_push_block(data!)
        }
        
        dataTask.resume()
    }
    
    
    // MARK: cache data
    private static let cache_push_block: (NSData) -> Bool = { data
        in
        
        let success = data.writeToFile(cacheFilePath, atomically: true)
       
        print("\(success ? "Cached data successfully! :)" : "Couldn't cache any data... :( ")\n")
        
        return success
    }
    
    
    private let cache_pop_block: () -> [Location]? = {
        
        var result: [Location]?
        
        do
        {
            let jsonData = try NSData(contentsOfFile: cacheFilePath,
                                             options: .DataReadingMappedIfSafe)
            
            let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData,
                                  options: .MutableContainers) as! NSDictionary
            //print(jsonDict)
            
            guard let jsonStatus: Int = getVaule(jsonDict, fieldName: "status")
                where jsonStatus >= 200 && jsonStatus < 300
                else { print("Error: JSON status\n"); return nil }
            
            guard let jsonResponse: NSDictionary = getVaule(jsonDict, fieldName: "response")
                else { print("Error: JSON response\n"); return nil }
            
            guard let jsonLocations: NSArray = getVaule(jsonResponse, fieldName:"locations")
                else { print("Error: JSON locations\n"); return nil }
            
            result = [Location]()
            
            for item in jsonLocations
            {
                if let dict = item as? NSDictionary
                {
                    if let location = Location(with: dict)
                    {
                        result!.append(location)
                    }
                }
            }
        }
        catch
        {
            print("Error: \(error)\n\n")
        }
        
        return result
    }
    
}

// MARK: global helper functions

func getVaule<T>(jsonData:NSDictionary, fieldName: String) -> T?
{
    if let value = jsonData.objectForKey(fieldName) as? T
    {
        //print(value)
        return value
    }
    else
    {
        return nil
    }
}

func getDocumentsDirectory() -> NSString
{
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    
    let documentsDirectory = paths[0]
    
    return documentsDirectory
}