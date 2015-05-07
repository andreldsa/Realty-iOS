//
//  ViewShowProperty.swift
//  App
//
//  Created by André Abrantes on 02/05/2015.
//  Copyright (c) 2015 André Abrantes. All rights reserved.
//

import Foundation
import UIKit

class CustomTablePropertyCell : UITableViewCell {

    @IBOutlet var key: UILabel!
    @IBOutlet var value: UILabel!
    
    func loadItem(#key: String, value: String) {
        self.key.text = key
        self.value.text = value
    }
}

class ViewShowProperty: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var titleProp: UILabel!
    @IBOutlet var frontImage: UIImageView!
    @IBOutlet var tableView: UITableView!
    
    var items: [(key: String, value: String)] = []
    var id = String()
    
    override func viewDidLoad() {
        var nib = UINib(nibName: "CustomTablePropertyCell", bundle: nil)
        
        tableView.registerNib(nib, forCellReuseIdentifier: "customPropertyCell")
        
        loadData()
    }
    
    func loadImage(image: String) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let urlString = image
            
            let imgURL: NSURL = NSURL(string: urlString)!
            
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if !(error? != nil) {
                    self.frontImage.image = UIImage(data: data)
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
        })
    }
    
    func loadData() {
        APIService().getOne(self.id) {
            (data, error) -> Void in
            let post = data
            if(post != nil) {
                let postT = post["title"]
                self.titleProp.text = "\(postT)"
                let property = post["realty"][0]
                let pimage = property["frontImage"]
                self.loadImage("\(pimage)")
                
                let desc = post["description"]
                self.items.append(key: "Description:", value: "\(desc)")
                
                let type = property["type"]
                self.items.append(key: "Type:", value: "\(type)")
                
                let city = property["city"]
                self.items.append(key: "City:", value: "\(city)")
                
                let region = property["region"]
                self.items.append(key: "Region:", value: "\(region)")
                
                let address = property["address"]
                self.items.append(key: "Address:", value: "\(address)")
                
                let owner = property["holder"]
                self.items.append(key: "Owner:", value: "\(owner)")

                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count;
    }
    
    func showAlert(key: String, value: String) {
        let alert = UIAlertView()
        alert.title = key
        alert.message = value
        alert.addButtonWithTitle("Close")
        alert.show()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:CustomTablePropertyCell = self.tableView.dequeueReusableCellWithIdentifier("customPropertyCell") as CustomTablePropertyCell
        
        var (key, value) = items[indexPath.row]
        
        cell.loadItem(key: key, value: value)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var (key, value) = items[indexPath.row]
        self.showAlert(key, value: value)
    }
    
    func tableView(tableView:UITableView!, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat {
        return 60
    }

    @IBAction func sendComment(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier("sendComment") as ViewSendComment
        viewController.id = self.id
        self.showViewController(viewController, sender: viewController)
    }
}