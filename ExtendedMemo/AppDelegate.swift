//
//  AppDelegate.swift
//  ExtendedMemo
//
//

import UIKit
var instances:[Web?] = []
var userDefaults = UserDefaults.standard
var lastnum:Int = 0
var tab:[String] = []
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    //iOS Simulator用のディレクトリ表示(デバッグ時にAppのファイルを見やすくするため)
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].absoluteString
        print("dir:\(dir)")
        print("allowFin:\(userDefaults.bool(forKey: "allowFin"))")
        //userDにUUIDが登録されていたらそれをPenproに渡す
        if  let UUID = userDefaults.string(forKey: "LastUUID") {
            Penpro.uuid = UUID
        }
//        if let lastUsed = UserDefaults.string()
        if userDefaults.bool(forKey: "allowFin") {
            userDefaults.set(false,forKey: "allowFin")
        }

        if  (userDefaults.array(forKey: "tabs") != nil) {
            //tabsがあればそれを開き直す。
            tab = userDefaults.array(forKey: "tabs") as! [String]
            lastnum = userDefaults.integer(forKey: "lastopened")
            //tabs配列にはsnowflake形式で保存したIDを持つtabの履歴配列を保管するような設計にする
            instances.append(Web())
        }
        else {
            instances.append(Web())
            
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

