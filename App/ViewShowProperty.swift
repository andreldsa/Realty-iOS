//
//  ViewShowProperty.swift
//  App
//
//  Created by André Abrantes on 02/05/2015.
//  Copyright (c) 2015 André Abrantes. All rights reserved.
//

import Foundation
import UIKit

class ViewShowProperty: UIViewController {
    
    @IBOutlet var titleProp: UILabel!
    @IBOutlet var frontImage: UIImageView!
    
    var id = String()
    
    override func viewDidLoad() {
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
                let type = property["type"]
                let city = property["city"]
                let pimage = property["frontImage"]
                self.loadImage("\(pimage)")
                println(type)
            }
        }
    }
}