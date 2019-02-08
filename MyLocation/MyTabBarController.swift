//
//  MyTabBarController.swift
//  MyLocation
//
//  Created by Phi Hoang Huy on 2/8/19.
//  Copyright © 2019 Phi Hoang Huy. All rights reserved.
//

import UIKit
class MyTabBarController: UITabBarController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var childForStatusBarStyle:
        UIViewController? {
        return nil
    }
}
