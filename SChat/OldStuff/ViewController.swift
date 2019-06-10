//
//  ViewController.swift
//  SChat
//
//  Created by Can Khac Nguyen on 6/1/19.
//  Copyright © 2019 Can Khac Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    var messageData = [SMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let outMessage = SMessage(content: "Try to lock me in this cage, I won't just lay me down and die, I will take these broken wings, And watch me burn across the sky ", date: Date())
        let inMessage = SMessage(content: "", isMine: false, date: Date(), emoji: #imageLiteral(resourceName: "imageViewTest"))
        messageData.append(outMessage)
        messageData.append(inMessage)
    }
    
    @IBAction func onTextFieldEditingChanged(_ sender: UITextField) {
        if let text = textField.text, !text.isEmpty {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
        
    }
    @IBAction func onSendButtonClicked(_ sender: UIButton) {
        let rand = Int.random(in: 1...2)
        if rand == 1 {
            guard let messText = textField.text else {
                return
            }
            let message = SMessage(content: messText, date: Date())
            messageData.append(message)
        } else {
            guard let messText = textField.text else {
                return
            }
            let message = SMessage(content: messText, isMine: false, date: Date())
            messageData.append(message)
        }
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: messageData.count - 1, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as? MessageTableViewCell else {
            return UITableViewCell()
        }
        let message = messageData[indexPath.row]
        cell.messageView.addSubview(SBubbleChatView(message: message, startY: 0))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messageData[indexPath.row]
        let bubbleView = SBubbleChatView(message: message, startY: 0)
        return bubbleView.frame.height + 10;
    }
}
