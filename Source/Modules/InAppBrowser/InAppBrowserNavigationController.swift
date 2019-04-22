//
//  InAppBrowserNavigationController.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 4/22/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

public class InAppBrowserNavigationController: UINavigationController {

    // MARK: - Instantiate ViewController
    
    public class func instantiate(url: URL) -> InAppBrowserNavigationController {
        guard let navigationController = UIStoryboard(name: "InAppBrowser", bundle: Bundle(for: InAppBrowserNavigationController.self)).instantiateInitialViewController() as? InAppBrowserNavigationController,
            let viewController = navigationController.topViewController as? InAppBrowserViewController else {
            fatalError("Invalid storyboard")
        }
        
        viewController.url = url
        
        return navigationController
    }

}
