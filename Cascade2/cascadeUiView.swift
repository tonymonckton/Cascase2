//
//  cascadeView.swift
//  Cascade2
//
//  Created by Tony Monckton on 14/11/2017.
//  Copyright © 2017 WeCreate! digital design. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class cascadeUIView: UIView, UIScrollViewDelegate {

    @IBInspectable var showDuration: CGFloat    = 0.8
    @IBInspectable var showDelay: CGFloat       = 0.2
    
    enum orentation: Int {
        case undefined = 0
        case portrait = 1
        case landscape = 2
    }
    
    let refreshControl              = UIRefreshControl()
    
    var mOrentation                 = orentation.portrait
    var mFrame: CGRect              = CGRect.zero
    var mFramePortrait: CGRect      = CGRect.zero
    var mFrameLandscape: CGRect     = CGRect.zero
    var mFramePortraitImgs: Int     = 2
    var mFrameLandscapeImgs: Int    = 3
    var mFrameImgs: Int             = 2
    
    var prefix:String       = "Image"
    var totalImages:Int     = 12
    
    var screenSize          = UIScreen.main.bounds
    var screenWidth         = UIScreen.main.bounds.size.width
    var screenHeight        = UIScreen.main.bounds.size.height
    var mImages: [cascadeImage]!
    
    var scrollView:UIScrollView?
    
private var notification: NSObjectProtocol?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)

        self.frame      = frame
        mFramePortrait  = CGRect(x:0, y:0, width: screenWidth, height: screenHeight)
        mFrameLandscape = CGRect(x:0, y:0, width: screenHeight, height: screenWidth)
        mFrame          = mFramePortrait
        mImages         = []

        // setup scrollView
        scrollView  = UIScrollView()

        updateScrollView()
        initScrollView()
        setupGestureRecognizer()

        // setup mImages
        for i in 0...totalImages-1 {
            let imgName     = prefix+String(i+1)
            let image       = UIImage(named: imgName)
            
            if (image != nil)
            {
                let imageWidth:Int  = Int(image!.size.width)
                let imageHeight:Int = Int(image!.size.height)
                let cImage          = cascadeImage(frame:CGRect(x:0, y:0, width:imageWidth, height:imageHeight))
                cImage.image        = image
                mImages.append(cImage)
                print ("image /(i) w,h:", imageWidth, imageHeight )
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        if let notification = notification {
            NotificationCenter.default.removeObserver(notification)
        }
    }
    
    // call from viewController.viewWillAppear
    func viewWillAppear()
    {
        self.addSubview(scrollView!)
        
        // add refresh control once.
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        scrollView?.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        notification = NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) {
            [unowned self] notification in
            print(">>>>>>active")
            self.show(numPerRow: self.numPerRow(), duration: self.showDuration, delay: self.showDelay)
        }
    }
    
    // scrollView
    
    func initScrollView()
    {
        scrollView?.delegate         = self
        scrollView?.tag              = 101
        scrollView?.bounces          = true
        scrollView?.layer.borderWidth = 0.0
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.isPagingEnabled  = false
        scrollView?.contentSize      = CGSize(width: mFrame.width, height: mFrame.height)
        scrollView?.frame            = mFrame
        
        // zoom
        let scrollViewSize:CGSize  = (scrollView?.bounds.size)!
        let imageViewSize:CGSize   = mFrame.size
        let widthScale      = scrollViewSize.width  / imageViewSize.width
        let heightScale     = scrollViewSize.height / imageViewSize.height
        
        scrollView?.minimumZoomScale = min(widthScale, heightScale)
        scrollView?.zoomScale = 1.0
    }

    func updateScrollView()
    {
        screenSize = UIScreen.main.bounds
        
        switch currentOrentation() {
            case orentation.portrait:
                mOrentation         = orentation.portrait
                mFrame              = mFramePortrait
                mFrameImgs          = mFramePortraitImgs
                scrollView?.frame   = mFrame
                self.frame          = mFrame
            
            case orentation.landscape:
                mOrentation         = orentation.landscape;
                mFrame              = mFrameLandscape
                mFrameImgs          = mFrameLandscapeImgs
                scrollView?.frame   = mFrame
                self.frame          = mFrame
            
            case orentation.undefined:
                print( "updateScrollView::currentOrentation:", orentation.undefined)
        }
        
    }

    // Orentation and refresh

    func currentOrentation() -> orentation
    {
        var ret: orentation = orentation.undefined
        
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            ret = orentation.landscape
        }
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            ret = orentation.portrait
        }
        
        return ret
    }
    
    func numPerRow() -> Int
    {
        var n = 0
        
        switch currentOrentation() {
        case orentation.portrait:
                n = mFramePortraitImgs
        case orentation.landscape:
            n = mFrameLandscapeImgs
        default:
            n = 1
        }
        
        return n
    }
    
    func rotated() {
        print ("rotated()")
        let origOrentation   = mOrentation
        let currOrentation   = currentOrentation()

        // only show when orentation changes
        if ( currOrentation != orentation.undefined ) {
            if origOrentation != currOrentation {
                print ("orentation change: from ",origOrentation," to ", currOrentation)
                show(numPerRow: numPerRow(), duration: showDuration, delay: showDelay)
            }
        }
    }

    func refresh(sender:AnyObject) {
        show(numPerRow: mFrameImgs, duration: showDuration, delay: showDelay)
        refreshControl.endRefreshing()
    }
    
    // Gestures

    private func setupGestureRecognizer() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        scrollView?.addGestureRecognizer(singleTap)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(sender:)))
        
        scrollView?.addGestureRecognizer(pinchGesture)
    }
    
    func pinchAction(sender:UIPinchGestureRecognizer) {
        if sender.state == .ended {
            print ("pinchEnd: ", sender.scale )
            var delta:Int = 1
            if sender.scale < 1.0 { delta = -1 }
            
            if ( mOrentation == orentation.portrait ) {
                if (mFramePortraitImgs+delta) > 0 {
                    mFramePortraitImgs += delta
                    mFrameImgs = mFramePortraitImgs
                    
                    show(numPerRow: mFramePortraitImgs, duration: showDuration, delay: showDelay)
                }
            }
            if ( mOrentation == orentation.landscape ) {
                if (mFrameLandscapeImgs+delta) > 0 {
                    mFrameLandscapeImgs += delta
                    mFrameImgs = mFramePortraitImgs
                    
                    show(numPerRow: mFrameLandscapeImgs, duration: showDuration, delay: showDelay)
                }
            }
        }
    }
    
    func handleSingleTap(_ sender: UITapGestureRecognizer) {
        print("Single tap", mFrameImgs)
    }
    
    // draw images
    
    func show(numPerRow: Int, duration: CGFloat, delay: CGFloat)
    {
        print ("show:", numPerRow)
        var ypos:Int        = 0
        let totalRow:Double = (Double(mImages.count)/Double(numPerRow))-1.0
        let tRow:Int        = Int(ceil(totalRow))
     
        updateScrollView()
        
        var rowHeight:Int = 0
        for row in 0...tRow {
            rowHeight = calRowHeight( view: scrollView!, ypos: ypos, row:row, numPerRow:numPerRow)
            ypos += rowHeight
        }
        
        scrollView?.contentSize = CGSize(width: Int(mFrame.width), height: ypos)
        
        // hide photos (for refresh)
        for img in mImages {
            img.alpha = CGFloat(0.0)
        }
        
        // fade in images
        var delay2:CGFloat = 0.0
        for img in mImages {
            img.fade(_duration: Double(showDuration), _delay: Double(delay2), _alpha:1.0)
            delay2 += showDelay
        }
    }
    
    func calRowHeight( view: UIView, ypos: Int, row: Int, numPerRow: Int ) -> Int
    {
        let targetHeight:CGFloat    = 4000.0
        var rowWidth:CGFloat        = 0.0;
        var scale:CGFloat           = 1.0;
        var imgWidth:CGFloat        = 0.0;
        
        // get images for row...
        let index       = row*numPerRow
        var numInRow    = (mImages.count - index)

        if (numInRow > numPerRow) { numInRow = numPerRow }
        let indexEnd    = (index+numInRow)-1

        rowWidth = 0.0
        for i in index...(indexEnd) {
            let img = mImages[i]
            imgWidth = targetHeight * img.aspectRatio()
            rowWidth += imgWidth
        }
        
        scale = rowWidth/mFrame.width

        var xpos:CGFloat = 0.0
        let h1 = targetHeight/scale
        
        for i in index...(indexEnd) {
            let img = mImages[i]
            let w  = targetHeight * img.aspectRatio()
            let w1 = w/scale
            
            let frame: CGRect = CGRect(x: xpos, y: CGFloat(ypos), width: w1, height: h1)
            mImages[i].setFrame(frame:frame)
            mImages[i].alpha = CGFloat(0.0)
            
            if img.isInView == false {
                view.addSubview(mImages[i])
                img.isInView = true
                print ("addSubview image:",i)
            }
            xpos += w1
        }
        return Int(h1)
    }    
}
