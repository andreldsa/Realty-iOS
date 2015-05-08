//
//  APIService.swift
//  RealtyApp
//
//  Created by André Abrantes on 23/03/2015.
//  Copyright (c) 2015 André Abrantes. All rights reserved.
//

import Foundation

extension NSMutableURLRequest {
    func setBodyContent(contentMap: Dictionary<String, String>) {
        var contentBodyAsString = String()
        var firstOneAdded = false
        let contentKeys:Array<String> = Array(contentMap.keys)
        for contentKey in contentKeys {
            if(!firstOneAdded) {
                contentBodyAsString += contentKey + "=" + contentMap[contentKey]!
                firstOneAdded = true
            }
            else {
                contentBodyAsString += "&" + contentKey + "=" + contentMap[contentKey]!
            }
        }
        contentBodyAsString = contentBodyAsString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        self.HTTPBody = contentBodyAsString.dataUsingEncoding(NSUTF8StringEncoding)
    }
}

class APIService: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    
    let API_KEY = "003d8ed40432044e7394131e09f8ad9fc57cd55d"
    let APP_ID = "5538a255bcec4a702a24bb59"
    let URL = "http://192.168.213.1:9000/api/posts" // IP VIRTUAL MACHINE - VMWARE
    
    typealias CallbackBlock = (result: String, error: String?) -> ()
    
    var callback: CallbackBlock = {
        (resultString, error) -> Void in
        if error == nil {
            println(resultString)
        } else {
            println(error)
        }
    }
    
    func getOne(id: String, callBack: (JSON,String?) -> Void) {
        makeRequest("\(URL)/\(id)", body: nil, post: false, callback: callBack)
    }
    
    func getAll(criteria: String, callback: (JSON,
        String?) -> Void) {
            if(criteria == "") {
                makeRequest(URL, body: nil, post: false, callback: callback)
            } else {
                let search = criteria.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                makeRequest("\(URL)?title=\(search)", body: nil, post: false, callback: callback)
            }
    }
    
    func postComment(body: Dictionary<String, String>, callBack: (JSON,String?) -> Void) {
        let id = body["id"]
        makeRequest(URL+"/\(id!)"+"/comments", body: body, post: true, callback: callBack)
    }
    
    func makeRequest(url: String, body: Dictionary<String, String>?, post: Bool, callback: (JSON, String?) -> Void)  {
        var request = NSMutableURLRequest(URL: NSURL(string: url )!)
        if(post) {
            var err: NSError?
            request.HTTPMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setBodyContent(body!)
        }
        request.addValue(API_KEY, forHTTPHeaderField: "x-api-key")
        request.addValue(APP_ID, forHTTPHeaderField: "x-application-id")
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration,
            delegate: self,
            delegateQueue:NSOperationQueue.mainQueue())
        var task = session.dataTaskWithRequest(request){
            (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if error != nil {
                callback("", error.localizedDescription)
            } else {
                var err: NSError? = error
                if(data.length > 0) {
                    let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
                    let result = JSON(json)
                    callback(result, nil)
                }else {
                    callback(nil, nil)
                }
                
                
            }
        }
        task.resume()
    }
    
    func URLSession(session: NSURLSession,
        didReceiveChallenge challenge:
        NSURLAuthenticationChallenge,
        completionHandler:
        (NSURLSessionAuthChallengeDisposition,
        NSURLCredential!) -> Void) {
            completionHandler(
                NSURLSessionAuthChallengeDisposition.UseCredential,
                NSURLCredential(forTrust:
                    challenge.protectionSpace.serverTrust))
    }
    
    func URLSession(session: NSURLSession,
        task: NSURLSessionTask,
        willPerformHTTPRedirection response:
        NSHTTPURLResponse,
        newRequest request: NSURLRequest,
        completionHandler: (NSURLRequest!) -> Void) {
            var newRequest : NSURLRequest? = request
            println(newRequest?.description);
            completionHandler(newRequest)
    }
}