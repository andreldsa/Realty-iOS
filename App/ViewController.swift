//
//  ViewController.swift
//  App
//
//  Created by André Abrantes on 28/04/2015.
//  Copyright (c) 2015 André Abrantes. All rights reserved.
//

import UIKit

class SharedDictionary<KeyType : Hashable, ValueType> {
    var imageCache = [KeyType: ValueType]()
    
    func addItem(#key: KeyType, value: ValueType) {
        imageCache[key] = value
    }
    
    func getItem(#key: KeyType) -> ValueType! {
        if let data = imageCache[key] {
            return data
        } else {
            return imageCache[key]
        }
    }

}

class CustomTableViewCell : UITableViewCell {
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    func loadItem(#title: String, image: String, cache: SharedDictionary<String, NSData>) {
        println("loading item: \(title)")

        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFit
        
        titleLabel.text = title
        
        var cached = cache.getItem(key: image)
        if(cached != nil) {
            println("from cache")
            self.backgroundImage.image = UIImage(data: cached)
        } else {
            self.backgroundImage.image = UIImage(named:  "loading.gif")

            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
                let urlString = image
                
                let imgURL: NSURL = NSURL(string: urlString)!
                
                let request: NSURLRequest = NSURLRequest(URL: imgURL)
                let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if !(error? != nil) {
                        self.backgroundImage.image = UIImage(data: data)
                        cache.addItem(key: image, value: data)
                    }
                    else {
                        println("Error: \(error.localizedDescription)")
                    }
                })
            })
        }
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var items: [(title: String, image: String, id: String)] = []
    
    var imageCache = SharedDictionary<String, NSData>()

    override func viewDidLoad() {
        super.viewDidLoad()
        var nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        
        tableView.registerNib(nib, forCellReuseIdentifier: "customCell")
        
        loadData()
    }
    
    func loadData() {
        APIService().getAll {
            (data, error) -> Void in
            
            let results = data["results"]
            for var index = 0; index < results.count; ++index {
                let post = results[index]
                let property = post["realty"][0]
                let type = property["type"]
                let city = property["city"]
                let id = post["_id"]
                let ptitle = post["title"]
                let pimage = property["frontImage"]
                self.items.append(title: "\(ptitle)", image: "\(pimage)", id: "\(id)")
            }
            
            self.tableView.reloadData()
        }
    }

    @IBAction func refresh(sender: AnyObject) {
        self.items = []
        loadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:CustomTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("customCell") as CustomTableViewCell
        
        var (title, image, id) = items[indexPath.row]
        
        cell.loadItem(title: title, image: image, cache: imageCache)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier("showProperty") as ViewShowProperty
        viewController.id = items[indexPath.row].id
        self.showViewController(viewController, sender: viewController)
    }
    
    func tableView(tableView:UITableView!, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat {
        return 240
    }
}

