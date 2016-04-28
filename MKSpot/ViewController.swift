//
//  ViewController.swift
//  MKSpot
//
//  Created by Liujh on 16/4/27.
//  Copyright © 2016年 mk.mk. All rights reserved.
//

import UIKit

let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let preLoad = MKPreLoad(frame: CGRectMake(0, 44, SCREEN_WIDTH-100, 200), spotColor: UIColor.greenColor(), backgroundColor: UIColor.lightGrayColor())
        self.view.addSubview(preLoad);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

