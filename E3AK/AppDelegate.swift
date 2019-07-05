//
//  AppDelegate.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/7.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit
import ChameleonFramework
import IQKeyboardManagerSwift

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       

        let isfirst = Config.saveParam.bool(forKey: Config.firstOpen)
        var storyboard:UIStoryboard!
        
        storyboard = UIStoryboard(storyboard: .Main)
        let vc:HomeNavigationController =  storyboard.instantiateViewController()
        window?.rootViewController = vc

       /* if !isfirst{
          storyboard = UIStoryboard(storyboard: .Intro)
            let vc:IntroNavigationController = storyboard.instantiateViewController()
           Config.saveParam.set(true, forKey: Config.firstOpen)
            window?.rootViewController = vc
        }else{
            storyboard = UIStoryboard(storyboard: .Main)
           let vc:HomeNavigationController =  storyboard.instantiateViewController()
           window?.rootViewController = vc
       }*/
       
       
        window?.makeKeyAndVisible()
        
        configUI()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        exit(0) //0508
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func configUI() {
        
        UINavigationBar.appearance().shadowImage = UIImage.imageWithColor(color: HexColor("00b900")!)
        UINavigationBar.appearance().setBackgroundImage(UIImage.imageWithColor(color: .white), for: .default)
        //UINavigationBar.appearance().setBackgroundImage(UIImage.imageWithColor(color: UIColor(colorLiteralRed: (247/255), green: (247/255), blue: (247/255), alpha: 1)), for: .default)
        UINavigationBar.appearance().barTintColor = UIColor(red: 70.0/255.0, green: 164.0/255.0, blue: 239.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = HexColor("00b900")
        
        UITextField.appearance().tintColor = HexColor("00b900")
    }

}

