//
//  ViewSendComment.swift
//  App
//
//  Created by André Abrantes on 07/05/2015.
//  Copyright (c) 2015 André Abrantes. All rights reserved.
//

import Foundation
import UIKit

class ViewSendComment: UIViewController, UITextViewDelegate{
    
    @IBOutlet var name: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var comment: UITextView!
    
    var id = String();

    func showAlert(title: String,value: String) {
        let alert = UIAlertView()
        alert.title = title
        alert.message = value
        alert.addButtonWithTitle("Close")
        alert.show()
    }
    
    override func viewDidLoad() {
        comment.delegate = self
        comment.text = "Placeholder"
        comment.textColor = UIColor.lightGrayColor()
        
        comment.layer.cornerRadius = 8.0
        comment.layer.masksToBounds = true
        comment.layer.borderColor = UIColor.lightGrayColor().CGColor
        comment.layer.borderWidth = 0.3
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if comment.textColor == UIColor.lightGrayColor() {
            comment.text = nil
            comment.textColor = UIColor.blackColor()
        }
    }
    
    @IBAction func send(sender: AnyObject) {
        if(name.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "") {
            if(email.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != "") {
                var  b = Dictionary<String, String>()
                b["id"] = id
                b["name"] =  name.text
                b["email"] =  email.text
                b["comment"] =  comment.text
                APIService().postComment(b) {
                    (data, error) -> Void in
                    if(error != nil) {
                        self.showAlert("Error", value: error!)
                    } else {
                        self.navigationController?.popViewControllerAnimated(true)
                        self.showAlert("Success", value: "Thank you \(self.name.text), we received your message.")
                    }
                }
                
            } else {
                showAlert("Error", value: "Type your email")
            }
        } else {
            showAlert("Error", value: "Type your name")
        }
    }
}