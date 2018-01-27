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
    }
    
    override func awakeFromNib() {
        
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
}

