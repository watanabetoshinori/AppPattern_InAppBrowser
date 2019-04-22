//
//  WebViewSettings.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 4/22/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

class InAppBrowserSettings: NSObject {
    
    enum DebugTool {
        case none
        case firebug
        case eruda
        
        var javascript: String {
            switch self {
            case .firebug:
                return "(function(F,i,r,e,b,u,g,L,I,T,E){if(F.getElementById(b))return;E=F[i+'NS']&&F.documentElement.namespaceURI;E=E?F[i+'NS'](E,'script'):F[i]('script');E[r]('id',b);E[r]('src',I+g+T);E[r](b,u);(F[e]('head')[0]||F[e]('body')[0]).appendChild(E);E=new Image;E[r]('src',I+L);})(document,'createElement','setAttribute','getElementsByTagName','FirebugLite','4','firebug-lite.js','releases/lite/latest/skin/xp/sprite.png','https://getfirebug.com/','#startOpened');"
            case .eruda:
                return "(function () { var script = document.createElement('script'); script.src=\"//cdn.jsdelivr.net/npm/eruda\"; document.body.appendChild(script); script.onload = function () { eruda.init() } })()"
            default:
                return ""
            }
        }
    }
    
    var debugTool: DebugTool = .none

    // MARK: - Initializing a Singleton
    
    static let shared = InAppBrowserSettings()
    
    override private init() {
        
    }    
    
}
