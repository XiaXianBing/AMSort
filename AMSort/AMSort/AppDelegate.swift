//
//  AppDelegate.swift
//  AMSort
//
//  Created by XiaXianBing on 2017-5-2.
//  Copyright © 2017年 XiaXianBing. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		self.window = UIWindow.init(frame: UIScreen.main.bounds)
		self.window?.backgroundColor = UIColor.white
		let storyboard = UIStoryboard.init(name: "Sort", bundle: nil)
		let sort = storyboard.instantiateViewController(withIdentifier: "SortSID")
		let navi = UINavigationController.init(rootViewController: sort)
		window?.rootViewController = navi
		self.window?.makeKeyAndVisible()
		return true
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		application.applicationIconBadgeNumber = 0
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
	}
}
