//
//  restAPImanager.swift
//  Cascade2
//
//  Created by Tony Monckton on 01/12/2017.
//  Copyright © 2017 WeCreate! digital design. All rights reserved.
//

import Foundation
import CoreData


class coreDataManager {
    static let sharedInstance = coreDataManager()

    var managedObjectContext: NSManagedObjectContext!
    
    func hello() {
        print("hello")
    }
}




//let json = JSONSerialization

typealias JSONDictionary = [String: Any]

class imageData {
    var filename: String    = ""
    var width: Int          = 0
    var height: Int         = 0
}



// async loaf
//-----------------------

/*
    completeLoadAction(urlString: "www.something.com") { (code, obj) in
        print(code)
    }
*/

func completeLoadAction(urlString:String, completion: @escaping (Int, AnyObject?) -> ()) {
    let url = URL(string:urlString.trimmingCharacters(in: .whitespaces))
    let request = URLRequest(url: url!)
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {                                                 // check for fundamental networking error
            print("error=\(error)")
            DispatchQueue.main.async {
                print("Unable to complete, message: The load has been added to the completion queue. This will be processed once there is a connection.")
            }
            let data:Data! = nil
            completion(0, data as AnyObject) // or return an error code
            return
        }
        
        let httpStatus          = response as? HTTPURLResponse
        var httpStatusCode:Int  = (httpStatus?.statusCode)!
        
        let responseString = String(data: data, encoding: .utf8)
        print("responseString = \(responseString)")
        DispatchQueue.main.async {
            print("async load successful")
        }
        completion(httpStatusCode, data as AnyObject)
    }
    task.resume()
    
}


func httpAuthenticate(username:String, password:String) {
}



class restAPIManager {
 
    static let sharedInstance = restAPIManager()

    func callWebService() {
        let config:URLSessionConfiguration  = URLSessionConfiguration.default
        let urlSession:URLSession           = URLSession(configuration: config)
        
        let callURL = URL.init(string: "https://itunes.apple.com/in/rss/newapplications/limit=10/json")
        var request = URLRequest.init(url: callURL!)
        
        request.timeoutInterval = 60.0 // TimeoutInterval in Second
        request.cachePolicy     = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod      = "GET"
        
        let dataTask = urlSession.dataTask(with: request) { (data,response,error) in
            if error != nil{
                return
            }
            do {
                let resultJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                print("Result",resultJson!)
            } catch {
                print("Error -> \(error)")
            }
        }
        dataTask.resume()
    }
    
    
    //----------------------------------------------
    
    
    func httpRequest(url: String) {

        let url = URL(string: url)
        let request = URLRequest(url: url!)
        
        execTask(request: request) { (ok, obj) in
            print("I AM BACK")
        }
    }
    
    
    func execTask(request: URLRequest, taskCallback: @escaping (Bool,
        AnyObject?) -> ()) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        print("THIS LINE IS PRINTED")
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if let data = data {
                print("THIS ONE IS PRINTED, TOO")
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                    taskCallback(true, json as AnyObject?)
                } else {
                    taskCallback(false, json as AnyObject?)
                }
            }
        })
        task.resume()
    }
    
    func httpRequestSync( _url: String ) -> Void
    {
        let url = URL(string: _url)

        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if let data = data {
                
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
                    
                    if let json = jsonSerialized, let url = json["url"], let explanation = json["explanation"] {
                        //print(url)
                        //print(explanation)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }

    }
    
    
    func httpRequestSynchronous( _url: String ) -> JSONDictionary?
    {
        let url = URL(string: _url)
        var ret: JSONDictionary?
    
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
        
            if let data = data {
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
                
                    if let json = jsonSerialized, let url = json["url"], let explanation = json["explanation"] {
                        //print(url)
                        //print(explanation)
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        task.resume()
        
        return ret
    }
    
    func Logout(requestURL: String, completionHandler:@escaping (Bool) -> ()) {
        
        let url = URL(string: requestURL)
        completionHandler(true)
    }
    
    public func createRequest( requestURL: String, completionHandler: @escaping (String) -> ()) {
        let url = URL(string: requestURL)
        let requestTask = URLSession.shared.dataTask(with: url!) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if(error != nil) {
                print("Error: \(error)")
            } else
            {
                let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String!
                
                //send this block to required place
                completionHandler( outputStr! )
            }
        }
        requestTask.resume()
        
        completionHandler(String(""))
    }
    
    
    // URL Session
    
    func httpURLrequest( _url: String) {
 //       let url = URL(string: _url)!
//        let req = NSMutableURLRequest(url:url)
//        let config = URLSessionConfiguration.default
//        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        
//        let task : URLSessionDownloadTask = session.downloadTask(with: req as URLRequest)
//        task.resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten writ: Int64, totalBytesExpectedToWrite exp: Int64) {
        print("downloaded \(100*writ/exp)" as AnyObject)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
    }

    // ...
    
}







