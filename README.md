# TweetTextView

This is a custom NSTextView to heighlight username hashtag and link.

## Support

Swift 4.0+

## How to Use

```Swift
//Set example String.
let statusString: String = "Example tweet text here. Don't you just love AppKit? Here's a reference to @Twitter. Check out this cool new site: https://www.apple.com #hashtag #tutorial #中文测试"

let insetRect = CGRect(x: 0, y: 0, width: 480, height: 270)
let statusView = TweetTextView(frame: insetRect)

//You must set usernameTextColor's value before statusString.
statusView.usernameTextColor = NSColor.red
//You must set linkTextColor's value before statusString.
statusView.linkTextColor = NSColor.purple  
//You must set hashtagTextColor's value before statusString.
statusView.hashtagTextColor = NSColor.lightGray 

//You must set usernameTextFont's value before statusString.
statusView.usernameTextFont = NSFont.systemFont(ofSize: 18.0) 
//You must set linkTextFont's value before statusString.
statusView.linkTextFont = NSFont.boldSystemFont(ofSize: 15.0)
//You must set hashtagTextFont's value before statusString.
statusView.hashtagTextFont = NSFont.boldSystemFont(ofSize: 20.0)  

statusView.statusString = statusString

self.view.addSubview(statusView)

//Set statusView's link string click action
statusView.linkTarget = self
statusView.linkAction = #selector(link)

//Set statusView's username string click action
statusView.usernameTarget = self
statusView.usernameAction = #selector(username)

//Set statusView's hashtag string click action
statusView.hashtagTarget = self
statusView.hashtagAction = #selector(hashtag)
```

## Screenshot

![screenshot](/Image/screenshot.png?raw=true "Screenshot")

## Objective-C version

if you use Objective-C,you can use [TweetView-OS-X](https://github.com/JanX2/TweetView-OS-X).

## Thanks for

Some code and idea from [TweetView-OS-X](https://github.com/JanX2/TweetView-OS-X).
I add some code for this.Now can add custom action everywhere when you initialize finish.

Thinks for [@JanX2](https://github.com/JanX2)'s oc code.

