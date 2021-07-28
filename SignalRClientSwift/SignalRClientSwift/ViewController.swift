//
//  ViewController.swift
//  SignalRClientSwift
//
//  Created by Somsak Kaeworasan on 27/6/2564 BE.
//

import UIKit
import SwiftSignalRClient

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var msgTextField: UITextField!
    
    private let serverUrl = "http://0.0.0.0:5000/chat"  // /chat or /chatLongPolling or /chatWebSockets
    private let dispatchQueue = DispatchQueue(label: "hubsamplephone.queue.dispatcheueuq")
    private var chatHubConnectionDelegate: HubConnectionDelegate?
    private var chatHubConnection: HubConnection?
    private var name = ""
    private var messages: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let alert = UIAlertController(title: "Enter your Name", message:"", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField() { textField in textField.placeholder = "Name"}
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            self.name = alert.textFields?.first?.text ?? "John Doe"

            self.chatHubConnectionDelegate = ChatHubConnectionDelegate(controller: self)
            self.chatHubConnection = HubConnectionBuilder(url: URL(string: self.serverUrl)!)
                .withLogging(minLogLevel: .debug)
                .withAutoReconnect()
                .withHubConnectionDelegate(delegate: self.chatHubConnectionDelegate!)
                .build()

            self.chatHubConnection!.on(method: "NewMessage", callback: {(user: String, message: String) in
                print("chatHubConnection \(user): \(message)")
                self.appendMessage(message: "\(user): \(message)")
            })
            self.chatHubConnection!.start()
        }
        alert.addAction(OKAction)
        self.present(alert, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        chatHubConnection?.stop()
    }
    
    @IBAction func sendMsgTouch(_ sender: Any) {
        let message = msgTextField.text
        if message != "" {
            chatHubConnection?.invoke(method: "Broadcast", name, message) { error in
                if let e = error {
                    self.appendMessage(message: "Error: \(e)")
                }
            }
            msgTextField.text = ""
        }
    }
    
    private func appendMessage(message: String) {
        self.dispatchQueue.sync {
            self.messages.append(message)
        }
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .automatic)
        self.tableView.endUpdates()
        self.tableView.scrollToRow(at: IndexPath(item: messages.count-1, section: 0), at: .bottom, animated: true)
    }
    
    fileprivate func connectionDidOpen() {
        self.navigationItem.title = "i am \(self.name)"
    }
}

class ChatHubConnectionDelegate: HubConnectionDelegate {

    weak var controller: ViewController?

    init(controller: ViewController) {
        self.controller = controller
    }

    func connectionDidOpen(hubConnection: HubConnection) {
        controller?.connectionDidOpen()
    }

    func connectionDidFailToOpen(error: Error) {
        print("connectionDidFailToOpen")
    }

    func connectionDidClose(error: Error?) {
        print("connectionDidClose")
    }

    func connectionWillReconnect(error: Error) {
        print("connectionWillReconnect")
    }

    func connectionDidReconnect() {
        print("connectionDidReconnect")
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = -1
        dispatchQueue.sync {
            count = self.messages.count
        }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell
        let row = indexPath.row
        cell.chatLabel.text = messages[row]
        return cell
    }
}

