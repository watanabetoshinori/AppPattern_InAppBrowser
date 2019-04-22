//
//  InAppBrowserViewController.swift
//  InAppBrowser
//
//  Created by Watanabe Toshinori on 4/22/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit
import WebKit

public class InAppBrowserViewController: UIViewController {
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var keyImageView: UIImageView!
    
    @IBOutlet weak var notSecureLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet var reloadButton: UIBarButtonItem!

    @IBOutlet var stopButton: UIBarButtonItem!

    @IBOutlet weak var backBarButton: UIBarButtonItem!
    
    @IBOutlet weak var forwardBarButton: UIBarButtonItem!

    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    @IBOutlet weak var safariButton: UIBarButtonItem!

    var webView: WKWebView!

    private var backButton: UIButton!
    
    private var forwardButton: UIButton!

    private var observers = [NSKeyValueObservation]()

    var url = URL(string: "https://www.google.com")!
    
    var configuration = WKWebViewConfiguration()
    
    var previewActions = [UIPreviewActionItem]()
    
    private var urlHandlers: [URLHandler] = [iTunesURLHandler()]
    
    public override var previewActionItems: [UIPreviewActionItem] {
        return previewActions
    }
    
    // MARK: - Instantiate ViewController

    public class func instantiate(url: URL, configuration: WKWebViewConfiguration, previewActions: [UIPreviewActionItem]) -> InAppBrowserViewController {
        guard let viewController = UIStoryboard(name: "InAppBrowser", bundle: Bundle(for: InAppBrowserViewController.self)).instantiateViewController(withIdentifier: "InAppBrowserViewController") as? InAppBrowserViewController else {
            fatalError("Invalid storyboard")
        }
        
        viewController.url = url
        viewController.configuration = configuration
        viewController.previewActions = previewActions
        
        return viewController
    }
    
    // MARK: - ViewController lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        keyImageView.tintColor = navigationController?.navigationBar.tintColor
        titleLabel.text = url.host ?? "unknown"

        initializeWebView()
        
        initialzieBackForwardButtons()

        startObservingWebViewState()
        
        openURL()
        
        showDeveloperTools()
    }
    
    deinit {
        stopObservingWebViewState()
    }
    
    // MARK: - Actions
    
    @IBAction func doneTapped(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reloadTapped(_ sender: Any) {
        webView.reload()
    }

    @IBAction func stopTapped(_ sender: Any) {
        webView.stopLoading()
    }

    @objc func backTapped(_ sender: Any) {
        webView.goBack()
    }

    @objc func forwardTapped(_ sender: Any) {
        webView.goForward()
    }
    
    @objc func backLongTapped(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            showBackForwardList(backBarButton)
        default:
            break
        }
    }

    @objc func forwardLongTapped(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            showBackForwardList(forwardBarButton)
        default:
            break
        }
    }

    @IBAction func actionTapped(_ sender: Any) {
        guard let url = webView.url else {
            return
        }

        let activityItems = [url]
        let viewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        viewController.popoverPresentationController?.barButtonItem = actionButton
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func safariTapped(_ sender: Any) {
        UIApplication.shared.open(webView.url!, options: [:]) { (result) in
            if result == false {
                print("Can't open URL by Safari.")
            }
        }
    }
    
    @objc func developerTapped(_ sender: Any) {
        webView.evaluateJavaScript(InAppBrowserSettings.shared.debugTool.javascript, completionHandler: nil)
    }
    
    // MARK: - Initialize UI
    
    private func initializeWebView() {
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(webView, at: 0)

        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    private func initialzieBackForwardButtons() {
        backButton = UIButton(type: .custom)
        backButton.isEnabled = false
        backButton.setImage(UIImage(named: "Back", in: Bundle(for: InAppBrowserViewController.self), compatibleWith: nil), for: .normal)
        backButton.tintColor = .lightGray
        backButton.addTarget(self, action: #selector(backTapped(_:)), for: .touchUpInside)
        backButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(backLongTapped(_:))))
        backBarButton.customView = backButton
        
        forwardButton = UIButton(type: .custom)
        forwardButton.isEnabled = false
        forwardButton.setImage(UIImage(named: "Forward", in: Bundle(for: InAppBrowserViewController.self), compatibleWith: nil), for: .normal)
        forwardButton.tintColor = .lightGray
        forwardButton.addTarget(self, action: #selector(forwardTapped(_:)), for: .touchUpInside)
        forwardButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(forwardLongTapped(_:))))
        forwardBarButton.customView = forwardButton
    }
    
    private func updateTitle() {
        if let title = webView.title, title.isEmpty == false {
            titleLabel.text = title
            return
        }
        if let host = webView.url?.host, host.isEmpty == false {
            titleLabel.text = host
            return
        }
    }
    
    private func openURL() {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func showDeveloperTools() {
        if InAppBrowserSettings.shared.debugTool == .none {
            return
        }

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let barButtonItem = UIBarButtonItem(image: UIImage(named: "Developer"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(developerTapped(_:)))
        
        toolbarItems?.append(contentsOf: [flexibleSpace, barButtonItem])
    }

    // MARK: - Observe WebView state

    private func startObservingWebViewState() {
        observers.append(webView.observe(\.estimatedProgress, options: .new) { (_, changes) in
            self.progressBar.progress = Float(changes.newValue ?? 0)
        })
        
        observers.append(webView.observe(\.title, options: .new) { (_, changes) in
            self.updateTitle()
        })
        
        observers.append(webView.observe(\.url, options: .new) { (_, changes) in
            self.updateTitle()
            
            self.actionButton.isEnabled = true
            self.safariButton.isEnabled = true
            
            let isSecure = (changes.newValue??.scheme ?? "") == "https"
            self.keyImageView.isHidden = !isSecure
            self.notSecureLabel.isHidden = isSecure
        })
        
        observers.append(webView.observe(\.isLoading, options: .new) { (_, changes) in
            self.navigationItem.rightBarButtonItems = (changes.newValue == true) ? [self.stopButton] : [self.reloadButton]
            self.progressBar.isHidden = (changes.newValue == false)
        })
        
        observers.append(webView.observe(\.canGoBack, options: .new) { (_, changes) in
            self.backButton.isEnabled = (changes.newValue == true)
            self.backButton.tintColor = (changes.newValue == true) ? self.navigationController?.toolbar.tintColor : UIColor.lightGray
        })
        
        observers.append(webView.observe(\.canGoForward, options: .new) { (_, changes) in
            self.forwardButton.isEnabled = (changes.newValue == true)
            self.forwardButton.tintColor = (changes.newValue == true) ? self.navigationController?.toolbar.tintColor : UIColor.lightGray
        })
    }
    
    private func stopObservingWebViewState() {
        observers.forEach({ $0.invalidate() })
    }
    
    // MARK: - Show BackForwardList
    
    private func showBackForwardList(_ barButtonItem: UIBarButtonItem) {
        
        let items: [WKBackForwardListItem] = {
            if barButtonItem == backBarButton {
                return Array(webView.backForwardList.backList.reversed())
            }
            return webView.backForwardList.forwardList
        }()

        if UIDevice.current.userInterfaceIdiom == .pad {
            guard let viewController = storyboard?.instantiateViewController(withIdentifier: "InAppBrowserBackForwardListController") as? InAppBrowserBackForwardListController else {
                fatalError("Invalid storyboard")
            }
            
            viewController.delegate = self
            viewController.items = items
            viewController.modalPresentationStyle = .popover
            viewController.popoverPresentationController?.barButtonItem = barButtonItem
            viewController.preferredContentSize = CGSize(width: 320, height: 220)
            
            present(viewController, animated: true, completion: nil)

        } else {
            guard let navigationController = storyboard?.instantiateViewController(withIdentifier: "InAppBrowserBackForwardListNavigationController") as? UINavigationController,
                let viewController = navigationController.topViewController as? InAppBrowserBackForwardListController else {
                    fatalError("Invalid storyboard")
            }
            
            viewController.delegate = self
            viewController.items = items
            
            present(navigationController, animated: true, completion: nil)

        }
    }

    // MARK: - Alert
    
    private func alert(_ error: Error) {
        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

}

// MARK: - WebView Navigation delegate

extension InAppBrowserViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if let urlHandler = urlHandlers.first(where: { $0.canHandle(url) }) {
                urlHandler.handle(url, viewController: self)
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
    // MARK: - Autholication Challenges
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
            let alertController = UIAlertController(title: "Log in to \(webView.url?.host ?? "site")", message: nil, preferredStyle: .alert)
            alertController.addTextField { (textField) in
                textField.placeholder = "User Name"
            }
            alertController.addTextField { (textField) in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
            }
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                let credential = URLCredential(user: alertController.textFields?[0].text ?? "",
                                               password: alertController.textFields?[1].text ?? "",
                                               persistence: .forSession)
                completionHandler(.useCredential, credential)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in
                completionHandler(.cancelAuthenticationChallenge, nil)
            }))
            
            present(alertController, animated: true, completion: nil)
            return
        }
        
        completionHandler(.performDefaultHandling, nil)
    }
    
    // MARK: - Reacting to Errors
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code == NSURLErrorCancelled {
            return
        }

        alert(error)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code == NSURLErrorCancelled {
            return
        }

        alert(error)
    }
    
}

// MARK: - WebView UI delegate

extension InAppBrowserViewController: WKUIDelegate {
    
    // MARK: - Creating a Web View
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame?.isMainFrame != true {
            webView.load(navigationAction.request)
        }
        
        return nil
    }
    
    // MARK: - Displaying UI Panels
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) -> Void in
            completionHandler()
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) -> Void in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) -> Void in
            completionHandler(false)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: prompt, message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { (action) -> Void in
            let input = alertController.textFields?.first?.text
            completionHandler(input)
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { (action) -> Void in
            completionHandler(nil)
        }))
        
        alertController.addTextField { (textField) -> Void in
            textField.text = defaultText
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Responding to Force Touch Actions
    
    public func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return true
    }

    public func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKPreviewElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {
        guard let url = elementInfo.linkURL else {
            fatalError("Invalid Link URL")
        }
        
        return InAppBrowserViewController.instantiate(url: url, configuration: configuration, previewActions: previewActions)
    }

    public func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {
        guard let viewController = previewingViewController as? InAppBrowserViewController,
            let url = viewController.webView.url else {
            fatalError("Invalid viewController")
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
}

// MARK: - InAppBrowserBackForwardListController delegate

extension InAppBrowserViewController: InAppBrowserBackForwardListControllerDelegate {
    
    func backForwardListDidSelectItem(_ item: WKBackForwardListItem) {
        webView.go(to: item)
    }

}
