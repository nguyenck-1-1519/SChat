//
//  Message.swift
//  SChat
//
//  Created by can.khac.nguyen on 6/10/19.
//  Copyright © 2019 Can Khac Nguyen. All rights reserved.
//

import Foundation
import MessageKit
import FirebaseAuth
import FirebaseFirestore

struct Message: MessageType {
    
    var kind: MessageKind {
        return .text(content ?? "")
    }
    
    var sender: Sender
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    let id: String?
    var content: String?
    var sentDate: Date
    let senderId: String
    let senderName: String

    init(user: User, content: String) {
        sender = Sender(id: user.uid, displayName: AppSettings.currentUserName)
        self.content = content
        sentDate = Date()
        senderId = user.uid
        senderName = AppSettings.currentUserName
        id = nil
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let content = data["content"] as? String, let timestamp = data["created"] as? Date,
            let senderId = data["senderId"] as? String, let senderName = data["senderName"] as? String else {
            return nil
        }
        self.content = content
        self.sentDate = timestamp
        self.senderId = senderId
        self.senderName = senderName
        self.id = document.documentID
        self.sender = Sender(id: senderId, displayName: AppSettings.currentUserName)
    }
}

extension Message: DataReference {
    var representation: [String : Any] {
        let rep: [String : Any] = [
            "created": sentDate,
            "senderId": sender.id,
            "senderName": sender.displayName,
            "content": content
        ]
        
        return rep
    }
}

extension Message: Comparable {
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}
