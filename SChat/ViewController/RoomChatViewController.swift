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
    var currentRoomAlertController: UIAlertController?

    private let roomPath = "rooms"
    private var db = Firestore.firestore()
    private var roomListener: ListenerRegistration?
    private var roomReference: CollectionReference {
        return db.collection(roomPath)
    }
    
    deinit {
        print("Room View controller deinit")
        roomListener?.remove()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if currentUser == nil {
            currentUser = Auth.auth().currentUser
        }
        // config navigation bar
        title = AppSettings.currentUserName
        let addRoomButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAddRoomButtonClicked))
        navigationItem.rightBarButtonItem = addRoomButton
        let signOutButton = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(onSignOutButtonClicked))
        navigationItem.leftBarButtonItem = signOutButton

        //register listener
        roomListener = roomReference.addSnapshotListener({[weak self] (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error listening for room updates: \(error?.localizedDescription ?? "No error")")
                return
            }

            snapshot.documentChanges.forEach { change in
                self?.handleDocumentChange(change: change)
            }
        })
    }

    // MARK: Navigation bar button action
    @objc func onAddRoomButtonClicked() {
        let ac = UIAlertController(title: "Create a new room", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addTextField { field in
            field.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            field.enablesReturnKeyAutomatically = true
            field.autocapitalizationType = .words
            field.clearButtonMode = .whileEditing
            field.placeholder = "Room name"
            field.returnKeyType = .done
        }

        let createAction = UIAlertAction(title: "Create", style: .default, handler: { [weak self] _ in
            self?.createRoom()
        })
        createAction.isEnabled = false
        ac.addAction(createAction)
        ac.preferredAction = createAction

        present(ac, animated: true) {
            ac.textFields?.first?.becomeFirstResponder()
        }
        currentRoomAlertController = ac
    }

    @objc func onSignOutButtonClicked() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { [weak self] _ in
            do {
                try Auth.auth().signOut()
                self?.onLogOut()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange(_ field: UITextField) {
        guard let ac = currentRoomAlertController else {
            return
        }
        
        ac.preferredAction?.isEnabled = field.hasText
    }
    
    func onLogOut() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
            window.rootViewController = vc
        }
    }

    // MARK: handle firestore action
    func createRoom() {
        guard let ac = currentRoomAlertController else {
            return
        }
        
        guard let roomName = ac.textFields?.first?.text else {
            return
        }
        
        let room = Room(name: roomName)
        roomReference.addDocument(data: room.representation) { error in
            if let e = error {
                print("Error saving room: \(e.localizedDescription)")
            }
        }
    }
    
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
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else {
            return
        }
        vc.user = currentUser
        vc.room = rooms[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
