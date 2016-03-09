//
//  GraphView.swift
//  GraphLearner
//
//  Created by Lucas Longo on 3/1/16.
//  Copyright © 2016 lucaslongo. All rights reserved.
//

import UIKit

class GraphView: UIView {
    
    var mainView : ViewController?
    var xSlider: UISlider?
    var ySlider: UISlider?
    var context : CGContextRef!
    var m : Double = 1.0
    var a : Double = 0.0
    var b : Double = 0.0
    var c : Double = 0.0
    var d : Double = 0.0
    var drawBaseline = true
    var drawGrids = false
    var drawSinCos = false
    var formulaValues = [CGPoint]()
    var drawingValues = [CGPoint]()
    var translateValue = 100
    var translateSize : CGPoint?
    let xySpan = 1000
    var currentPoint : CGPoint?
    var drawNumbers = false
    var drawIntersectionPoint = false
    var pickerViewTriggered = false
    
    //    var translateDelta : CGPoint = CGPointMake(0, 0)

    override func drawRect(rect: CGRect) {
        
        
        context = UIGraphicsGetCurrentContext()

        // FlipContext & Translate
        var transform = CGAffineTransformIdentity;
        transform = CGAffineTransformScale(transform, 1.0, -1.0)
        if let t = translateSize {
            transform = CGAffineTransformTranslate(transform, t.x, -self.frame.height + t.y);
        }
        else {
            let ts = CGPointMake(CGFloat(translateValue), CGFloat(translateValue))
            transform = CGAffineTransformTranslate(transform, ts.x, -self.frame.height + ts.y);
        }
        CGContextConcatCTM(context, transform);
        
//        let translate = CGAffineTransformMakeTranslation(translateSize.x, -translateSize.y)
//        CGContextConcatCTM(context, translate)
//        CGContextTranslateCTM(context, translateSize.x, -translateSize.y)
//        CGContextTranslateCTM(context, translateSize.x + translateDelta.x, -translateSize.y - translateDelta.y)
//        translateSize = CGPointMake(translateSize.x + translateDelta.x, -translateSize.y - translateDelta.y)



        drawXSliderLine(context)
        drawYSliderLine(context)
        drawIntersectionPoint(context)
        drawAxis(context)
        drawTracedLine(context)
        drawCurrentPoint(context)

        if drawBaseline == true {
            drawFormula(context)
        }
        if drawGrids == true {
            drawGrid(context)
        }

    }
    
    func drawXSliderLine(context: CGContextRef) {
        
        if let value = xSlider?.value {
            CGContextMoveToPoint(context, CGFloat(value), CGFloat(-xySpan))
            CGContextAddLineToPoint(context, CGFloat(value), CGFloat(xySpan))
            CGContextSetStrokeColorWithColor(context,UIColor.redColor().CGColor)
            CGContextSetLineWidth(context, 2.0)
            CGContextSetLineDash(context, 0, [10,10], 2)
            CGContextDrawPath(context, CGPathDrawingMode.FillStroke)

        }
    }
    
    func drawYSliderLine(context: CGContextRef) {
        
        if let value = ySlider?.value {
            CGContextMoveToPoint(context, CGFloat(-xySpan), CGFloat(value))
            CGContextAddLineToPoint(context, CGFloat(xySpan), CGFloat(value))
            CGContextSetStrokeColorWithColor(context,UIColor.greenColor().CGColor)
            CGContextSetLineWidth(context, 2.0)
            CGContextSetLineDash(context, 0, [10,10], 2)
            CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
        }
    }
    
    func drawIntersectionPoint(context: CGContextRef) {
        if let xValue = xSlider?.value, yValue = ySlider?.value {
            CGContextMoveToPoint(context, CGFloat(xValue), CGFloat(yValue))
            CGContextAddEllipseInRect(context, CGRectMake(CGFloat(xValue-5), CGFloat(yValue-5), 10, 10))
            CGContextSetStrokeColorWithColor(context, UIColor.clearColor().CGColor)
            CGContextSetFillColorWithColor(context, UIColor.yellowColor().CGColor)
            CGContextSetLineWidth(context, 0.0)
            CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
            let point = CGPointMake(CGFloat(xValue), CGFloat(yValue))
            
            // Draw x,y values on intersection
            if drawNumbers == true {
                drawXYBesidesPoint(context, point: point)
            }
            
        }
    }
    
    func drawCurrentPoint(context: CGContextRef) {
        
        if pickerViewTriggered == false {
            return
        }
        
        if let xValue = currentPoint?.x, yValue = currentPoint?.y {
            CGContextSaveGState(context)
            CGContextMoveToPoint(context, CGFloat(xValue), CGFloat(yValue))
            CGContextAddEllipseInRect(context, CGRectMake(CGFloat(xValue-5), CGFloat(yValue-5), 10, 10))
            CGContextSetStrokeColorWithColor(context, UIColor.clearColor().CGColor)
            CGContextSetFillColorWithColor(context, UIColor.blueColor().CGColor)
            CGContextSetLineWidth(context, 0.0)
            CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
            if drawNumbers == true {
                drawXYBesidesPoint(context, point: currentPoint)
            }
            CGContextRestoreGState(context)
        }
    }

    func drawPointAt(context: CGContextRef, point: CGPoint?, color: UIColor, withXYText: Bool) {
        if let p = point {
            CGContextMoveToPoint(context, p.x, p.y)
            CGContextAddEllipseInRect(context, CGRectMake(p.x-5, p.y-5, 10, 10))
            CGContextSetStrokeColorWithColor(context, color.CGColor)
            CGContextSetFillColorWithColor(context, color.CGColor)
            CGContextSetLineWidth(context, 0.0)
            CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
            if drawIntersectionPoint == true {
                if drawSinCos == false {
                    drawTextAt(context, point: CGPointMake(p.x-50, p.y+20), text: String(format: "m: %.1f", m), axis: "m")
                    drawTextAt(context, point: CGPointMake(p.x-50, p.y+6), text: String(format: "b: %.1f", b/10), axis: "b")
                }
                else{
                    drawTextAt(context, point: CGPointMake(p.x-50, p.y+42), text: String(format: "a: %.1f", a/10), axis: "a")
                    drawTextAt(context, point: CGPointMake(p.x-50, p.y+30), text: String(format: "b: %.1f", b*10), axis: "bb")
                    drawTextAt(context, point: CGPointMake(p.x-50, p.y+20), text: String(format: "c: %.1f", c), axis: "c")
                    drawTextAt(context, point: CGPointMake(p.x-50, p.y+6), text: String(format: "d: %.1f", d/10), axis: "d")
                }
            }
        }
    }

    func drawXYBesidesPoint(context: CGContextRef, point: CGPoint?) {
        if let p = point{
            drawTextAt(context, point: CGPointMake(p.x+10, p.y+8), text: String(format: "(x: %.1f, ", p.x/10), axis: "z1")
            drawTextAt(context, point: CGPointMake(p.x+60, p.y+8), text: String(format: "y: %.1f)", p.y/10), axis: "z2")
        }

    }
    
    func drawTracedLine(context: CGContextRef) {
       
        if let point = drawingValues.first {
           CGContextMoveToPoint(context, point.x, point.y)
        }

        for point in drawingValues {
            if point == drawingValues.first {
                CGContextMoveToPoint(context, point.x, point.y)
            }
            CGContextAddLineToPoint(context, point.x, point.y)
        }
        
        CGContextSetStrokeColorWithColor(context, UIColor.yellowColor().CGColor)
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        CGContextSetLineWidth(context, 3.0)
        CGContextDrawPath(context, CGPathDrawingMode.Stroke)
        
        if let v = mainView {
            if pickerViewTriggered == false {
                v.updateDataTable()
            }
        }

    }
    
    func drawGrid(context: CGContextRef) {
        
        var i = -xySpan
        
        while i < xySpan {
            
            let xPos = CGFloat(i)
            CGContextMoveToPoint(context, xPos, CGFloat(-xySpan))
            if xPos%50 == 0 {
                CGContextAddLineToPoint(context, xPos, CGFloat(xySpan))
            }
            CGContextMoveToPoint(context, CGFloat(-xySpan), xPos)
            if xPos%50 == 0 {
                CGContextAddLineToPoint(context, CGFloat(xySpan), xPos)
            }
            
            i += 10
        }
        
        CGContextSetStrokeColorWithColor(context,UIColor.blackColor().CGColor)
        CGContextSetLineWidth(context, 0.5)
        CGContextSetLineDash(context, 0, nil, 0)
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
        
    }
    
    func drawAxis(context: CGContextRef) {
        
        // Draw main graph lines
        CGContextMoveToPoint(context, 0, CGFloat(-xySpan))
        CGContextAddLineToPoint(context, 0, CGFloat(xySpan))
        CGContextMoveToPoint(context, CGFloat(-xySpan), 0)
        CGContextAddLineToPoint(context, CGFloat(xySpan), 0)
        CGContextSetStrokeColorWithColor(context,UIColor.blackColor().CGColor)
        CGContextSetLineWidth(context, 1)
        CGContextSetLineDash(context, 0, nil, 0)
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)

        var i = -xySpan
        
        while i < xySpan {
            
            let pos = CGFloat(i)

            if pos%100 == 0 {
                CGContextMoveToPoint(context, pos, -10)
                CGContextAddLineToPoint(context, pos, 10)
                
                CGContextMoveToPoint(context, -10, pos)
                CGContextAddLineToPoint(context, 10, pos)
                if drawNumbers == true {
                    if pos == 0 {
                        drawTextAt(context, point: CGPointMake(10, 14), text: "\(i/10) ", axis: "x")
                        drawTextAt(context, point: CGPointMake(10, -15), text: "\(i/10)", axis: "y")
                    }
                    else {
                        drawTextAt(context, point: CGPointMake(pos-8, 14), text: "\(i/10)", axis: "x")
                        drawTextAt(context, point: CGPointMake(14, pos-3), text: "\(i/10)", axis: "y")
                    }
                }

            }
            else if pos%50 == 0 {
                CGContextMoveToPoint(context, pos, -5)
                CGContextAddLineToPoint(context, pos, 5)
                
                CGContextMoveToPoint(context, -5, pos)
                CGContextAddLineToPoint(context, 5, pos)

            }
            else {
                CGContextMoveToPoint(context, pos, -2)
                CGContextAddLineToPoint(context, pos, 2)
                
                CGContextMoveToPoint(context, -2, pos)
                CGContextAddLineToPoint(context, 2, pos)
            }
            
            i += 10
        }
    
        CGContextSetStrokeColorWithColor(context,UIColor.blackColor().CGColor)
        CGContextSetLineWidth(context, 0.5)
        CGContextSetLineDash(context, 0, nil, 0)
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)

    }
    
    func drawTextAt(context: CGContextRef, point: CGPoint, text: String, axis: String) {
        
        var attrs: [String: AnyObject]

        if axis == "x" {
            attrs = [NSFontAttributeName : UIFont.systemFontOfSize(12.0),
                NSForegroundColorAttributeName : UIColor.redColor().CGColor]
        }
        else if axis == "y" {
            attrs = [NSFontAttributeName : UIFont.systemFontOfSize(12.0),
                NSForegroundColorAttributeName : UIColor.greenColor().CGColor]
        }
        else if axis == "z1" {
            attrs = [NSFontAttributeName : UIFont.systemFontOfSize(12.0),
                NSForegroundColorAttributeName : UIColor.greenColor().CGColor]
        }
        else if axis == "z2" {
            attrs = [NSFontAttributeName : UIFont.systemFontOfSize(12.0),
                NSForegroundColorAttributeName : UIColor.redColor().CGColor]
        }
        else if axis == "b" {
            attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(12.0),
                NSForegroundColorAttributeName : UIColor.orangeColor().CGColor]
        }
        else if axis == "m" {
            attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(12.0),
                NSForegroundColorAttributeName : UIColor.blueColor().CGColor]
        }
        else if axis == "a" {
            attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(12.0),
                NSForegroundColorAttributeName : UIColor.blueColor().CGColor]
        }
        else if axis == "bb" {
            attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(12.0),
                NSForegroundColorAttributeName : UIColor.orangeColor().CGColor]
        }
        else if axis == "c" {
            attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(12.0),
                NSForegroundColorAttributeName : UIColor.brownColor().CGColor]
        }
        else if axis == "d" {
            attrs = [NSFontAttributeName : UIFont.boldSystemFontOfSize(12.0),
                NSForegroundColorAttributeName : UIColor.purpleColor().CGColor]
        }
        else {
            attrs = [NSFontAttributeName : UIFont.systemFontOfSize(14.0),
                NSForegroundColorAttributeName : UIColor.redColor().CGColor]
        }

        CGContextSetTextPosition(context, point.x, point.y);
        let aString = NSMutableAttributedString(string:text, attributes:attrs);
        let line = CTLineCreateWithAttributedString(aString)
        CTLineDraw(line, context);
    }
    
    
    func drawFormula(context: CGContextRef) {
        
        formulaValues = [CGPoint]()
        
        for var x = -xySpan; x < xySpan; x++ {
            
            
            if drawSinCos == true {
                CGContextSetLineDash(context, 0, nil, 0)
            }
            else {
                CGContextSetLineDash(context, 0, [5,5], 2)
            }
            
            let y = yForX(Double(x))
            let point = CGPointMake(CGFloat(x), CGFloat(y))

            formulaValues.append(point)

            if x == -xySpan {
                CGContextMoveToPoint(context, CGFloat(x), CGFloat(y))
                continue
            }
            
            CGContextAddLineToPoint(context,  CGFloat(x), CGFloat(y))
        }

        
        CGContextSetStrokeColorWithColor(context,UIColor.blueColor().CGColor)
        CGContextSetLineWidth(context, 1.5)
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
        
        if let v = mainView {
            if pickerViewTriggered == false {
                v.updateDataTable()
            }
        }
        
        if drawNumbers == true {
            let x = 0.0
            let y = yForX(x)
            let point = CGPointMake(CGFloat(x), CGFloat(y))
            drawPointAt(context, point: point, color: UIColor.orangeColor(), withXYText: true)
        }
    }
    
    func yForX(x: Double) -> Double {
       
        var y = 0.0
        if drawSinCos == true {
            y = a * sin(b * x + c) + d
            CGContextSetLineDash(context, 0, nil, 0)
        }
        else {
            y = m * Double(x) + b
            CGContextSetLineDash(context, 0, [5,5], 2)
        }
        
        return y
    }
}
