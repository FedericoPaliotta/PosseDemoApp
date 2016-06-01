//
//  ViewController.swift
//  DemoApp
//
//  Created by Federico Paliotta on 5/25/16.
//  Copyright © 2016 FPC. All rights reserved.
//

import Masonry
import DeviceKit

class ViewController: UIViewController
{

    let dataStore = DataStore.sharedStore()
    
    var textView: UITextView!
    var middleLayer: UIView!
    var getNewLocationsButton: UIButton!
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        let defaultBgColor = UIColor.redColor().colorWithAlphaComponent(0.6)
        let defaultRadius: CGFloat = 5
        let defaultPadding = UIEdgeInsetsMake(8, 8, 8, 8);

        // MARK: textView setup
        textView = UITextView(frame: CGRectZero)
        textView.editable = false
        textView.backgroundColor = defaultBgColor
        textView.layer.cornerRadius = defaultRadius
        textView.textColor = UIColor.whiteColor()
        textView.font = UIFont(name: "AppleColorEmoji", size: 18)
        
        textView.textAlignment = .Center
        textView.userInteractionEnabled = false
        textView.text = 🎁()
        
        view.addSubview(textView)
        
        textView.mas_makeConstraints { make in
            make.edges.equalTo()(self.view).with().insets()(defaultPadding)
        }
        
        // MARK: middleLayer setup
        middleLayer = UIView()
        middleLayer.backgroundColor = defaultBgColor
        middleLayer.layer.cornerRadius = defaultRadius
        middleLayer.alpha = 0
        
        view.addSubview(middleLayer)
        
        middleLayer.mas_makeConstraints { make in
            make.edges.equalTo()(self.view).with().insets()(defaultPadding)
        }
        
        // MARK: getNewLocationsButton setup
        getNewLocationsButton = UIButton(type: .Custom)
        getNewLocationsButton.backgroundColor = UIColor.whiteColor()
        getNewLocationsButton.layer.cornerRadius = defaultRadius
        getNewLocationsButton.layer.borderWidth = 0.3
        getNewLocationsButton.layer.borderColor = defaultBgColor.CGColor
        getNewLocationsButton.setTitle("😎", forState: .Normal)
        
        getNewLocationsButton.addTarget(self,
                                        action: #selector(getNewLocations),
                                        forControlEvents: .TouchUpInside)
        
        view.addSubview(getNewLocationsButton)
        
        getNewLocationsButton.mas_makeConstraints { make in
            make.center.equalTo()(self.view)
        }
    }
    
    func getNewLocations()
    {
        animateTextViewMiddleLayer()
        
        let locations = dataStore.getLocationsData { locations in
            if let locs = locations where locs.count > 0 {
                self.textView.textAlignment = .Left
                self.textView.text = locs.reduce("\n") { descr, loc -> String in
                    return descr + "\(loc.description)\n"
                }
                self.textView.userInteractionEnabled = true
                self.getNewLocationsButton.alpha = 0
            }
            else {
                self.getNewLocationsButton.setTitle("😰", forState: .Normal)
                self.textView.textAlignment = .Center
                self.textView.text = "\n\n\nOoops... ☹ \n"
                                   + "Looks like you aren't "
                                   + "connected to the internet !"
            }
        }
        
        if locations == nil || locations?.count == 0
        {
            dataStore.refetchData()
        }
    }
    
    private func animateTextViewMiddleLayer ()
    {
        UIView.animateWithDuration(0.2, animations: {
            self.textView.alpha = 0
            self.middleLayer.alpha = 1
            })
        { finished in
            if finished {
                self.middleLayer.alpha = 0
                self.textView.alpha = 1
            }
        }
    }
    
    private func 🎁() -> String
    {
        let lol = "♧♡♔♘☀︎☺︎☫⚉✌︎☕︎❖❀✽✾❦❤︎✰❧❂◀︎▲△✷▽▷▴✤☛✇⚓︎✈︎☉♧♐︎"
        var 👻 = ""
        
        let bound = UInt32(lol.characters.count)
        
        let mult = multiplier4Device
        
        for i in 0..<Int(42.0 * mult)
        {
            var q: Double
            
            if (i % 2) == 0 { q = 6 }
            else {  q = 5 }
            
            let t = Int(q * mult)
            
            for _ in 0..<t
            {
                let idx = lol.startIndex.advancedBy(Int(arc4random_uniform(bound)))
                let rand = lol[idx]
                    👻 += " \(rand) "
            }
            👻 += "\n"
        }
        return 👻
    }
    
    private var multiplier4Device: Double {
        let device = Device()
        print(device.model)
        let smallerDevs: [Device] = [.iPhone5, .iPhone5s]
        
        var mult = 1.0
        
        if device.isPad { mult = 2 }
        
        // These two won't work on simulator...
        if device.isOneOf(smallerDevs) { mult = 0.4 }
        if device.isOneOf([.iPadPro]) { mult = 3 }

        return mult
    }
}

