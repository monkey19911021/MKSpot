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
let ti: CGFloat = 0.03


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
    private var originRearX: CGFloat = 0
    private var finalRearX: CGFloat = 0
    
    private var spotScaleVal1 = NSValue(CATransform3D: CATransform3DMakeScale(1.0, 1.0, 0))
    private var spotScaleVal2 = NSValue(CATransform3D: CATransform3DMakeScale(2.0, 2.0, 0))
    private var spotScaleVal3 = NSValue(CATransform3D: CATransform3DMakeScale(3.0, 3.0, 0))
    private var spotScaleVal4 = NSValue(CATransform3D: CATransform3DMakeScale(4.0, 4.0, 0))
    
    init(){
        super.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        margin = frame.size.width/4
        originX = margin
        finalX = frame.size.width - margin;
        originRearX = originX - 4 * UNIT_RADIUS
        finalRearX = finalX + 4 * UNIT_RADIUS
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
        addLeftSpotAnimation()
        
        //右边固定点
        addRightSpotAnimation()
        
        for (index,var spot) in spotArray.enumerate(){
            spot = MKPreLoadSpot(frame: CGRectMake(originX - UNIT_RADIUS, frame.size.height/2 - UNIT_RADIUS, 2 * UNIT_RADIUS, 2 * UNIT_RADIUS), color: UIColor.greenColor());
            self.addSubview(spot)
            
            //添加关键帧动画
            addKeyFrameAnimation(spot, index: index)
        }
    }
    
    //MARK: 左边固定点动画
    private func addLeftSpotAnimation(){
        leftSoptView = MKPreLoadSpot(frame: CGRectMake(originX - UNIT_RADIUS, frame.size.height/2 - UNIT_RADIUS, 2 * UNIT_RADIUS, 2 * UNIT_RADIUS), color: UIColor.greenColor())
        self.addSubview(leftSoptView)
        
        leftSoptView.layer.transform = CATransform3DMakeScale(4.0, 4.0, 0)
        let ani = CAKeyframeAnimation(keyPath: "transform")
        ani.values = [spotScaleVal3,
                      spotScaleVal4,
                      spotScaleVal4,
                      spotScaleVal3,
                      spotScaleVal3,
                      spotScaleVal2,
                      spotScaleVal2,
                      spotScaleVal1,
                      spotScaleVal1,
                      spotScaleVal2,
                      spotScaleVal2,
                      spotScaleVal3,
                      spotScaleVal3,]
        ani.keyTimes = [0.0, 0.0 + ti, 0.25, 0.25 + ti, 0.33, 0.33 + ti, 0.41, 0.41 + ti, 0.84, 0.84 + ti, 0.92, 0.92 + ti, 1.00]//SPOT_DELAY_RATIO = 0.08
        ani.duration = PROCESS_DURING
        ani.repeatCount = MAXFLOAT
        leftSoptView.layer.addAnimation(ani, forKey: "fixedSpotScaleAnim")
    }
    
    //MARK: 右边固定点动画
    private func addRightSpotAnimation(){
        rightSoptView = MKPreLoadSpot(frame: CGRectMake(finalX - UNIT_RADIUS, frame.size.height/2 - UNIT_RADIUS, 2 * UNIT_RADIUS, 2 * UNIT_RADIUS), color: UIColor.greenColor())
        self.addSubview(rightSoptView)
        
        let ani = CAKeyframeAnimation(keyPath: "transform")
        ani.values = [spotScaleVal1,
                      spotScaleVal1,
                      spotScaleVal2,
                      spotScaleVal2,
                      spotScaleVal3,
                      spotScaleVal3,
                      spotScaleVal4,
                      spotScaleVal4,
                      spotScaleVal3,
                      spotScaleVal3,
                      spotScaleVal2,
                      spotScaleVal2,
                      spotScaleVal1,
                      spotScaleVal1,]
        ani.keyTimes = [0.0, 0.25, 0.25 + ti, 0.33, 0.33 + ti, 0.41, 0.41 + ti, 0.75, 0.75 + ti, 0.83, 0.83 + ti, 0.91, 0.91 + ti, 1.00]//SPOT_DELAY_RATIO = 0.08
        ani.duration = PROCESS_DURING
        ani.repeatCount = MAXFLOAT
        //0.1 ratio needed that the spot from left to right
        ani.beginTime = CACurrentMediaTime() + PROCESS_DURING * 0.1;
        rightSoptView.layer.addAnimation(ani, forKey: "fixedSpotScaleAnim")
    }
    
    //MARK: 移动点动画
    private func addKeyFrameAnimation(spot: UIView, index: Int){
        let anim = CAKeyframeAnimation(keyPath: "position.x")
        anim.values = [originX,
                       originX,
                       finalX,
                       finalRearX,
                       finalX,
                       finalX,
                       originX,
                       originRearX,
                       originX,
                       originX]
        anim.keyTimes = [0.0, 0.25, 0.35, 0.38, 0.41, 0.75, 0.85, 0.88, 0.91, 1.0];//sleep 0.4 ratio
        anim.duration = PROCESS_DURING
        anim.repeatCount = MAXFLOAT
        anim.beginTime = CACurrentMediaTime() + Double(index) * SPOT_DELAY_RATIO * PROCESS_DURING
        spot.layer.addAnimation(anim, forKey: "movingAnim");
        CATransaction.begin()
        CATransaction.setDisableActions(true);
        CATransaction.commit()
    }
}