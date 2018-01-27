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
        
        var statusString: String = "Example tweet text here. Don't you just love AppKit? Here's a reference to @Twitter. Check out this cool new site: https://www.apple.com #hashtag #tutorial #中文测试"
        
        var attributedStatusString = NSMutableAttributedString(string: statusString)
        
        var textShadow: NSShadow? = NSShadow()
        textShadow?.shadowColor = NSColor(deviceWhite: 1, alpha: 0.8)
        textShadow?.shadowBlurRadius = 0
        textShadow?.shadowOffset = NSMakeSize(0, -1)
        
        var paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        paragraphStyle?.minimumLineHeight = 22
        paragraphStyle?.maximumLineHeight = 22
        paragraphStyle?.paragraphSpacing = 0
        paragraphStyle?.paragraphSpacingBefore = 0
        paragraphStyle?.tighteningFactorForTruncation = 4
        paragraphStyle?.alignment = .natural
        paragraphStyle?.lineBreakMode = .byWordWrapping
        
        let fullAttributes = [NSAttributedStringKey.foregroundColor: NSColor(deviceHue: 0.53, saturation: 0.13, brightness: 0.26, alpha: 1), NSAttributedStringKey.shadow: textShadow, .cursor: NSCursor.arrow, NSAttributedStringKey.kern: 0.0, NSAttributedStringKey.ligature: 0, NSAttributedStringKey.paragraphStyle: paragraphStyle, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 14.0)] as [NSAttributedStringKey : Any]
        attributedStatusString.addAttributes(fullAttributes, range: NSRange(location: 0, length: statusString.count))
        
        let linkMatches = scanString(forLinks: statusString)
        let usernameMatches = scanString(forUsernames: statusString)
        let hashtagMatches = scanString(forHashtags: statusString)
        
        for match: NSTextCheckingResult in linkMatches {
            let range: NSRange = match.range
            if range.location != NSNotFound {
                let string: NSString = NSString(string: statusString)
                let linkMatchedString = string.substring(with: range)
                let linkAttr: NSDictionary = [NSAttributedStringKey.cursor: NSCursor.pointingHand, NSAttributedStringKey.foregroundColor: NSColor.blue, NSAttributedStringKey.font: NSFont.boldSystemFont(ofSize: 14.0), TVLinkMatchAttributeName: linkMatchedString]
                attributedStatusString.addAttributes(linkAttr as! [NSAttributedStringKey : Any], range: range)
            }
        }
        
        for match: NSTextCheckingResult in usernameMatches {
            let range: NSRange = match.range
            if range.location != NSNotFound {
                let string: NSString = NSString(string: statusString)
                let usernameMatchedString = string.substring(with: range)
                // Add custom attribute of UsernameMatch to indicate where our usernames are found
                let linkAttr2: NSDictionary = [NSAttributedStringKey.foregroundColor: NSColor.black, NSAttributedStringKey.cursor: NSCursor.pointingHand, NSAttributedStringKey.font: NSFont.boldSystemFont(ofSize: 14.0), TVUsernameMatchAttributeName: usernameMatchedString]
                attributedStatusString.addAttributes(linkAttr2 as! [NSAttributedStringKey : Any], range: range)
            }
        }
        
        for match: NSTextCheckingResult in hashtagMatches {
            let range: NSRange = match.range
            if range.location != NSNotFound {
                let string: NSString = NSString(string: statusString)
                let hashtagMatchedString = string.substring(with: range)
                // Add custom attribute of HashtagMatch to indicate where our hashtags are found
                let linkAttr3: NSDictionary = [NSAttributedStringKey.foregroundColor: NSColor.gray, NSAttributedStringKey.foregroundColor: NSCursor.pointingHand, NSAttributedStringKey.font: NSFont.systemFont(ofSize: 14.0), TVHashtagMatchAttributeName: hashtagMatchedString]
                attributedStatusString.addAttributes(linkAttr3 as! [NSAttributedStringKey : Any], range: range)
            }
        }
        
        let insetRect = CGRect(x: 0, y: 0, width: 480, height: 270)
        let statusView = TweetTextView(frame: insetRect)
        statusView.autoresizingMask = [.width, .height]
        statusView.backgroundColor = NSColor.clear
        statusView.textContainerInset = NSZeroSize
        statusView.textStorage?.setAttributedString(attributedStatusString)
        statusView.isEditable = false
        statusView.isSelectable = true
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
    
    func scanString(forLinks string: String) -> [NSTextCheckingResult] {
        var regEx: NSRegularExpression? = nil
        var onceToken = NSInteger()
        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            let pattern = "\\b(([\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/)))"
            var error: Error?
            regEx = try? NSRegularExpression(pattern: pattern, options: [])
            if regEx == nil {
                print("\(error)")
            }
        }
        onceToken = 1
        let fullRange = NSRange(location: 0, length: (string.count ?? 0))
        let matches = regEx?.matches(in: string, options: [], range: fullRange)
        return matches ?? [NSTextCheckingResult]()
    }
    
    func scanString(forUsernames string: String) -> [NSTextCheckingResult] {
        var regEx: NSRegularExpression? = nil
        var onceToken = NSInteger()
        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            let pattern = "@{1}([-A-Za-z0-9_]{2,})"
            var error: Error?
            regEx = try? NSRegularExpression(pattern: pattern, options: [])
            if regEx == nil {
                print("\(error)")
            }
        }
        onceToken = 1
        let fullRange = NSRange(location: 0, length: (string.count ?? 0))
        let matches = regEx?.matches(in: string, options: [], range: fullRange)
        return matches ?? [NSTextCheckingResult]()
    }
    
    func scanString(forHashtags string: String) -> [NSTextCheckingResult] {
        var regEx: NSRegularExpression? = nil
        var onceToken = NSInteger()
        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            let pattern = "[\\s]{1,}#{1}([^\\s]{2,})"
            var error: Error?
            regEx = try? NSRegularExpression(pattern: pattern, options: [])
            if regEx == nil {
                print("\(error)")
            }
        }
        onceToken = 1
        let fullRange = NSRange(location: 0, length: (string.count ?? 0))
        let matches = regEx?.matches(in: string, options: [], range: fullRange)
        return matches ?? [NSTextCheckingResult]()
    }
    
}

