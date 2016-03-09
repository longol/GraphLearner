//
//  ViewController.swift
//  GraphLearner
//
//  Created by Lucas Longo on 3/1/16.
//  Copyright © 2016 lucaslongo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var stageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var graphView: GraphView!

    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var currentStageLabel: UILabel!

    @IBOutlet weak var phase1Button: UIButton!
    @IBOutlet weak var phase2Button: UIButton!
    @IBOutlet weak var phase3Button: UIButton!
    @IBOutlet weak var phase1View: UIImageView!
    @IBOutlet weak var phase2View: UIImageView!
    @IBOutlet weak var phase3View: UIImageView!
    
    @IBOutlet weak var xSlider: UISlider!
    @IBOutlet weak var ySlider: UISlider!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var autoXButton: UIButton!
    @IBOutlet weak var autoYButton: UIButton!

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var clearDrawingButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
//    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var paramView: UIView!
    @IBOutlet weak var formulaStaticLabel: UILabel!
    @IBOutlet weak var formulaView: UIView!
    @IBOutlet weak var formulaLabel: UILabel!
    @IBOutlet weak var formulaCurrentView: UIView!
    @IBOutlet weak var formulaStaticCurrentLabel: UILabel!
    @IBOutlet weak var formulaCurrentLabel: UILabel!

    @IBOutlet weak var slider1Name: UILabel!
    @IBOutlet weak var slider2Name: UILabel!
    @IBOutlet weak var slider3Name: UILabel!
    @IBOutlet weak var slider4Name: UILabel!
    @IBOutlet weak var slider1Slider: UISlider!
    @IBOutlet weak var slider2Slider: UISlider!
    @IBOutlet weak var slider3Slider: UISlider!
    @IBOutlet weak var slider4Slider: UISlider!
    @IBOutlet weak var slider1Value: UILabel!
    @IBOutlet weak var slider2Value: UILabel!
    @IBOutlet weak var slider3Value: UILabel!
    @IBOutlet weak var slider4Value: UILabel!

    @IBOutlet weak var drawingTableView: UIView!
    @IBOutlet weak var drawingPickerView: UIPickerView!
    
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var gridSwitch: UISwitch!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var speedSliderLabel: UILabel!

    
    var currentStage = 0
    var countDownNum = 3
    var cancelAnimations = false
    var xSliderAuto = false
    var ySliderAuto = false
    var xValueTicker = 0.0
    var instructionLabelClosedFrame : CGRect!
//    var firstTouchLocation : CGPoint?

    // MARK: VIEW DID LOAD

    override func viewDidLoad() {
        super.viewDidLoad()
        
        instructionLabelClosedFrame = instructionsLabel.frame
        
        updateInterface()
        clearDrawing()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"automateSlider", name: "countDownDone", object: nil)
        
        NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "showInstructions", userInfo: nil, repeats: false)
        
        for view in self.view.subviews {
            if view != graphView && view != instructionsLabel {
                view.layer.cornerRadius = 10
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: PICKER VIEW
    
    func updateDataTable() {
        drawingPickerView.reloadAllComponents()
        if graphView.drawingValues.count > 1 {
            drawingPickerView.selectRow(graphView.drawingValues.count-1, inComponent: 0, animated: false)
            drawingPickerView.selectRow(graphView.drawingValues.count-1, inComponent: 1, animated: false)
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return graphView.drawingValues.count
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let number = graphView.drawingValues[row]
        var string = ""
        var myTitle : NSAttributedString!
        
        if component == 0 {
            string = String(format: "%.1f", number.x/10)
            myTitle = NSAttributedString(string: string, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.redColor()])
        }
        else {
            string = String(format: "%.1f", number.y/10)
            myTitle = NSAttributedString(string: string, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.greenColor()])
        }
        
        return myTitle
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.selectRow(row, inComponent: 1, animated: true)
        }
        else if component == 1 {
            pickerView.selectRow(row, inComponent: 0, animated: true)
        }
        
        NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "pickerViewAnimationEnded", userInfo: nil, repeats: false)
    }
    
    func pickerViewAnimationEnded() {
        
        let currPoint = graphView.drawingValues[drawingPickerView.selectedRowInComponent(0)]
        graphView.currentPoint = CGPointMake(currPoint.x, currPoint.y)
        graphView.pickerViewTriggered = true
        graphView.setNeedsDisplay()
    }
    
    
    // MARK: IBACTIONS
    
    @IBAction func autoXAction() {
        clearDrawing()
        showInstructions()
        countDown()
        xSliderAuto = true
    }
    
    @IBAction func autoYAction() {
        clearDrawing()
        showInstructions()
        countDown()        
        ySliderAuto = true
    }

        
    @IBAction func prevStage(sender: AnyObject) {
        currentStage--
        clearDrawing()
        updateInterface()
    }
    
    @IBAction func nextStage(sender: AnyObject) {
        currentStage++
        clearDrawing()
        updateInterface()
    }
    
    @IBAction func sliderXChanged() {
        graphView.drawingValues.append(CGPointMake(CGFloat(xSlider.value), CGFloat(ySlider.value)))
        graphView.pickerViewTriggered = false
        xLabel.text = String(format: "X: %.1f", xSlider.value/10)
        graphView.setNeedsDisplay()
        updateDataTable()

    }
    
    @IBAction func sliderYChanged() {
        graphView.drawingValues.append(CGPointMake(CGFloat(xSlider.value), CGFloat(ySlider.value)))
        graphView.pickerViewTriggered = false
        yLabel.text = String(format: "Y: %.1f", ySlider.value/10)
        graphView.setNeedsDisplay()
        updateDataTable()
    }
    
    @IBAction func drawGrid() {
        graphView.drawGrids = gridSwitch.on
        graphView.setNeedsDisplay()
    }
    
    @IBAction func demoPhase() {
        currentStage = 0
        clearDrawing()
        updateInterface()
    }

    @IBAction func yxPhase() {
        currentStage = 3
        clearDrawing()
        updateInterface()
    }

    @IBAction func ymxbPhase() {
        currentStage = 4
        clearDrawing()
        updateInterface()
    }
    @IBAction func sinPhase() {
        currentStage = 5
        clearDrawing()
        updateInterface()
    }

    @IBAction func clearDrawing() {
        if graphView.drawSinCos == false {
            xSlider.value = -50
        }
        else {
            xSlider.value = -100
        }
        ySlider.value = Float(graphView.yForX(Double(xSlider.value)))
        xValueTicker = Double(xSlider.value)
        xLabel.text = "X: -50"
        yLabel.text = "Y: -50"
        cancelAnimations = true
        xSliderAuto = false
        ySliderAuto = false
        graphView.pickerViewTriggered = false
        graphView.drawingValues.removeAll()
        graphView.setNeedsDisplay()

    }
    
    @IBAction func speedSliderAction() {
        if speedSlider.value < 0.5 {
            speedSlider.value = 0
            speedSliderLabel.text = "Speed: Slow"
        }
        else if speedSlider.value < 1.5 {
            speedSlider.value = 1
            speedSliderLabel.text = "Speed: Normal"
        }
        else {
            speedSlider.value = 2
            speedSliderLabel.text = "Speed: Fast"
        }
    }
    
    @IBAction func sliderParamsValueChanged(sender: UISlider) {
        
        if graphView.drawSinCos == false {
            if sender == slider1Slider {
                graphView.m = Double(sender.value)
                slider1Value.text = String(format: "%.1f", sender.value)
            }
            if sender == slider2Slider {
                graphView.b = Double(sender.value)
                slider2Value.text = String(format: "%.1f", sender.value/10)
            }
            writeFormulas()
        }
        else {
            if sender == slider1Slider {
                graphView.a = Double(sender.value)
                slider1Value.text = String(format: "%.1f", sender.value/10)
            }
            if sender == slider2Slider {
                graphView.b = Double(sender.value)
                slider2Value.text = String(format: "%.1f", sender.value*10)
            }
            if sender == slider3Slider {
                graphView.c = Double(sender.value)
                slider3Value.text = String(format: "%.1f", sender.value/10)
            }
            if sender == slider4Slider {
                graphView.d = Double(sender.value)
                slider4Value.text = String(format: "%.1f", sender.value/10)
            }
            writeFormulas()
        }
        
        graphView.setNeedsDisplay()
        
    }
    
    // MARK: MY FUNCTIONS


    func showInstructions() {
        instructionsLabel.font = UIFont.systemFontOfSize(30)
        UIView.animateWithDuration(0.3) { () -> Void in
            self.instructionsLabel.frame.size.height = self.graphView.frame.origin.y + self.graphView.frame.height - self.instructionLabelClosedFrame.origin.y
            self.instructionsLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        }
        
    }
    
    func hideInstructions() {
        instructionsLabel.font = UIFont.systemFontOfSize(17)
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.instructionsLabel.alpha = 0
            }) { (end) -> Void in
                self.instructionsLabel.frame.size.height = self.instructionLabelClosedFrame.height
                UIView.animateWithDuration(0.3) { () -> Void in
                    self.instructionsLabel.alpha = 1
                    self.instructionsLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
                }
        }
    }
    
    func countDown() {
        instructionsLabel.text = "\(countDownNum)"

        if countDownNum > 0 {
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countDown", userInfo: nil, repeats: false)
        }
        else {
            countDownEnded()
        }
        countDownNum--
    }

    func countDownStop() {
        countDownNum = 3
        instructionsLabel.text = "\(countDownNum)"
    }
    
    func automateSlider() {
    
        var animationSpeed : Double = 0.0
        
        if speedSlider.value == 0 {
            animationSpeed = 1
        }
        if speedSlider.value == 1 {
            animationSpeed = 2.0
        }
        if speedSlider.value == 2 {
            animationSpeed = 10.0
        }
        
        var y = 0.0
        
        if graphView.drawSinCos == true {
            y = graphView.a * sin(graphView.b * Double(xSlider.value) + graphView.c) + graphView.d
        }
        else {
            y = graphView.m * Double(xSlider.value) + graphView.b
        }

        if ySliderAuto == true && xSliderAuto == true {
            
            ySlider.setValue(Float(y), animated: true)
            xSlider.setValue(xSlider.value, animated: true)
            
            graphView.drawingValues.append(CGPointMake(CGFloat(xSlider.value), CGFloat(ySlider.value)))

            if (xSlider.value < Float(graphView.frame.width) - Float(graphView.translateValue)) &&
                (ySlider.value < Float(graphView.frame.height) - Float(graphView.translateValue)) {
                NSTimer.scheduledTimerWithTimeInterval(1/30.0, target: self, selector: "automateSlider", userInfo: nil, repeats: false)
            }
            else {
                sliderAnimationEnded()
            }
           
            xSlider.value += Float(animationSpeed)
        }
        else if xSliderAuto == true {
            
            xSlider.setValue(xSlider.value, animated: true)

            if xSlider.value < Float(graphView.frame.width) - Float(graphView.translateValue) {
                NSTimer.scheduledTimerWithTimeInterval(1/30, target: self, selector: "automateSlider", userInfo: nil, repeats: false)
            }
            else {
                sliderAnimationEnded()
            }

            graphView.drawingValues.append(CGPointMake(CGFloat(xSlider.value), CGFloat(ySlider.value)))
            xSlider.value += Float(animationSpeed)
        }
        else if ySliderAuto == true {
            
            if graphView.drawSinCos == true {
                y = graphView.a * sin(graphView.b * xValueTicker + graphView.c) + graphView.d
            }
            else {
                y = graphView.m * xValueTicker + graphView.b
            }

            ySlider.setValue(Float(y), animated: true)
            
            if ySlider.value < Float(graphView.frame.height) - Float(graphView.translateValue) {
                NSTimer.scheduledTimerWithTimeInterval(1/30, target: self, selector: "automateSlider", userInfo: nil, repeats: false)
            }
            else {
                sliderAnimationEnded()
            }
            
            graphView.drawingValues.append(CGPointMake(CGFloat(xSlider.value), CGFloat(ySlider.value)))
            xValueTicker += animationSpeed
        }

        xLabel.text = String(format: "X: %.1f", xSlider.value/10)
        yLabel.text = String(format: "Y: %.1f", ySlider.value/10)

        graphView.setNeedsDisplay()
    }
    
    
    
//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        if let touch = touches.first {
//            firstTouchLocation = touch.locationInView(self.view)
//        }
//    }
//    
//    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        let touch = touches.first
//        if let location = touch?.locationInView(self.view), firstLocation = firstTouchLocation {
//            let deltaX = location.x - firstLocation.x
//            let deltaY = location.y - firstLocation.y
//            graphView.translateDelta = CGPointMake(deltaX, deltaY)
//            graphView.setNeedsDisplay()
//        }
//    }

    func writeFormulas() {
        if graphView.drawSinCos == true {
            formulaLabel.text = "y = a * sin ( b * x + c ) + d"
            formulaCurrentLabel.text = String(format: "y = %.1f * sin ( %.1f * x + %.1f ) + %.1f", graphView.a/10, graphView.b*10, graphView.c/10, graphView.d/10)
        }
        else {
            formulaLabel.text = "y = m * x + b"
            formulaCurrentLabel.text = String(format: "y = %.1f * x + %.1f", graphView.m, graphView.b/10)
        }

    }
    // MARK: UPDATE INTERFACE
    
    func updateInterface() {
        
        cancelAnimations = false
        
        // Rotate Y axis slider
        ySlider.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        
        // Pass on reference to graphView
        graphView.xSlider = xSlider
        graphView.ySlider = ySlider
        graphView.mainView = self
        graphView.translateSize = CGPointMake(100, 100)

        currentStageLabel.text = "Stage: \(currentStage)"
        
        // Adjust visuals
        switch currentStage {
        case 0:
            instructionsLabel.text = "Let me show you how this works! \n\nWe have the blue line to follow.\n\nUse the red and green sliders. \n\nPress start to see a demonstration."
            formulaView.hidden = true
            formulaCurrentView.hidden = true
            graphView.m = 1
            graphView.b = 0
            graphView.drawSinCos = false
            graphView.drawNumbers = false
            phase2Button.hidden = true
            phase2View.hidden = true
            phase3Button.hidden = true
            phase3View.hidden = true
            autoXButton.hidden = true
            autoYButton.hidden = true
            drawingTableView.hidden = true
            paramView.hidden = true
            xLabel.hidden = true
            yLabel.hidden = true
            settingsView.hidden = true
            clearDrawingButton.hidden = true
            speedSlider.value = 2
            xSliderAuto = true
            ySliderAuto = true
            ySlider.userInteractionEnabled = false
            xSlider.userInteractionEnabled = false
            xValueTicker = -50
            prevButton.hidden = true
            clearDrawingButton.hidden = true
            showInstructions()
       case 1:
            clearDrawing()
            startButton.hidden = false
            prevButton.hidden = false
            settingsView.hidden = false
            xSliderAuto = false
            xSlider.userInteractionEnabled = true
            instructionsLabel.text = "Got it? \n\nNow it's your turn. \n\nI will move green and you move the red. \n\n Press Start when your are ready!\n\n\nYou can change the speed of how fast I go below."
            showInstructions()
        case 2:
            startButton.hidden = false
            prevButton.hidden = false
            
            xSliderAuto = true
            ySliderAuto = false
            ySlider.userInteractionEnabled = true
            xSlider.userInteractionEnabled = false
            instructionsLabel.text = "Great - let's switch! \n\nNow I control the red.\n\nYou control the green.\n\n"
            showInstructions()
        case 3:
            formulaView.hidden = true
            formulaCurrentView.hidden = true
            graphView.m = 1
            graphView.b = 0
            graphView.drawSinCos = false
            graphView.drawNumbers = true
            graphView.drawIntersectionPoint = false
            phase3Button.hidden = true
            phase3View.hidden = true
            paramView.hidden = true
            settingsView.hidden = false
            speedSlider.value = 1
            xValueTicker = -50
            startButton.hidden = false
            xSliderAuto = false
            ySliderAuto = false
            ySlider.userInteractionEnabled = true
            xSlider.userInteractionEnabled = true
            xLabel.hidden = false
            yLabel.hidden = false
            drawingTableView.hidden = false
            clearDrawingButton.hidden = true
            prevButton.hidden = false
            autoXButton.hidden = false
            autoYButton.hidden = false
            phase2Button.hidden = false
            phase2View.hidden = false
            formulaStaticLabel.hidden = false
            formulaLabel.text = "y = x"
            instructionsLabel.text = "Awesome!\n\nNow you control both!\n\nNotice we now see numbers all over.\n\nX axis is RED and the Y axis is GREEN.\n\nWe can see values for your drawing.\n\nWe can see the formula of the blue line!"
            showInstructions()
        case 4:
            graphView.drawNumbers = true
            graphView.drawIntersectionPoint = true
            graphView.drawSinCos = false
            graphView.m = 2.4
            graphView.b = 150
            xSlider.value = -75
            ySlider.value = Float(graphView.yForX(Double(xSlider.value)))
            instructionsLabel.text = "Now can change parameters of the blue line\n\nPlay around with the sliders.\n\n Try to notice what changes."
            slider1Name.text = "m"
            slider2Name.text = "b"
            slider1Slider.value = Float(graphView.m)
            slider1Slider.minimumValue = -10
            slider1Slider.maximumValue = 10
            slider2Slider.value = Float(graphView.b)
            slider2Slider.minimumValue = -100
            slider2Slider.maximumValue = 400
            slider1Value.text = String(format: "%.1f", graphView.m)
            slider2Value.text = String(format: "%.1f", graphView.b/10)
            slider3Slider.hidden = true
            slider4Slider.hidden = true
            slider3Name.hidden = true
            slider4Name.hidden = true
            slider3Value.hidden = true
            slider4Value.hidden = true
            slider1Slider.minimumTrackTintColor = UIColor.blueColor()
            slider1Name.textColor = UIColor.blueColor()
            slider2Slider.minimumTrackTintColor = UIColor.orangeColor()
            slider2Name.textColor = UIColor.orangeColor()
            phase3Button.hidden = false
            phase3View.hidden = false
            formulaView.hidden = false
            formulaCurrentView.hidden = false
            paramView.hidden = false
            writeFormulas()
            showInstructions()
        case 5:
            graphView.drawSinCos = true
            graphView.drawNumbers = true
            instructionsLabel.text = "Now let's look at sin waves!\n\nMany parameters to play with."
            paramView.hidden = false
            
            graphView.translateSize = CGPointMake(150, graphView.frame.height/2)

            graphView.a = 100.0
            graphView.b = 0.01
            graphView.c = 0.0
            graphView.d = 0.0
            xSlider.value = -100
            ySlider.value = Float(graphView.yForX(Double(xSlider.value)))
            
            slider1Name.text = "a"
            slider2Name.text = "b"
            slider3Name.text = "c"
            slider4Name.text = "d"

            slider1Name.hidden = false
            slider2Name.hidden = false
            slider3Name.hidden = false
            slider4Name.hidden = false

            slider1Name.textColor = UIColor.blueColor()
            slider2Name.textColor = UIColor.orangeColor()
            slider3Name.textColor = UIColor.brownColor()
            slider4Name.textColor = UIColor.purpleColor()

            slider1Slider.hidden = false
            slider2Slider.hidden = false
            slider3Slider.hidden = false
            slider4Slider.hidden = false

            slider1Slider.value = Float(graphView.a)
            slider2Slider.value = Float(graphView.b)
            slider3Slider.value = Float(graphView.c)
            slider4Slider.value = Float(graphView.d)

            slider1Slider.minimumValue = 0
            slider2Slider.minimumValue = 0
            slider3Slider.minimumValue = -10
            slider4Slider.minimumValue = -200
            
            slider1Slider.maximumValue = 400
            slider2Slider.maximumValue = 0.1
            slider3Slider.maximumValue = 10
            slider4Slider.maximumValue = 400
            
            slider1Slider.minimumTrackTintColor = UIColor.blueColor()
            slider2Slider.minimumTrackTintColor = UIColor.orangeColor()
            slider3Slider.minimumTrackTintColor = UIColor.brownColor()
            slider4Slider.minimumTrackTintColor = UIColor.purpleColor()

            slider1Value.hidden = false
            slider2Value.hidden = false
            slider3Value.hidden = false
            slider4Value.hidden = false
            
            slider1Value.text = String(format: "%.1f", graphView.a/10)
            slider2Value.text = String(format: "%.1f", graphView.b*10)
            slider3Value.text = String(format: "%.1f", graphView.c/10)
            slider4Value.text = String(format: "%.1f", graphView.d/10)

            phase3Button.hidden = false
            phase3View.hidden = false
            
            formulaView.hidden = false
            formulaCurrentView.hidden = false

            writeFormulas()
            showInstructions()

        default:
            break
        }
        
        // Set slider values
        xSlider.minimumValue = Float(-graphView.translateSize!.x)
        xSlider.maximumValue = Float(graphView.frame.width) - Float(graphView.translateSize!.x)
        
        ySlider.minimumValue = Float(-graphView.translateSize!.y)
        ySlider.maximumValue = Float(graphView.frame.height) - Float(graphView.translateSize!.y)
        
        xLabel.text = String(format: "X: %.1f", xSlider.value/10)
        yLabel.text = String(format: "Y: %.1f", ySlider.value/10)
        
        graphView.setNeedsDisplay()
    }
    
    @IBAction func startButtonAction() {
        switch currentStage {
        case 0:
            startButton.hidden = true
            prevButton.hidden = true
            xSliderAuto = true
            ySliderAuto = true
            countDown()
        case 1:
            startButton.hidden = true
            prevButton.hidden = true
            xSliderAuto = false
            ySliderAuto = true
            countDown()
        case 2:
            startButton.hidden = true
            prevButton.hidden = true
            xSliderAuto = true
            ySliderAuto = false
            countDown()
        case 3:
            startButton.hidden = false
            prevButton.hidden = false
            clearDrawingButton.hidden = false
            instructionsLabel.text = "Play with AutoX and AutoY"
            hideInstructions()
        case 4:
            startButton.hidden = false
            prevButton.hidden = false
            clearDrawingButton.hidden = false
            instructionsLabel.text = "Play with parameters"
            hideInstructions()
        case 5:
            startButton.hidden = false
            prevButton.hidden = false
            clearDrawingButton.hidden = false
            instructionsLabel.text = "Play with parameters"
            hideInstructions()
        default:
            break
        }
        
    }

    func countDownEnded() {
        countDownNum = 3
        hideInstructions()
        
        switch currentStage {
        case 0:
            instructionsLabel.text = "Observe how the red and the green move at the same speed!"
        case 1:
            instructionsLabel.text = "Move the red slider at the same speed as I do."
        case 2:
            instructionsLabel.text = "GO!"
        default:
            break
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("countDownDone", object: nil)
    }
    
    func sliderAnimationEnded() {
        
        switch currentStage {
        case 0:
            clearDrawing()
            currentStage = 1
        case 1:
            clearDrawing()
            currentStage = 2
        case 2:
            clearDrawing()
            currentStage = 3
        default:
            break
        }
        
        updateInterface()
    }
}

