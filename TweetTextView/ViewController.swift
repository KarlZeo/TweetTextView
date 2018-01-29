//
//  ViewController.swift
//  TweetTextView
//
//  Created by Zeo on 27/01/2018.
//  Copyright © 2018 Zeo. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusString: String = "Example tweet text here. Don't you just love AppKit? Here's a reference to @Twitter. Check out this cool new site: https://www.apple.com #hashtag #tutorial #中文测试"
        
        let insetRect = CGRect(x: 0, y: 0, width: 480, height: 270)
        let statusView = TweetTextView(frame: insetRect)
        statusView.statusString = statusString
        // Add to window and we're done.
        self.view.addSubview(statusView)
        
        statusView.linkTarget = self
        statusView.linkAction = #selector(link)
        statusView.usernameTarget = self
        statusView.usernameAction = #selector(username)
        statusView.hashtagTarget = self
        statusView.hashtagAction = #selector(hashtag)
    }
    
    @objc func link() {
        print("link")
    }
    
    @objc func username() {
        print("username")
    }
    
    @objc func hashtag() {
        print("hashtag")
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

