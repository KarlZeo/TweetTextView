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
    
    public var usernameTextColor: NSColor = {
        let color = NSColor(cgColor: NSColor.blue.cgColor)
        return color!
    }()
    
    public var linkTextColor: NSColor = {
        let color = NSColor(cgColor: NSColor.blue.cgColor)
        return color!
    }()
    
    public var hashtagTextColor: NSColor = {
        let color = NSColor(cgColor: NSColor.lightGray.cgColor)
        return color!
    }()
    
    public var usernameTextFont: NSFont = {
        let font = NSFont.boldSystemFont(ofSize: 14.0)
        return font
    }()
    
    public var linkTextFont: NSFont = {
        let font = NSFont.boldSystemFont(ofSize: 14.0)
        return font
    }()
    
    public var hashtagTextFont: NSFont = {
        let font = NSFont.systemFont(ofSize: 14.0)
        return font
    }()
    
    public var textShadow: NSShadow = {
        let shadow = NSShadow()
        shadow.shadowColor = NSColor(deviceWhite: 1, alpha: 0.8)
        shadow.shadowBlurRadius = 0
        shadow.shadowOffset = NSMakeSize(0, -1)
        return shadow
    }()
    
    public var paragraphStyle: NSMutableParagraphStyle = {
        let style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        style?.minimumLineHeight = 22
        style?.maximumLineHeight = 22
        style?.paragraphSpacing = 0
        style?.paragraphSpacingBefore = 0
        style?.tighteningFactorForTruncation = 4
        style?.alignment = .natural
        style?.lineBreakMode = .byWordWrapping
        return style!
    }()
    
    var statusString: String {
        set {
            let attStr = self.setAttributedString(newValue)
            self.textStorage?.setAttributedString(attStr)
        }
        get {
            return ""
        }
    }
    
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
    
    
    private func setAttributedString(_ originString: String) -> NSMutableAttributedString {
        let statusString: String = originString
        
        let attributedStatusString = NSMutableAttributedString(string: statusString)
        
        let fullAttributes = [
            NSAttributedStringKey.foregroundColor: NSColor(deviceHue: 0.53, saturation: 0.13, brightness: 0.26, alpha: 1),
            NSAttributedStringKey.shadow: self.textShadow,
            NSAttributedStringKey.cursor: NSCursor.arrow,
            NSAttributedStringKey.kern: 0.0,
            NSAttributedStringKey.ligature: 0,
            NSAttributedStringKey.paragraphStyle: self.paragraphStyle,
            NSAttributedStringKey.font: NSFont.systemFont(ofSize: 14.0)
            ] as [NSAttributedStringKey : Any]
        attributedStatusString.addAttributes(fullAttributes, range: NSRange(location: 0, length: statusString.count))
        
        let linkMatches = scanString(forLinks: statusString)
        let usernameMatches = scanString(forUsernames: statusString)
        let hashtagMatches = scanString(forHashtags: statusString)
        
        for match: NSTextCheckingResult in linkMatches {
            let range: NSRange = match.range
            if range.location != NSNotFound {
                let string: NSString = NSString(string: statusString)
                let linkMatchedString = string.substring(with: range)
                let linkAttr: NSDictionary = [
                    NSAttributedStringKey.cursor: NSCursor.pointingHand,
                    NSAttributedStringKey.foregroundColor: self.linkTextColor,
                    NSAttributedStringKey.font: self.linkTextFont,
                    TVLinkMatchAttributeName: linkMatchedString
                ]
                attributedStatusString.addAttributes(linkAttr as! [NSAttributedStringKey : Any], range: range)
            }
        }
        
        for match: NSTextCheckingResult in usernameMatches {
            let range: NSRange = match.range
            if range.location != NSNotFound {
                let string: NSString = NSString(string: statusString)
                let usernameMatchedString = string.substring(with: range)
                // Add custom attribute of UsernameMatch to indicate where our usernames are found
                let linkAttr2: NSDictionary = [
                    NSAttributedStringKey.foregroundColor: self.usernameTextColor,
                    NSAttributedStringKey.cursor: NSCursor.pointingHand,
                    NSAttributedStringKey.font: self.usernameTextFont,
                    TVUsernameMatchAttributeName: usernameMatchedString
                ]
                attributedStatusString.addAttributes(linkAttr2 as! [NSAttributedStringKey : Any], range: range)
            }
        }
        
        for match: NSTextCheckingResult in hashtagMatches {
            let range: NSRange = match.range
            if range.location != NSNotFound {
                let string: NSString = NSString(string: statusString)
                let hashtagMatchedString = string.substring(with: range)
                // Add custom attribute of HashtagMatch to indicate where our hashtags are found
                let linkAttr3: NSDictionary = [
                    NSAttributedStringKey.foregroundColor: self.hashtagTextColor,
                    NSAttributedStringKey.foregroundColor: NSCursor.pointingHand,
                    NSAttributedStringKey.font: self.hashtagTextFont,
                    TVHashtagMatchAttributeName: hashtagMatchedString
                ]
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
    
    private func scanString(forLinks string: String) -> [NSTextCheckingResult] {
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
    
    private func scanString(forUsernames string: String) -> [NSTextCheckingResult] {
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
    
    private func scanString(forHashtags string: String) -> [NSTextCheckingResult] {
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

