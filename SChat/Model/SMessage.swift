//
//  SMessage.swift
//  SChat
//
//  Created by Can Khac Nguyen on 6/1/19.
//  Copyright © 2019 Can Khac Nguyen. All rights reserved.
//

import Foundation
import UIKit

class SMessage {
    public let content: String
    public let isMine: Bool
    public let date: Date
    public let emoji: UIImage?
    
    init(content: String, isMine: Bool = true, date: Date, emoji: UIImage? = nil) {
        self.content = content;
        self.isMine = isMine;
        self.date = date;
        self.emoji = emoji;
    }
}
