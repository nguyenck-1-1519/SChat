//
//  Message.swift
//  SChat
//
//  Created by can.khac.nguyen on 6/10/19.
//  Copyright © 2019 Can Khac Nguyen. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Message {
    let id: String?
    var content: String?
    var createdDate: Date
    let senderId: String
    let senderName: String

    init(content: String, createdDate: Date, senderId: String, senderName: String) {
        self.id = nil
        self.content = content
        self.createdDate = createdDate
        self.senderId = senderId
        self.senderName = senderName
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let content = data["content"] as? String, let createdDate = data["created"] as? Date,
            let senderId = data["senderId"] as? String, let senderName = data["senderName"] as? String else {
            return nil
        }
        self.content = content
        self.createdDate = createdDate
        self.senderId = senderId
        self.senderName = senderName
        self.id = document.documentID
    }
}

extension Message: Comparable {
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.createdDate < rhs.createdDate
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}
