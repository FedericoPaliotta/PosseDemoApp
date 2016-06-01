//
//  AppDelegate.swift
//  DemoApp
//
//  Created by Federico Paliotta on 5/25/16.
//  Copyright © 2016 FPC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
       
        DataStore.sharedStore()
       
        return true
    }
    
}

