//
//  Room.swift
//  SChat
//
//  Created by can.khac.nguyen on 6/10/19.
//  Copyright © 2019 Can Khac Nguyen. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Room {
    let id: String?
    let name: String

    init(name: String) {
        self.id = nil
        self.name = name
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let name = data["name"] as? String else {
            return nil
        }
        self.name = name
        self.id = document.documentID
    }
}

extension Room: DataReference {
    var representation: [String : Any] {
        var rep = ["name": name]
        
        if let id = id {
            rep["id"] = id
        }
        
        return rep
    }
}

extension Room: Comparable {
    static func < (lhs: Room, rhs: Room) -> Bool {
        return lhs.name < rhs.name
    }

    static func  == (lhs: Room, rhs: Room) -> Bool {
        return lhs.id == rhs.id
    }
}
