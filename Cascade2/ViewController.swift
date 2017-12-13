//
//  ViewController.swift
//  Cascade2
//
//  Created by Tony Monckton on 13/11/2017.
//  Copyright © 2017 WeCreate! digital design. All rights reserved.
//

import UIKit

class cascadeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var cascadeViewObj: [cascadeUIView]!

    var mCascadeView: cascadeUIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mCascadeView = cascadeUIView(frame: UIScreen.main.bounds)
        
        
        
        let api = restAPIManager()

        api.httpRequest(url: "http://www.tonymonckton.co.uk/cascade")
        
        
        api.Logout(requestURL: "http://www.tonymonckton.co.uk/cascade") { success in
            print (success)
    }

        api.createRequest( requestURL: "http://www.tonymonckton.co.uk/cascade") { output in
            
        print ("createRequest:", output)
//        let jsonSerialized = try JSONSerialization.jsonObject(with: output , options: []) as? JSONDictionary
           // let data: Data = output as S
           // let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
            
        }

        
        
        
        let jsonSerialized: JSONDictionary? = api.httpRequestSynchronous( _url: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY")
        
        if jsonSerialized != nil {
            let json = jsonSerialized
            let url = json?["url"]
            let explanation = json?["explanation"]
            
            print(url!)
            print(explanation!)
        }
    }
    
    func refresh(sender:AnyObject) {
        
        mCascadeView?.show(numPerRow:2, duration: 0.8, delay: 0.2)
        print ("refresh tapped")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.addSubview(mCascadeView!)
        
        mCascadeView?.viewWillAppear()
        mCascadeView?.show(numPerRow:2, duration: 0.8, delay: 0.2)
    }
        
    override var prefersStatusBarHidden: Bool {
        return true
    }  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

