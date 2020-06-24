//
//  DetailViewController.swift
//  NotesApp
//
//  Created by Danny Vo on 2020-06-21.
//  Copyright © 2020 Danny Vo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var paragraph: UITextView!
    @IBOutlet var toolbar: UIToolbar!
    
    @IBAction func trash(_ sender: Any) {
        note?.body = ""
        navigationController?.popToRootViewController(animated: true)
    }
    
    var note: Note?
    var i: Int?
    let shareItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
    let dismissKeyboard = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(keyboardWillDismiss))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        self.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        paragraph.delegate = self // used to see text changed in UITextView
        paragraph.font = .systemFont(ofSize: 15)
        
        if let noteLoad = note {
            paragraph.text = noteLoad.body
        }
        
        navigationItem.rightBarButtonItem = shareItem
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        note?.body = textView.text
    }
    
    @objc func adjustForKeyboard(notification: Notification){
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        let keyboardScreenFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            paragraph.contentInset = .zero
        } else {
            paragraph.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        paragraph.scrollIndicatorInsets = paragraph.contentInset
        
        let selectedRange = paragraph.selectedRange
        paragraph.scrollRangeToVisible(selectedRange)
    }
    
    @objc func share() {
        let text = paragraph.text
        
        let textToShare = [text]
        let ac = UIActivityViewController(activityItems: textToShare as [Any], applicationActivities: nil)
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(ac, animated: true)
    }
    
    @objc func keyboardWillDismiss() {
        self.view.endEditing(true)
        navigationItem.rightBarButtonItems = nil
        navigationItem.rightBarButtonItem = shareItem
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItems = [dismissKeyboard, shareItem]
    }

}
