//
//  MKSpotAnimation.swift
//  MKSpot
//
//  Created by Liujh on 16/4/27.
//  Copyright © 2016年 mk.mk. All rights reserved.
//

import Foundation
import UIKit

let MAX_MULTIPLE = 5
let PROCESS_DURING = 3.6
let SPOT_DELAY_RATIO = 0.08 //污点弹出延迟系数
let COORDINATE_CORRECTION_OFFSET: CGFloat = 2.2;     //修正path超出图形的情况
let SPOT_MAGNIFY_ANIM_DURATION_RATIO: CGFloat = 0.03

let UNIT_RADIUS: CGFloat = 5 //spot半径

let EFFECT_TOKEN_LEFT = "EFFECT_TOKEN_LEFT"     //可对左边污点造成影响
let EFFECT_TOKEN_RIGHT = "EFFECT_TOKEN_RIGHT"   //可对右边污点造成影响

//MARK: MKPreLoadSpot
class MKPreLoadSpot: UIView{
    
    var effectToken = ""
    var allowChangeEffectToken = false
    var isFirstTimeToBlend = false
    var isFirstTimeToSpringBack = false
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, color: UIColor) {
        self.init(frame: frame)
        assignEffectToken()
        drawLittleSpotWithColor(color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func assignEffectToken(){
        self.effectToken = EFFECT_TOKEN_LEFT
    }
    
    func drawLittleSpotWithColor(color: UIColor){
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 3 * UIScreen.mainScreen().scale)
        CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), true)
        let rectInset: CGFloat = 0.5
        let path = UIBezierPath(ovalInRect: CGRectInset(self.bounds, rectInset, rectInset))
        color.setFill()
        path.fill()
        self.layer.contents = UIGraphicsGetImageFromCurrentImageContext().CGImage
        UIGraphicsEndImageContext()
    }
}

//MARK: MKPreLoad
class MKPreLoad: UIView{
    
    var spotColor: UIColor = UIColor.blackColor()
    
    var leftSoptView: MKPreLoadSpot!
    var rightSoptView: MKPreLoadSpot!
    
    private var mainDisplayLink: CADisplayLink!
    private var movingSpots: [MKPreLoadSpot] = []
    private var stickyView: UIView!
    
    private var stickyShapeLayer: CAShapeLayer!
    private var stickyShapeLayerRight: CAShapeLayer!
    private var stickyShapeLayerLeftRear: CAShapeLayer!
    private var stickyShapeLayerRightRear: CAShapeLayer!
    
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
        addStickyView()
        
        //左边固定点
        addLeftSpotAnimation()
        
        //右边固定点
        addRightSpotAnimation()
        
        for index in 0...2{
            let spot = MKPreLoadSpot(frame: CGRectMake(originX - UNIT_RADIUS, frame.size.height/2 - UNIT_RADIUS, 2 * UNIT_RADIUS, 2 * UNIT_RADIUS), color: UIColor.greenColor());
            spot.tag = index
            //添加关键帧动画
            addKeyFrameAnimation(spot)
            movingSpots.append(spot)
            
            self.addSubview(spot)
        }
        
        configureDisplayLink()
    }
    
    //MARK: 左边固定点动画
    private func addLeftSpotAnimation(){
        leftSoptView = MKPreLoadSpot(frame: CGRectMake(originX - UNIT_RADIUS, frame.size.height/2 - UNIT_RADIUS, 2 * UNIT_RADIUS, 2 * UNIT_RADIUS), color: UIColor.greenColor())
        self.addSubview(leftSoptView)
        
        leftSoptView.layer.transform = CATransform3DMakeScale(4.0, 4.0, 0)
        let ani = CAKeyframeAnimation(keyPath: "transform")
        let ti = SPOT_MAGNIFY_ANIM_DURATION_RATIO
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
        let ti = SPOT_MAGNIFY_ANIM_DURATION_RATIO
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
    private func addKeyFrameAnimation(spot: UIView){
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
        anim.beginTime = CACurrentMediaTime() + Double(spot.tag) * SPOT_DELAY_RATIO * PROCESS_DURING
        spot.layer.addAnimation(anim, forKey: "movingAnim");
        CATransaction.begin()
        CATransaction.setDisableActions(true);
        CATransaction.commit()
    }
    
    func addStickyView(){
        stickyView = UIView(frame: self.bounds);
        configureStickyShapelayer()
        self.addSubview(stickyView)
    }
    
    func configureStickyShapelayer() {
        stickyShapeLayer = CAShapeLayer();
        stickyShapeLayerRight = CAShapeLayer();
        stickyShapeLayerLeftRear = CAShapeLayer();
        stickyShapeLayerRightRear = CAShapeLayer();
        
        stickyView.layer.insertSublayer(stickyShapeLayer, above:stickyView.layer);
        stickyView.layer.insertSublayer(stickyShapeLayerRight, above:stickyView.layer);
        stickyView.layer.insertSublayer(stickyShapeLayerLeftRear, above:stickyView.layer);
        stickyView.layer.insertSublayer(stickyShapeLayerRightRear, above:stickyView.layer);
    }
    
    func configureDisplayLink(){
        if(mainDisplayLink == nil){
            mainDisplayLink = CADisplayLink.init(target: self, selector: #selector(MKPreLoad.displayLinkAction(_:)));
            mainDisplayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        }
    }
    
    func displayLinkAction(displayLink: CADisplayLink){
        //抽到全局
//        let cdFixSpot = centerDistance(leftSoptView.center, another: rightSoptView.center);
        
        let leftFixSpotPreLayer = CALayer(layer: leftSoptView.layer.presentationLayer()!);
        let rightFixSpotPreLayer = CALayer(layer: leftSoptView.layer.presentationLayer()!);
        
        let leftFixSpotPosition = leftFixSpotPreLayer.position;
        let rightFixSpotPosition = rightFixSpotPreLayer.position;
        
        let pointLeftU = CGPointMake(leftFixSpotPosition.x, leftFixSpotPosition.y - leftFixSpotPreLayer.frame.size.height/2 + COORDINATE_CORRECTION_OFFSET);
        let pointLeftD = CGPointMake(leftFixSpotPosition.x, leftFixSpotPosition.y + leftFixSpotPreLayer.frame.size.height/2 - COORDINATE_CORRECTION_OFFSET);
        let pointRightU = CGPointMake(rightFixSpotPosition.x, rightFixSpotPosition.y - rightFixSpotPreLayer.frame.size.height/2 + COORDINATE_CORRECTION_OFFSET);
        let pointRightD = CGPointMake(rightFixSpotPosition.x, rightFixSpotPosition.y + rightFixSpotPreLayer.frame.size.height/2 - COORDINATE_CORRECTION_OFFSET);
        
        //圆心距(left)
        for movingSpot in movingSpots {
            let movingSpotPreLayer = CALayer(layer: movingSpot.layer.presentationLayer()!);
            if (circleIncircling(leftFixSpotPreLayer, smallOne:movingSpotPreLayer) ||
                circleIncircling(rightFixSpotPreLayer, smallOne:movingSpotPreLayer)) {
                if (movingSpot.isFirstTimeToBlend) {
                    cleanResiduePath(movingSpot);
                } else if (movingSpot.isFirstTimeToSpringBack) {
                    cleanRearResidePath(movingSpot);
                }
                continue;
            }
            
            let fdLeft = faceDistance(leftFixSpotPreLayer, another:movingSpotPreLayer);
            let fdRight = faceDistance(rightFixSpotPreLayer, another:movingSpotPreLayer);
            
            
            if (movingSpot.effectToken == EFFECT_TOKEN_LEFT) {
                //排除内切圆 和 圆心距大于30 的情况
                if (fdLeft < 20) {
                    let movingSpotPosition = movingSpotPreLayer.position
                    
                    let pointMovingU = CGPointMake(movingSpotPosition.x, movingSpotPosition.y - movingSpotPreLayer.frame.size.height/2)
                    let pointMovingD = CGPointMake(movingSpotPosition.x, movingSpotPosition.y + movingSpotPreLayer.frame.size.height/2)
                    
                    let controlPointX = (leftFixSpotPosition.x - movingSpotPosition.x)/2 + movingSpotPosition.x
                    let controlPointUpY = pointMovingU.y
                    let controlPointDownY = pointMovingD.y
                    
                    let controlPointUp = CGPointMake(controlPointX, controlPointUpY)
                    let controlPointDown = CGPointMake(controlPointX, controlPointDownY)
                    
                    //todo 其实这里可以动态根据fixSpot的scale来改变MovingPoint的值(专门虚拟一个来做回弹).
                    if (movingSpotPosition.x < leftFixSpotPosition.x) {
                        //隐藏真实movingSpot
                        movingSpot.alpha = 0.0
                        let scale = leftFixSpotPreLayer.frame.size.width / rightSoptView.frame.size.width
                        var virtualExcursion = scale * -UNIT_RADIUS
                        let basicScale:CGFloat = 2.0
                        if (2 == scale) {
                            virtualExcursion = scale * -0.6 * UNIT_RADIUS
                        } else if (3 == scale) {
                            virtualExcursion = 0
                        } else if (4 == scale) {
                            virtualExcursion = (scale - basicScale) * 0.4 * UNIT_RADIUS
                        }
//                        let virtualPointMovingU = CGPointMake(movingSpotPosition.x - virtualExcursion, movingSpotPosition.y - movingSpotPreLayer.frame.size.height/2)
                        let virtualCenter = CGPointMake(movingSpotPosition.x - virtualExcursion, movingSpotPosition.y)
                        
                        let moving45degreesX = Double(UNIT_RADIUS) * sin(35/180.0 * M_PI)
                        let moving45degreesY = Double(UNIT_RADIUS) * cos(35/180.0 * M_PI)
                        let moving45degreesU = CGPointMake(movingSpotPosition.x - virtualExcursion - CGFloat(moving45degreesX), movingSpotPosition.y - CGFloat(moving45degreesY))
                        let moving45degreesD = CGPointMake(movingSpotPosition.x - virtualExcursion - CGFloat(moving45degreesX), movingSpotPosition.y + CGFloat(moving45degreesY))
                        
                        let stickyPath = UIBezierPath()
                        stickyPath.moveToPoint(pointLeftU)
                        stickyPath.addLineToPoint(moving45degreesU)
//                        stickyPath.addQuadCurveToPoint(pointMovingU, controlPoint:controlPointUp)
                        stickyPath.addArcWithCenter(virtualCenter, radius: movingSpotPreLayer.frame.size.width/2, startAngle: CGFloat(-M_PI/2), endAngle: CGFloat(M_PI/2), clockwise: false)
                        stickyPath.addLineToPoint(moving45degreesD)
//                        stickyPath.addQuadCurveToPoint(pointLeftD, controlPoint:controlPointDown)
                        stickyPath.addLineToPoint(pointLeftD)
                        stickyPath.closePath()
                        
                        stickyShapeLayerLeftRear.path = stickyPath.CGPath
                        stickyShapeLayerLeftRear.fillColor = self.spotColor.CGColor
                        stickyShapeLayerLeftRear.removeAllAnimations()
                        movingSpot.isFirstTimeToSpringBack = true
                    } else {
                        //恢复真实movingSpot
                        movingSpot.alpha = 1.0
                        let stickyPath = UIBezierPath();
                        stickyPath.moveToPoint(pointLeftU)
                        stickyPath.addQuadCurveToPoint(pointMovingU, controlPoint:controlPointUp)
                        stickyPath.addArcWithCenter(movingSpotPreLayer.position, radius:movingSpotPreLayer.frame.size.width/2, startAngle:CGFloat(-M_PI/2), endAngle:CGFloat(M_PI/2), clockwise:true)
                        stickyPath.addQuadCurveToPoint(pointLeftD, controlPoint:controlPointDown)
                        stickyPath.closePath()
                        
                        stickyShapeLayer.path = stickyPath.CGPath
                        stickyShapeLayer.fillColor = self.spotColor.CGColor
                        stickyShapeLayer.removeAllAnimations()
                        //处理过，允许换令牌
                        movingSpot.allowChangeEffectToken = true
                        movingSpot.isFirstTimeToBlend = true
                    }
                } else {
                    stickyShapeLayer.fillColor = self.backgroundColor!.CGColor
                    stickyShapeLayer.removeAllAnimations()
                    if (movingSpot.allowChangeEffectToken) {
                        //失去令牌,不会再进此 if else
                        movingSpot.effectToken = EFFECT_TOKEN_RIGHT
                        movingSpot.allowChangeEffectToken = false
                    }
                    
                }
            } else if (movingSpot.effectToken == EFFECT_TOKEN_RIGHT) {
                if (fdRight < 20) {
                    let movingSpotPosition = movingSpotPreLayer.position;
                    
                    let pointMovingU = CGPointMake(movingSpotPosition.x, movingSpotPosition.y - movingSpotPreLayer.frame.size.height/2);
                    let pointMovingD = CGPointMake(movingSpotPosition.x, movingSpotPosition.y + movingSpotPreLayer.frame.size.height/2);
                    
                    
                    let controlPointX = (rightFixSpotPosition.x - movingSpotPosition.x)/2 + movingSpotPosition.x;
                    let controlPointUpY = pointMovingU.y;
                    let controlPointDownY = pointMovingD.y;
                    
                    let controlPointUp = CGPointMake(controlPointX, controlPointUpY);
                    let controlPointDown = CGPointMake(controlPointX, controlPointDownY);
                    
                    if (movingSpotPosition.x > rightFixSpotPosition.x) {
                        //隐藏真实movingSpot
                        movingSpot.alpha = 0.0
                        let scale = rightFixSpotPreLayer.frame.size.width / rightSoptView.frame.size.width;
                        var virtualExcursion = scale * -UNIT_RADIUS;
                        let basicScale: CGFloat = 2;
                        if (2 == scale) {
                            virtualExcursion = scale * -0.6 * UNIT_RADIUS;
                        } else if (3 == scale) {
                            virtualExcursion = 0;
                        } else if (4 == scale) {
                            virtualExcursion = (scale - basicScale) * 0.4 * UNIT_RADIUS;
                        }
                        
                        //CGPoint virtualPointMovingU = CGPointMake(movingSpotPosition.x + virtualExcursion, movingSpotPosition.y - movingSpotPreLayer.frame.size.height/2);
                        let virtualCenter = CGPointMake(movingSpotPosition.x + virtualExcursion, movingSpotPosition.y)
                        
                        let moving45degreesXY = Double(UNIT_RADIUS) * sin(35/180 * M_PI);
                        let moving45degreesY = Double(UNIT_RADIUS) * cos(35/180 * M_PI);
                        let moving45degreesU = CGPointMake(movingSpotPosition.x + virtualExcursion + CGFloat(moving45degreesXY), movingSpotPosition.y - CGFloat(moving45degreesY))
                        let moving45degreesD = CGPointMake(movingSpotPosition.x + virtualExcursion + CGFloat(moving45degreesXY), movingSpotPosition.y + CGFloat(moving45degreesY))
                        
                        let stickyPath = UIBezierPath()
                        stickyPath.moveToPoint(pointRightU)
                        //[stickyPath addQuadCurveToPoint:virtualPointMovingU controlPoint:controlPointUp];
                        stickyPath.addLineToPoint(moving45degreesU)
                        stickyPath.addArcWithCenter(virtualCenter, radius:movingSpotPreLayer.frame.size.width/2, startAngle:CGFloat(-M_PI/2), endAngle:CGFloat(M_PI/2), clockwise:true)
                        stickyPath.addLineToPoint(moving45degreesD)
                        //[stickyPath addQuadCurveToPoint:pointRightD controlPoint:controlPointDown];
                        stickyPath.addLineToPoint(pointRightD)
                        stickyPath.closePath()
                        stickyShapeLayerRightRear.path = stickyPath.CGPath
                        stickyShapeLayerRightRear.fillColor = self.spotColor.CGColor
                        stickyShapeLayerRightRear.removeAllAnimations()
                        movingSpot.isFirstTimeToSpringBack = true
                    } else {
                        //恢复真实movingSpot
                        movingSpot.alpha = 1.0
                        let stickyPath = UIBezierPath()
                        stickyPath.moveToPoint(pointRightU)
                        stickyPath.addQuadCurveToPoint(pointMovingU, controlPoint:controlPointUp)
                        stickyPath.addArcWithCenter(movingSpotPreLayer.position, radius:movingSpotPreLayer.frame.size.width/2, startAngle:CGFloat(-M_PI/2), endAngle:CGFloat(M_PI/2), clockwise:false)
                        stickyPath.addQuadCurveToPoint(pointRightD, controlPoint:controlPointDown)
                        stickyPath.closePath()
                        stickyShapeLayerRight.path = stickyPath.CGPath
                        stickyShapeLayerRight.fillColor = self.spotColor.CGColor
                        stickyShapeLayerRight.removeAllAnimations()
                        //处理过，允许换令牌
                        movingSpot.allowChangeEffectToken = true
                        movingSpot.isFirstTimeToBlend = true
                    }
                } else {
                    stickyShapeLayerRight.fillColor = self.backgroundColor!.CGColor
                    self.stickyShapeLayerRight.removeAllAnimations()
                    if (movingSpot.allowChangeEffectToken) {
                        //失去令牌,不会再进此 if else
                        movingSpot.effectToken = EFFECT_TOKEN_LEFT
                        movingSpot.allowChangeEffectToken = false
                    }
                }
            }
        }
    }
    
    func cleanResiduePath(spot: MKPreLoadSpot) {
        let handleLayer: CAShapeLayer
        if (spot.effectToken == EFFECT_TOKEN_LEFT) {
            handleLayer = stickyShapeLayer
        } else {
            handleLayer = stickyShapeLayerRight
        }
        handleLayer.fillColor = self.backgroundColor!.CGColor
        handleLayer.removeAllAnimations()
        spot.isFirstTimeToBlend = false
    }
    
    func cleanRearResidePath(spot: MKPreLoadSpot) {
        let handleLayer: CAShapeLayer
        if (spot.effectToken == EFFECT_TOKEN_LEFT) {
            handleLayer = stickyShapeLayerLeftRear
        } else {
            handleLayer = stickyShapeLayerRightRear
        }
        handleLayer.fillColor = self.backgroundColor!.CGColor
        handleLayer.removeAllAnimations()
        spot.isFirstTimeToSpringBack = false
    }
    
    func spotChangeEffectToken(spot: MKPreLoadSpot) {
        if (spot.allowChangeEffectToken) {
            spot.effectToken = spot.effectToken == EFFECT_TOKEN_LEFT ? EFFECT_TOKEN_RIGHT : EFFECT_TOKEN_LEFT
            spot.allowChangeEffectToken = false
        }
    }
    
    //MARK: 计算两点距离
    func centerDistance(point: CGPoint, another: CGPoint) -> Double {
        let x1 = point.x
        let y1 = point.y
        
        let x2 = another.x
        let y2 = another.y
        
        let cdX2X1 = Double(x2 - x1)
        let cdY2Y1 = Double(y2 - y1)
        return sqrt(cdX2X1 * cdX2X1 + cdY2Y1 * cdY2Y1)
    }
    
    //MARK: 计算圆表面距离
    func faceDistance(circleLayer: CALayer, another: CALayer) -> Double {
        let cd = centerDistance(circleLayer.position, another: another.position)
        return cd - Double(layer.frame.size.width + another.frame.size.width)/2
    }
    
    //MARK: 两圆是否包含
    func circleIncircling(bigOne: CALayer, smallOne: CALayer) -> Bool {
        let cd = centerDistance(bigOne.position, another: smallOne.position)
        return (cd < Double(bigOne.frame.size.width - smallOne.frame.size.width)/2)
    }
}