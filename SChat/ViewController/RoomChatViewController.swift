//
//  RoomChatViewController.swift
//  SChat
//
//  Created by can.khac.nguyen on 6/10/19.
//  Copyright © 2019 Can Khac Nguyen. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RoomChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var currentUser: User!
    var rooms = [Room]()

    private let roomPath = "rooms"
    private var db = Firestore.firestore()
    private var roomListener: ListenerRegistration?
    private var roomReference: CollectionReference {
        return db.collection(roomPath)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // config navigation bar
        title = AppSettings.currentUserName
        let addRoomButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddRoomButtonClicked))
        navigationItem.rightBarButtonItem = addRoomButton
        let signOutButton = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(onSignOutButtonClicked))
        navigationItem.leftBarButtonItem = signOutButton

        //register listener
        roomListener = roomReference.addSnapshotListener({[weak self] (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }

            snapshot.documentChanges.forEach { change in
                self?.handleDocumentChange(change: change)
            }
        })
    }

    // MARK: Navigation bar button action
    @objc func onAddRoomButtonClicked() {

    }

    @objc func onSignOutButtonClicked() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    // MARK: handle action
    func handleDocumentChange(change: DocumentChange) {
        guard let roomChange = Room(document: change.document) else {
            return
        }
        switch change.type {
        case .added:
            handleRoomAdded(roomChange)
        case .removed:
            handleRoomDeleted(roomChange)
        default:
            handleRoomModified(roomChange)
        }
    }

    func handleRoomAdded(_ room: Room) {
        guard !rooms.contains(room) else {
            return
        }

        rooms.append(room)
        rooms.sort()

        guard let index = rooms.index(of: room) else {
            return
        }
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    func handleRoomDeleted(_ room: Room) {
        guard let index = rooms.index(of: room) else {
            return
        }

        rooms.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    func handleRoomModified(_ room: Room) {
        guard let index = rooms.index(of: room) else {
            return
        }

        rooms[index] = room
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

}

// MARK: TableViewDataSource
extension RoomChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = rooms[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
}

// MARK: TableViewDelegate
extension RoomChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // do sthg
    }
}
