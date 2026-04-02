//
//  MogilSerlestApp.swift
//  MogilSerlest
//
//  Created by Philipp Timofeev on 02.04.26.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(UIKit)
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        #if canImport(FirebaseCore)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        #endif
        return true
    }
}
#endif

@main
struct MogilSerlestApp: App {
    #if canImport(UIKit)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
