//
//  MainViewController.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 4/22/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    // MARK: - ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Transpernt NavigationBar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textField.becomeFirstResponder()
    }
    
    // MARK: - TextField delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.text?.count ?? 0) > 0 {
            let queryString = textField.text ?? ""
            
            var components = URLComponents(string: "https://www.google.com/search")!
            components.queryItems = [URLQueryItem(name: "q", value: queryString)]
            let url = components.url!
            
            let viewController = InAppBrowserNavigationController.instantiate(url: url)
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true, completion: nil)
            
            return true
        }
        
        return false
    }

}
