//
//  AppDelegate.swift
//  Gunner
//
//  Created by Victor on 7/9/16.
//  Copyright © 2016 Bananaapps. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseCrash
import Firebase
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADInterstitialDelegate {

    var window: UIWindow?
    var gameViewController: GameViewController?
    var interstitial: GADInterstitial!
    var remoteConfig: FIRRemoteConfig!
    
    lazy var menuScene: MenuScene = {
        let scene = MenuScene(fileNamed:"MenuScene")!
        scene.scaleMode = .aspectFit
        return scene
    }()
    lazy var gameOverScene: GameOverScene = {
        let scene = GameOverScene(fileNamed:"GameOverScene")!
        scene.scaleMode = .aspectFit
        return scene
    }()
    var gameScene: GameScene? {
        didSet {
            gameScene?.scaleMode = .aspectFit
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Firebase
        FIRApp.configure()
        
        // Smooch integration
        let smoochSettings = SKTSettings(appToken: Constants.smoochAppToken)
        smoochSettings.conversationAccentColor = UIColor.appGreenColor()
        Smooch.initWith(smoochSettings)
        
        // Root VC
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        self.gameViewController = initialViewController
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        // Firebase remote config
        self.remoteConfig = FIRRemoteConfig.remoteConfig()
#if DEBUG
        let remoteConfigSettings = FIRRemoteConfigSettings(developerModeEnabled: true)
        self.remoteConfig.configSettings = remoteConfigSettings!
#endif
        self.remoteConfig.setDefaults([
            Constants.RemoteConfig.interstitial_gameover_enabled: Constants.RemoteConfig.interstitial_gameover_enabled_defaut as NSObject
            ])
        // fetch
        var expirationDuration = 3600
        // If in developer mode cacheExpiration is set to 0 so each fetch will retrieve values from
        // the server.
        if (remoteConfig.configSettings.isDeveloperModeEnabled) {
            expirationDuration = 0
        }
        // cacheExpirationSeconds is set to cacheExpiration here, indicating that any previously
        // fetched and cached config would be considered expired because it would have been fetched
        // more than cacheExpiration seconds ago. Thus the next fetch would go to the server unless
        // throttling is in progress. The default expiration duration is 43200 (12 hours).
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
            if (status == FIRRemoteConfigFetchStatus.success) {
                print("Config fetched!")
                self.remoteConfig.activateFetched()
            } else {
                print("Config not fetched")
                print("Error \(error!.localizedDescription)")
            }
        }
        
        // Preload Ads
        self.createAndLoadInterstitial()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - AdMob
    
    fileprivate func createAndLoadInterstitial() {
        interstitial = GADInterstitial(adUnitID: Constants.admob_interstitial_gameover_unitID)
        interstitial.delegate = self
        let request = GADRequest()
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        request.testDevices = [ kGADSimulatorID, "2077ef9a63d2b398840261c8221a0c9b" ]
        interstitial.load(request)
    }
    
    func presentInterstitial() {
        let interstitialEnabled = remoteConfig[Constants.RemoteConfig.interstitial_gameover_enabled].boolValue
        if interstitialEnabled {
            if interstitial != nil && interstitial.isReady {
                if let targetVC = self.gameViewController {
                    interstitial.present(fromRootViewController: targetVC)
                }
            } else {
                self.createAndLoadInterstitial()
            }
        }
    }
    
    //GADInterstitialDelegate
    func interstitialDidDismissScreen(_ ad: GADInterstitial!) {
        self.createAndLoadInterstitial()
    }

}

