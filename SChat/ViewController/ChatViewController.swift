//
//  ChatViewControler.swift
//  SChat
//
//  Created by Can Khac Nguyen on 6/10/19.
//  Copyright © 2019 Can Khac Nguyen. All rights reserved.
//

import UIKit
import MessageKit
import MessageInputBar
import Firebase
import FirebaseFirestore
import FirebaseAuth

class ChatViewController: MessagesViewController {

    var user: User!
    var room: Room!
    
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    
    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?
    
    deinit {
        print("Chat view deinit")
        messageListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = room.name
        
        guard let id = room.id else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        reference = db.collection(["rooms", id, "thread"].joined(separator: "/"))
        
        messageListener = reference?.addSnapshotListener { [weak self] querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for room updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self?.handleDocumentChange(change)
            }
        }
        
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.keyboardDismissMode = .interactive
    }
    
    // MARK: Handle firestore action
    private func save(_ message: Message) {
        reference?.addDocument(data: message.representation) { [weak self] error in
            if let e = error {
                print("Error sending message: \(e.localizedDescription)")
                return
            }
            
            self?.messagesCollectionView.scrollToBottom()
        }
    }
    
    private func insertNewMessage(_ message: Message) {
        guard !messages.contains(message) else {
            return
        }
        
        messages.append(message)
        messages.sort()
        
        let isLatestMessage = messages.index(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        
        messagesCollectionView.reloadData()
        
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let message = Message(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            insertNewMessage(message)
            
        default:
            break
        }
    }

}

// MARK: Message Input Delegate
extension ChatViewController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let message = Message(user: user, content: text)
        
        save(message)
        inputBar.inputTextView.text = ""
    }
}

// MARK: Message DataSource
extension ChatViewController: MessagesDataSource {
    func currentSender() -> Sender {
        return Sender(id: user.uid, displayName: AppSettings.currentUserName)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.row]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType,
                                    at indexPath: IndexPath) -> NSAttributedString? {
        
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor.lightGray
            ]
        )
    }
}

// MARK: Message Layout delegate
extension ChatViewController: MessagesLayoutDelegate {
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 10)
    }
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
}


// MARK: Message Display delegate
extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .outgoingMessage : .incomingMessage
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return isFromCurrentSender(message: message) ? .bubbleTail(.bottomRight, .curved) : .bubbleTail(.bottomLeft, .curved)
    }
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.image = isFromCurrentSender(message: message) ? #imageLiteral(resourceName: "myAva") :#imageLiteral(resourceName: "frAva")
    }
}
