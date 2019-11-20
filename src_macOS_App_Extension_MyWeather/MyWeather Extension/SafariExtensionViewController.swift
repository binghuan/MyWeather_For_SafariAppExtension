//
//  SafariExtensionViewController.swift
//  MyWeather Extension
//
//  Created by BH_Lin on 2019/11/12.
//  Copyright © 2019 Studio Bing-Huan. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()
    
}
