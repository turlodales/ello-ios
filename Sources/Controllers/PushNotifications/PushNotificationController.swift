//
//  PushNotificationController.swift
//  Ello
//
//  Created by Gordon Fontenot on 4/22/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SwiftyUserDefaults

private let NeedsPermissionKey = "PushNotificationNeedsPermission"
private let DeniedPermissionKey = "PushNotificationDeniedPermission"

public class PushNotificationController {
    public static let sharedController = PushNotificationController()

    var needsPermission: Bool {
        get { return Defaults[NeedsPermissionKey].bool ?? true }
        set { Defaults[NeedsPermissionKey] = newValue }
    }

    var permissionDenied: Bool {
        get { return Defaults[DeniedPermissionKey].bool ?? false }
        set { Defaults[DeniedPermissionKey] = newValue }
    }

    public init() {
        registerForLocalNotifications()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

public extension PushNotificationController {
    func requestPushAccessIfNeeded() -> AlertViewController? {
        if !AuthToken().isAuthenticated { return .None }
        if permissionDenied { return .None }

        if needsPermission { return alertViewController() }

        registerForRemoteNotifications()
        return .None
    }

    func registerForRemoteNotifications() {
        self.needsPermission = false
        registerStoredToken()

        let settings = UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: .None)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }

    func updateToken(token: NSData) {
        Keychain.pushToken = token
        ProfileService().updateUserDeviceToken(token)
    }

    func registerStoredToken() {
        if let token = Keychain.pushToken {
            ProfileService().updateUserDeviceToken(token)
        }
    }

    @objc func deregisterStoredToken() {
        if let token = Keychain.pushToken {
            ProfileService().removeUserDeviceToken(token)
        }
    }
}

private extension PushNotificationController {
    func registerForLocalNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("deregisterStoredToken"), name: Notifications.UserLoggedOut.rawValue, object: .None)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("deregisterStoredToken"), name: Notifications.SystemLoggedOut.rawValue, object: .None)
    }

    func alertViewController() -> AlertViewController {
        let alert = AlertViewController(message: NSLocalizedString("Allow Push Notifications?", comment: "Turn on Push Notifications?"), dismissable: false)

        let disallowAction = AlertAction(title: NSLocalizedString("Disallow", comment: "Disallow"), style: .Dark) { _ in
            self.needsPermission = false
            self.permissionDenied = true
        }
        alert.addAction(disallowAction)

        let allowAction = AlertAction(title: NSLocalizedString("Allow", comment: "Allow"), style: .Light) { _ in
            self.registerForRemoteNotifications()
        }
        alert.addAction(allowAction)

        return alert
    }
}