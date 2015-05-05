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
    @IBOutlet var desc: UILabel!
    
    func loadItem(#title: String, image: String, desc: String, cache: SharedDictionary<String, NSData>) {
        self.backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.titleLabel.text = title
        self.desc.text = desc
        
        var cached = cache.getItem(key: image)
        if(cached != nil) {
            self.backgroundImage.image = UIImage(data: cached)
            self.backgroundImage.layer.cornerRadius = (self.backgroundImage.frame.height/2)
            self.backgroundImage.clipsToBounds = true
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
                        self.backgroundImage.layer.cornerRadius = (self.backgroundImage.frame.height/2)
                        self.backgroundImage.clipsToBounds = true
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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var search: UISearchBar!
    
    var clicked = false
    
    var items: [(title: String, image: String, desc: String, id: String)] = []
    
    var imageCache = SharedDictionary<String, NSData>()
    
    var resultSearchController = UISearchController()

    override func viewDidAppear(animated: Bool) {
        loadData("")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        
        tableView.registerNib(nib, forCellReuseIdentifier: "customCell")
        

        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.showsSearchResultsButton = true
            controller.searchBar.searchBarStyle = UISearchBarStyle.Minimal
            
            self.tableView.tableHeaderView = controller.searchBar
            
            controller.searchBar.delegate = self
            
            return controller
        })()
    }
    
    func loadData(criteria: String) {
        self.items = []
        APIService().getAll(criteria) {
            (data, error) -> Void in
            
            let results = data["results"]
            
            if(results.count == 0) {
                self.showAlert()
            }
            
            for var index = 0; index < results.count; ++index {
                let post = results[index]
                let property = post["realty"][0]
                let type = property["type"]
                let city = property["city"]
                let id = post["_id"]
                let ptitle = post["title"]
                let pdesc = post["description"]
                let pimage = property["frontImage"]
                self.items.append(title: "\(ptitle)", image: "\(pimage)", desc: "\(pdesc)", id: "\(id)")
            }
            
            self.tableView.reloadData()
        }
    }
    
    func showAlert() {
        let alert = UIAlertView()
        alert.title = "Alert"
        alert.message = "Nothing was found."
        alert.addButtonWithTitle("Ok")
        alert.show()
    }

    @IBAction func refresh(sender: AnyObject) {
        loadData("")
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
        
        var (title, image, desc, id) = items[indexPath.row]
        
        cell.loadItem(title: title, image: image, desc: desc, cache: imageCache)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier("showProperty") as ViewShowProperty
        viewController.id = items[indexPath.row].id
        
        self.resultSearchController.active = false
        
        self.showViewController(viewController, sender: viewController)
    }
    
    func tableView(tableView:UITableView!, heightForRowAtIndexPath indexPath:NSIndexPath)->CGFloat {
        return 90
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if(self.clicked) {
            loadData(searchController.searchBar.text)
            self.clicked = false
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.clicked = true
        self.updateSearchResultsForSearchController(resultSearchController)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.loadData("")
    }
}

