//
//  MKSpotAnimation.swift
//  MKSpot
//
//  Created by Liujh on 16/4/27.
//  Copyright © 2016年 mk.mk. All rights reserved.
//

import Foundation
import UIKit

let PROCESS_DURING = 3.6
let SPOT_DELAY_RATIO = 0.08

let UNIT_RADIUS: CGFloat = 5 //spot半径


class MKPreLoadSpot: UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, color: UIColor) {
        self.init(frame: frame)
        self.layer.cornerRadius = frame.size.width/2.0
        self.backgroundColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class MKPreLoad: UIView{
    
    var spotColor: UIColor = UIColor.blackColor()
    
    private var leftSoptView: MKPreLoadSpot!
    private var rightSoptView: MKPreLoadSpot!
    
    private var movingSoptView1: MKPreLoadSpot!
    private var movingSoptView2: MKPreLoadSpot!
    private var movingSoptView3: MKPreLoadSpot!
    
    private var margin: CGFloat = 0
    private var originX: CGFloat = 0
    private var finalX: CGFloat = 0
    
    
    
    init(){
        super.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        margin = frame.size.width/4
        originX = margin
        finalX = frame.size.width - margin;
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(frame: CGRect, spotColor: UIColor, backgroundColor: UIColor) {
        self.init(frame: frame)
        self.spotColor = spotColor
        self.backgroundColor = backgroundColor
        
        let spotArray = [movingSoptView1,
                         movingSoptView2,
                         movingSoptView3]
        
        //左边固定点
        leftSoptView = MKPreLoadSpot(frame: CGRectMake(originX - UNIT_RADIUS, frame.size.height/2 - UNIT_RADIUS, 2 * UNIT_RADIUS, 2 * UNIT_RADIUS), color: UIColor.greenColor())
        self.addSubview(leftSoptView)
        
        //右边固定点
        rightSoptView = MKPreLoadSpot(frame: CGRectMake(finalX - UNIT_RADIUS, frame.size.height/2 - UNIT_RADIUS, 2 * UNIT_RADIUS, 2 * UNIT_RADIUS), color: UIColor.greenColor())
        self.addSubview(rightSoptView)
        
        for (index,var spot) in spotArray.enumerate(){
            spot = MKPreLoadSpot(frame: leftSoptView.frame, color: UIColor.greenColor());
            self.addSubview(spot)
            
            //添加关键帧动画
            addKeyFrameAnimation(spot, index: index-1)
        }
    }
    
    private func addKeyFrameAnimation(spot: UIView, index: Int){
        let anim = CAKeyframeAnimation(keyPath: "position.x")
        anim.values = [originX, originX, finalX, finalX, originX, originX]
        anim.keyTimes = [0.0, 0.25, 0.35, 0.75, 0.85, 1.0];//sleep 0.4 ratio
        anim.duration = PROCESS_DURING
        anim.repeatCount = MAXFLOAT
        anim.beginTime = CACurrentMediaTime() + Double(index) * SPOT_DELAY_RATIO * PROCESS_DURING
        spot.layer.addAnimation(anim, forKey: "movingAnim");
        CATransaction.begin()
        CATransaction.setDisableActions(true);
        CATransaction.commit()
    }
}