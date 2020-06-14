//
//  AppDelegate.swift
//  do.buy
//
//  Created by Mingu Kang on June/2020.
//  Copyright 2020 Mingu. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UITabBar.appearance().tintColor = .systemRed
//        UITabBar.appearance().backgroundColor = .black
//        UITabBar.appearance().barTintColor = .darkGray
        
        print(Realm.Configuration.defaultConfiguration.fileURL)

//        do {
//            let realm = try Realm()
//        } catch {
//            print(error.localizedDescription)
//        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
}

