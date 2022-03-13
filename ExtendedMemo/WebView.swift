//
//  WebView.swift
//  ExtendedMemo
//
//

import Foundation
import WebKit
import SwiftUI
struct Web:UIViewControllerRepresentable {
    var controller:WebViewControll?
    var currentpage:String
    var archivelists:WKBackForwardList?
    var beforeurl = ""
    @ObservedObject var singlec:single
    init(){
        self.singlec = single()
        self.currentpage = "https://www.google.co.jp"
    }
    init(archive:WKBackForwardList,random:Int){
        self.singlec = single()
        self.archivelists = archive
        self.currentpage = "\(archive.item(at: userDefaults.integer(forKey: String(random))))"

    }
    func makeUIViewController(context: Context) -> WebViewControll {
        instances[lastnum]!.controller = WebViewControll(coordinator: context.coordinator)
        instances[lastnum]!.controller!.webview.load(URLRequest(url:URL(string:currentpage)!))
        return instances[lastnum]!.controller!
    }
    func updateUIViewController(_ uiViewController: WebViewControll, context: Context) {
    }
    func makeCoordinator() -> Web.Coordinator {
        return Coordinator(view:self,singlet:singlec)
    }
    class Coordinator:NSObject,WKNavigationDelegate,WKUIDelegate {
        let currentview:Web
        var target:single
        init (view:Web,singlet:single){
            self.currentview = view
            self.target = singlet
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            
            let url = URL(fileURLWithPath: Bundle.main.path(forResource:"NF404", ofType: "html")!, isDirectory: false)
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            instances[lastnum]!.singlec.cangoforward = !webView.canGoForward
            instances[lastnum]!.singlec.cangoback = !webView.canGoBack
        }
    }
    
}
class WebViewControll:UIViewController,UIGestureRecognizerDelegate,ObservableObject {
    var notifer = false
    var currenttitle = "Google"
    var webview: WKWebView
    
//    let CookieStore = WKWebsiteDataStore.default()
    var delegate:Web.Coordinator? = nil
    
    var _observers = [NSKeyValueObservation]()
    init (coordinator: Web.Coordinator) {
        self.delegate = coordinator
        self.webview = WKWebView()
        self.webview.allowsBackForwardNavigationGestures = true
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
           self.webview = WKWebView()
           super.init(coder: coder)
       }
    
    override func loadView() {
        self.webview.navigationDelegate = self.delegate
        self.webview.uiDelegate = self.delegate
        view = webview
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        _observers.append(webview.observe(\.estimatedProgress, options: .new){_,change in
            print("Progress: \(change.newValue!)")
            contentView.progress.Progress.setProgress(Float(change.newValue!), animated: true)
            if (change.newValue! == 1.0){
                contentView.progress.Progress.setProgress(0.0, animated: true)
                contentView.show = false
            }
            else {
                contentView.show = true
                contentView.progress.Progress.setProgress(Float(change.newValue!), animated: true)
            }
                })
        _observers.append(webview.observe(\.url, options: .new){_,change in
            instances[lastnum]!.singlec.cangoback = !instances[lastnum]!.controller!.webview.canGoBack
            instances[lastnum]!.singlec.cangoforward = !instances[lastnum]!.controller!.webview.canGoForward
            if ((change.newValue! != nil) && (change.newValue! != URL(fileURLWithPath: Bundle.main.path(forResource:"NF404", ofType: "html")!, isDirectory: false))) {
            contentView.Search.TextField.Text.text = change.newValue!!.absoluteString
            Tex = change.newValue!!.absoluteString
            }
            else {
                contentView.Search.TextField.Text.text = instances[lastnum]!.beforeurl
            }
                })
        _observers.append(webview.observe(\.title,options: .new) {_, change in
            print("Loading:\(change.newValue!!)")
            if ((change.newValue!! != "") && (self.currenttitle != change.newValue!!)){
            self.currenttitle = change.newValue!!
            instances[lastnum]!.singlec.operate.toggle()
            }
        })
    }
}
class single:ObservableObject {
    @Published var load = false
    @Published var save = false
    @Published var operate = false
    @Published var menuisshowed = false
    @Published var cangoback = false
    @Published var cangoforward = false
}
