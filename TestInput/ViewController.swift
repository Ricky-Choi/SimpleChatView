//
//  ViewController.swift
//  TestInput
//
//  Created by ricky on 2021/07/13.
//

import UIKit

class ViewController: UIViewController {
    
    let tempInputViewController = UIInputViewController()
    let chatInputView = ChatInputAccessoryView(frame: .zero, inputViewStyle: .default)
    
    var data: [String] = (0...30).map { String($0) }
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set main scroll view
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Plain")
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
        
        tableView.keyboardDismissMode = .interactive
        
        self.tableView = tableView
        
        // keyboard observing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // action
        chatInputView.sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
    }
    
    // input view

    override var canBecomeFirstResponder: Bool {
        true
    }
    
    override var inputAccessoryViewController: UIInputViewController? {
        tempInputViewController.inputView = chatInputView
        return tempInputViewController
    }
    
    // keyboard occulusion
    
    @objc func keyboardFrameChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let convertedFrame = view.convert(frame, from: UIScreen.main.coordinateSpace)
        let intersectedKeyboardHeight = view.frame.inset(by: view.layoutMargins).intersection(convertedFrame).height
        
        //
        tableView.contentInset.bottom = intersectedKeyboardHeight
        tableView.verticalScrollIndicatorInsets.bottom = intersectedKeyboardHeight
        
        print(#function, intersectedKeyboardHeight)
    }
    
    // messaging
    
    @objc func didTapSend() {
        let text = chatInputView.expandingTextView.text!
        if !text.isEmpty {
            sendMessage(message: text)
            chatInputView.expandingTextView.text = ""
        }
    }
    
    private func sendMessage(message: String) {
        data.append(message)
        
        let newIndexPath = IndexPath(row: data.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .top)
        tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Plain", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
}
