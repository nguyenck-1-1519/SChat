//
//  BubbleChatView.swift
//  SChat
//
//  Created by Can Khac Nguyen on 6/1/19.
//  Copyright © 2019 Can Khac Nguyen. All rights reserved.
//

import Foundation
import UIKit

class SBubbleChatView: UIView {
    
    var emojiImageView: UIImageView?
    var imageViewBG: UIImageView?
    var messageLabel: UILabel?
    var messageFont = UIFont.systemFont(ofSize: 14)
    let paddingContent: CGFloat = 10
    static let maxWidthRatioFrame: CGFloat = 0.65
    static let sidePaddingRatio: CGFloat = 0.1 // minX friend bb view
    
    /**
     Initializes bubble view
     
     :param: message        message Data
     :param: startY         start Y point of the chat bubble frame in parent view
     
     :returns: Chat Bubble
     */
    
    init(message: SMessage, startY: CGFloat) {
        let isMine = message.isMine
        super.init(frame: SBubbleChatView.getMaxFrame(isMine: isMine, startY: startY))
        
        self.backgroundColor = UIColor.clear
        
        // init emoji if have
        if let emojiImage = message.emoji {
            let width: CGFloat = min(emojiImage.size.width, self.frame.width - 2  * paddingContent)
            let height: CGFloat = max(emojiImage.size.height, self.frame.height - 2 * paddingContent)
            emojiImageView = UIImageView(frame: CGRect(x: paddingContent, y: paddingContent, width: width, height: height))
            emojiImageView?.image = emojiImage
            emojiImageView?.layer.cornerRadius = 5.0
            emojiImageView?.layer.masksToBounds = true
            if let imageView = emojiImageView {
                self.addSubview(imageView)
            }
        }
        
        // init content if have
        if !message.content.isEmpty {
            messageLabel = UILabel(frame: CGRect(x: paddingContent,
                                                 y: paddingContent,
                                                 width: self.frame.width - 2 * paddingContent,
                                                 height: 10))
            messageLabel?.text = message.content
            messageLabel?.numberOfLines = 0
            messageLabel?.font = messageFont
            messageLabel?.sizeToFit()
            if let label = messageLabel {
                self.addSubview(label)
            }
        }
        
        // resize frame of bubble chat
        var resizedWidth: CGFloat = 0
        var resizedHeight: CGFloat = 0
        if let emojiImageView = emojiImageView {
            resizedWidth = min(self.frame.width, emojiImageView.frame.maxX + paddingContent)
            resizedHeight = max(self.frame.height, emojiImageView.frame.maxY + paddingContent)
        } else if let messageLabel = messageLabel {
            resizedWidth = min(self.frame.width, messageLabel.frame.maxX + paddingContent)
            resizedHeight = max(self.frame.height, messageLabel.frame.maxY + paddingContent)
        }
        let screenWidth = UIScreen.main.bounds.width
        let sidePadding = SBubbleChatView.sidePaddingRatio
        self.frame = CGRect(x: isMine ? screenWidth * (1 - sidePadding) - resizedWidth : screenWidth * sidePadding,
                            y: startY,
                            width: resizedWidth,
                            height: resizedHeight)
        
        // add bubble image
        let bubbleImage = isMine ? #imageLiteral(resourceName: "bubble_mine") : #imageLiteral(resourceName: "bubble")
        let bubbleImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        if isMine {
            bubbleImageView.image = bubbleImage.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21,
                                                                                           bottom: 17, right: 21))
        } else {
            bubbleImageView.image = bubbleImage.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21,
                                                                                           bottom: 21, right: 17))
        }
        self.addSubview(bubbleImageView)
        self.sendSubviewToBack(bubbleImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func getMaxFrame(isMine: Bool, startY: CGFloat) -> CGRect {
        let screenWidth = UIScreen.main.bounds.width
        let maxWidth = screenWidth * maxWidthRatioFrame
        let startX = isMine ? screenWidth * (1.0 - sidePaddingRatio) - maxWidth : screenWidth * sidePaddingRatio
        return CGRect(x: startX, y: startY, width: maxWidth, height: 22)
    }
}
