//  TVTextView.swift
//  ActiveLabelMac
//
//  Created by Zeo on 27/01/2018.
//  Copyright © 2018 Zeo. All rights reserved.
//

import Cocoa

let TVLinkMatchAttributeName = "TVLinkMatch"
let TVUsernameMatchAttributeName = "TVUsernameMatch"
let TVHashtagMatchAttributeName = "TVHashtagMatch"

class TweetTextView: NSTextView {
    
    public var linkAction: Selector?
    
    public var linkTarget: AnyObject?
    
    public var usernameAction: Selector?
    
    public var usernameTarget: AnyObject?
    
    public var hashtagAction: Selector?
    
    public var hashtagTarget: AnyObject?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        self.originSetting()
    }
    
    override func awakeFromNib() {
        self.originSetting()
    }
    
    func originSetting() {
        self.autoresizingMask = [.width, .height]
        self.backgroundColor = NSColor.clear
        self.textContainerInset = NSZeroSize
        self.isEditable = false
        self.isSelectable = true
    }
    
    var statusString: String {
        set {
            let attStr = self.setAttributedString(newValue)
            self.textStorage?.setAttributedString(attStr)
        }
        get {
            return ""
        }
    }
    
    private func setAttributedString(_ originString: String) -> NSMutableAttributedString {
        let statusString: String = originString
        
        let attributedStatusString = NSMutableAttributedString(string: statusString)
        
        let textShadow: NSShadow? = NSShadow()
        textShadow?.shadowColor = NSColor(deviceWhite: 1, alpha: 0.8)
        textShadow?.shadowBlurRadius = 0
        textShadow?.shadowOffset = NSMakeSize(0, -1)
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
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
        return attributedStatusString
    }
    
    override func mouseDown(with event: NSEvent) {
        let point = self.convert(event.locationInWindow, from: nil)
        let charIndex = self.characterIndexForInsertion(at: point)
        if (NSLocationInRange(charIndex, NSRange(location: 0, length: self.string.count)) == true) {
            let attributes: NSDictionary = attributedString().attributes(at: charIndex, effectiveRange: nil) as NSDictionary
            if attributes[TVLinkMatchAttributeName] != nil {
                self.linkTarget?.perform(self.linkAction, with: self)
            }
            if attributes[TVUsernameMatchAttributeName] != nil {
                self.usernameTarget?.perform(self.usernameAction, with: self)
            }
            if attributes[TVHashtagMatchAttributeName] != nil {
                self.hashtagTarget?.perform(hashtagAction, with: self)
            }
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

