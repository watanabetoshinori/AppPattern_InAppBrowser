//
//  InAppBrowserBackForwardListController.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 4/22/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit
import WebKit

protocol InAppBrowserBackForwardListControllerDelegate: class {
    
    func backForwardListDidSelectItem(_ item: WKBackForwardListItem)
}

class InAppBrowserBackForwardListController: UITableViewController {
    
    weak var delegate: InAppBrowserBackForwardListControllerDelegate?
    
    var items = [WKBackForwardListItem]()
    
    // MARK: - ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Actions
    
    @IBAction func doneTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.url.host
        return cell
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        delegate?.backForwardListDidSelectItem(item)
        dismiss(animated: true, completion: nil)
    }

}
