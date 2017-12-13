//
//  cascadeImage.swift
//  Cascade2
//
//  Created by Tony Monckton on 20/11/2017.
//  Copyright © 2017 WeCreate! digital design. All rights reserved.
//

import Foundation
import UIKit

class cascadeImage: UIImageView {
    
    var mImageURL: String       = ""
    var mWidth: CGFloat         = 1.0
    var mHeight: CGFloat        = 1.0
    var mAspectRatio: CGFloat   = 1.0
    var mAddSubView: Bool       = false
    
    var isInView: Bool {
        get             { return mAddSubView }
        set (status)    { mAddSubView = status }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.zPosition        = 10.0
        self.layer.borderWidth      = 0.0
        self.layer.cornerRadius     = 0.0
        self.bounds                 = CGRect(x:0,y:0, width:0, height:0 )
        self.contentMode            = .scaleAspectFit
        self.frame                  = frame
        
        mWidth          = frame.size.width
        mHeight         = frame.size.height
        mAspectRatio    = mWidth/mHeight
    }
    
    init(frame: CGRect, width:CGFloat, height:CGFloat ) {
        super.init(frame: frame)
        
        self.frame                  = frame
        self.layer.zPosition        = 10.0
        self.contentMode            = .center
        
        mWidth          = width
        mHeight         = height
        mAspectRatio    = mWidth/mHeight
    }
    
    func setFrame(frame: CGRect)
    {
        self.frame = frame
        self.contentMode = .scaleToFill
        
        //       print ("frame: ",frame.minX, frame.minY, frame.width, frame.height)
    }
    
    func aspectRatio() -> CGFloat {
        return mAspectRatio
    }
    
    func fade( _duration: Double, _delay: Double, _alpha: Double) {
        UIView.animate(withDuration: _duration, delay: _delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = CGFloat(_alpha)
        }, completion: nil)
    }
}
