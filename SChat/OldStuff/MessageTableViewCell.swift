//
//  MessageTableViewCell.swift
//  SChat
//
//  Created by Can Khac Nguyen on 6/1/19.
//  Copyright © 2019 Can Khac Nguyen. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageView: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        for subview in messageView.subviews {
            subview.removeFromSuperview()
        }
    }
}
