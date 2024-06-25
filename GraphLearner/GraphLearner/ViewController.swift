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

    @IBOutlet weak var currentStageLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var instructionsBottomLabel: UILabel!

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
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var paramView: UIView!
    @IBOutlet weak var formulaLabel: UILabel!
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

    var colorA = UIColor(red: 0, green: 206/255, blue: 209/255, alpha: 1) // DarkTurquoise 0,206,209
    var colorB = UIColor(red: 148/255, green: 0, blue: 211/255, alpha: 1) // DarkViolet 148,0,211
    var colorC = UIColor(red: 47/255, green: 79/255, blue: 79/255, alpha: 1) // DarkSlateGrey 47,79,79
    var colorD = UIColor(red: 1, green: 20/255, blue: 147/255, alpha: 1) // DeepPink 255,20,147

    var currentStage = 0
    var countDownNum = 3
    var cancelAnimations = false
    var xSliderAuto = false
    var ySliderAuto = false
    var xValueTicker = 0.0
    var instructionLabelClosedFrame : CGRect!
    var stageInstructionsPresented = [String]()


    // MARK: VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instructionLabelClosedFrame = instructionsLabel.frame

        updateInterface()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"automateSlider", name: "countDownDone", object: nil)

        NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "showInstructions:", userInfo: nil, repeats: false)
        
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
        if row >= graphView.drawingValues.count {
            return NSAttributedString(string: "")
        }
        
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
        showInstructions(true)
        countDown()
        xSliderAuto = true
    }
    
    @IBAction func autoYAction() {
        clearDrawing()
        showInstructions(true)
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
    
    @IBAction func sliderXChanged(sender: UISlider) {
//        if sender == xSlider && ySliderAuto == false {
//            graphView.drawingValues.append(CGPointMake(CGFloat(xSlider.value), CGFloat(ySlider.value)))
//        }
        graphView.pickerViewTriggered = false
        xLabel.text = String(format: "X: %.1f", xSlider.value/10)
        graphView.setNeedsDisplay()
        updateDataTable()
    }
    
    @IBAction func sliderYChanged(sender: UISlider) {
//        if sender == ySlider && xSliderAuto == false  {
//            graphView.drawingValues.append(CGPointMake(CGFloat(xSlider.value), CGFloat(ySlider.value)))
//        }
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

        xSlider.value = graphView.drawSinCos ? -100 : -50
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
                slider2Value.text = String(format: "%.2f", sender.value*10)
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


    func showInstructions(forceShow: Bool) {
        
        switch currentStage {
        case 3...5:
            if stageInstructionsPresented.contains("\(currentStage)") == true && forceShow == false {
                return
            }
        default:
            break
        }
        
        stageInstructionsPresented.append("\(currentStage)")
    
        UIView.animateWithDuration(0.3) { () -> Void in
            self.instructionsLabel.alpha = 1
        }
    }
    
    func hideInstructions() {
        
        UIView.animateWithDuration(0.3) { () -> Void in
           self.instructionsLabel.alpha = 0
        }
    }
    
    func countDown() {
        instructionsLabel.text = "\(countDownNum)"
        
        if countDownNum > 0 {
            NSTimer.scheduledTimerWithTimeInterval(1/2, target: self, selector: "countDown", userInfo: nil, repeats: false)
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
                if graphView.drawSinCos == true && xSlider.value < Float(graphView.frame.width) - Float(graphView.translateValue) {
                    NSTimer.scheduledTimerWithTimeInterval(1/30, target: self, selector: "automateSlider", userInfo: nil, repeats: false)
                }
                else {
                    sliderAnimationEnded()
                }
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
        
        var htmlString = ""
        
        if graphView.drawSinCos == false {
            htmlString = "<center><b><font size=5><font color=\"GreenYellow\">y </font><font color=\"white\">= </font><font color=\"DarkTurquoise\">m </font><font color=\"white\">* </font><font color=\"red\">x </font><font color=\"white\">+ </font><font color=\"DarkViolet\">b</font></font><b></center>"
            createAttributedString(htmlString, label: formulaLabel)
            
            htmlString = String(format:"<center><b><font size=5><font color=\"GreenYellow\">y</font><font color=\"white\">=</font><font color=\"DarkTurquoise\">%.1f</font><font color=\"white\">*</font><font color=\"red\">x</font><font color=\"white\">+</font><font color=\"DarkViolet\">%.1f</font></font><b></center>", graphView.m, graphView.b/10)
            createAttributedString(htmlString, label: formulaCurrentLabel)
        }
        else {
            htmlString = "<center><b><font size=5><font color=\"GreenYellow\">y </font><font color=\"white\">= </font><font color=\"DarkTurquoise\">a </font><font color=\"white\">* sin ( <font color=\"DarkViolet\">b </font><font color=\"white\">* </font><font color=\"red\">x </font><font color=\"white\">+ </font><font color=\"DarkSlateGrey\">c </font><font color=\"white\">) + </font><font color=\"DeepPink\"> d</font></font></b></center>"
            createAttributedString(htmlString, label: formulaLabel)
            
            htmlString = String(format: "<center><b><font size=5><font color=\"GreenYellow\">y</font><font color=\"white\">=</font><font color=\"DarkTurquoise\">%.1f</font><font color=\"white\"> * sin (<font color=\"DarkViolet\">%.2f</font><font color=\"white\">*<font color=\"red\">x</font><font color=\"white\">+</font><font color=\"DarkSlateGrey\">%.1f</font><font color=\"white\">)+</font><font color=\"DeepPink\">%.1f</font></font></b></center>", graphView.a/10, graphView.b*10, graphView.c/10, graphView.d/10)
            createAttributedString(htmlString, label: formulaCurrentLabel)
        }
    }
    
    func createAttributedString(htmlString: String, label: UILabel) {
        let encodedData = htmlString.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            label.attributedText = attributedString
            
        } catch _ {
            print("Cannot create attributed String")
        }
    }

    // MARK: UPDATE INTERFACE
    func updateInterface() {
        currentStageLabel.text = "Stage: \(currentStage)"
        clearDrawing()
        cancelAnimations = false
        
        ySlider.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        graphView.xSlider = xSlider
        graphView.ySlider = ySlider
        graphView.mainView = self
        graphView.translateSize = CGPointMake(100, 100)
        graphView.translateValue = 100
        
        slider1Slider.thumbTintColor = colorA
        slider2Slider.thumbTintColor = colorB
        slider3Slider.thumbTintColor = colorC
        slider4Slider.thumbTintColor = colorD
        
        slider1Slider.minimumTrackTintColor = colorA
        slider2Slider.minimumTrackTintColor = colorB
        slider3Slider.minimumTrackTintColor = colorC
        slider4Slider.minimumTrackTintColor = colorD
        
        slider1Name.textColor = colorA
        slider2Name.textColor = colorB
        slider3Name.textColor = colorC
        slider4Name.textColor = colorD
        
        slider1Value.textColor = colorA
        slider2Value.textColor = colorB
        slider3Value.textColor = colorC
        slider4Value.textColor = colorD
        
        for view in self.view.subviews {
            if view != graphView && view != instructionsLabel {
                view.layer.cornerRadius = 10
            }
        }
        
        // Adjust for stages
        switch currentStage {
        case 0:
            graphView.a  = 0
            graphView.b  = 0
            graphView.c  = 0
            graphView.d  = 0
            graphView.m  = 1
            graphView.translateSize  = CGPointMake(100, 100)
            graphView.translateValue = 100
            slider1Slider.maximumValue  = 10
            slider1Slider.minimumValue  = -10
            slider1Slider.value  = Float(graphView.b)
            slider2Slider.maximumValue  = -100
            slider2Slider.minimumValue  = 400
            slider2Slider.value  = Float(graphView.b)
            slider3Slider.maximumValue  = 10
            slider3Slider.minimumValue  = -10
            slider3Slider.value  = Float(graphView.c)
            slider4Slider.maximumValue  = 400
            slider4Slider.minimumValue  = -200
            slider4Slider.value  = Float(graphView.d)
            xSlider.value  = -50
            xValueTicker  = -50
            ySlider.value  = Float(graphView.yForX(Double(xSlider.value)))
            instructionsLabel.text  = "Let me show you how this works! \n\nWe have the blue line to follow.\n\nUse the red and green sliders. \n\nPress start to see a demonstration."
            slider1Name.text  = "m"
            slider1Value.text  = String(format: "%.1f", graphView.m)
            slider2Value.text  = String(format: "%.1f", graphView.b)
            slider3Value.text  = String(format: "%.1f", graphView.c/10)
            slider4Value.text  = String(format: "%.1f", graphView.d/10)
            autoXButton.hidden  = true
            autoYButton.hidden  = true
            clearDrawingButton.hidden  = true
            drawingTableView.hidden  = true
            graphView.drawIntersectionPoint  = false
            graphView.drawNumbers  = false
            graphView.drawSinCos  = false
            instructionsBottomLabel.hidden  = true
            nextButton.hidden  = false
            paramView.hidden  = true
            prevButton.hidden  = true
            settingsView.hidden  = true
            slider3Name.hidden  = true
            slider3Slider.hidden  = true
            slider3Value.hidden  = true
            slider4Name.hidden  = true
            slider4Slider.hidden  = true
            slider4Value.hidden  = true
            xLabel.hidden  = true
            xSlider.userInteractionEnabled  = false
            xSliderAuto  = true
            yLabel.hidden  = true
            ySlider.userInteractionEnabled  = false
            ySliderAuto  = true
            speedSlider.value = 1
            speedSliderAction()
            break
        case 1:
            graphView.a  = 0
            graphView.b  = 0
            graphView.c  = 0
            graphView.d  = 0
            graphView.m  = 1
            graphView.translateSize  = CGPointMake(100, 100)
            graphView.translateValue = 100
            slider1Slider.maximumValue  = 10
            slider1Slider.minimumValue  = -10
            slider1Slider.value  = Float(graphView.b)
            slider2Slider.maximumValue  = -100
            slider2Slider.minimumValue  = 400
            slider2Slider.value  = Float(graphView.b)
            slider3Slider.maximumValue  = 10
            slider3Slider.minimumValue  = -10
            slider3Slider.value  = Float(graphView.c)
            slider4Slider.maximumValue  = 400
            slider4Slider.minimumValue  = -200
            slider4Slider.value  = Float(graphView.d)
            xSlider.value  = -50
            xValueTicker  = -50
            ySlider.value  = Float(graphView.yForX(Double(xSlider.value)))
            instructionsLabel.text  = "Got it? \n\nNow it's your turn. \n\nI will move green and you move the red. \n\n Press Start when your are ready!\n\n\nYou can change the speed of how fast I go below."
            slider1Name.text  = "m"
            slider1Value.text  = String(format: "%.1f", graphView.m)
            slider2Value.text  = String(format: "%.1f", graphView.b)
            slider3Value.text  = String(format: "%.1f", graphView.c/10)
            slider4Value.text  = String(format: "%.1f", graphView.d/10)
            autoXButton.hidden  = true
            autoYButton.hidden  = false
            clearDrawingButton.hidden  = false
            drawingTableView.hidden  = true
            graphView.drawIntersectionPoint  = false
            graphView.drawNumbers  = false
            graphView.drawSinCos  = false
            instructionsBottomLabel.hidden  = true
            nextButton.hidden  = false
            paramView.hidden  = true
            prevButton.hidden  = false
            settingsView.hidden  = false
            slider3Name.hidden  = true
            slider3Slider.hidden  = true
            slider3Value.hidden  = true
            slider4Name.hidden  = true
            slider4Slider.hidden  = true
            slider4Value.hidden  = true
            xLabel.hidden  = true
            xSlider.userInteractionEnabled  = true
            xSliderAuto  = false
            yLabel.hidden  = true
            ySlider.userInteractionEnabled  = false
            ySliderAuto  = true
            break
        case 2:
            graphView.a  = 0
            graphView.b  = 0
            graphView.c  = 0
            graphView.d  = 0
            graphView.m  = 1
            graphView.translateSize  = CGPointMake(100, 100)
            graphView.translateValue = 100
            slider1Slider.maximumValue  = 10
            slider1Slider.minimumValue  = -10
            slider1Slider.value  = Float(graphView.b)
            slider2Slider.maximumValue  = -100
            slider2Slider.minimumValue  = 400
            slider2Slider.value  = Float(graphView.b)
            slider3Slider.maximumValue  = 10
            slider3Slider.minimumValue  = -10
            slider3Slider.value  = Float(graphView.c)
            slider4Slider.maximumValue  = 400
            slider4Slider.minimumValue  = -200
            slider4Slider.value  = Float(graphView.d)
            xSlider.value  = -50
            xValueTicker  = -50
            ySlider.value  = Float(graphView.yForX(Double(xSlider.value)))
            instructionsLabel.text  = "Great - let's switch! \n\nNow I control the red.\n\nYou control the green.\n\n"
            slider1Name.text  = "m"
            slider1Value.text  = String(format: "%.1f", graphView.m)
            slider2Value.text  = String(format: "%.1f", graphView.b)
            slider3Value.text  = String(format: "%.1f", graphView.c/10)
            slider4Value.text  = String(format: "%.1f", graphView.d/10)
            autoXButton.hidden  = false
            autoYButton.hidden  = true
            clearDrawingButton.hidden  = false
            drawingTableView.hidden  = true
            graphView.drawIntersectionPoint  = false
            graphView.drawNumbers  = false
            graphView.drawSinCos  = false
            instructionsBottomLabel.hidden  = true
            nextButton.hidden  = false
            paramView.hidden  = true
            prevButton.hidden  = false
            settingsView.hidden  = false
            slider3Name.hidden  = true
            slider3Slider.hidden  = true
            slider3Value.hidden  = true
            slider4Name.hidden  = true
            slider4Slider.hidden  = true
            slider4Value.hidden  = true
            xLabel.hidden  = true
            xSlider.userInteractionEnabled  = false
            xSliderAuto  = true
            yLabel.hidden  = true
            ySlider.userInteractionEnabled  = true
            ySliderAuto  = false
            break
        case 3:
            graphView.a  = 0
            graphView.b  = 0
            graphView.c  = 0
            graphView.d  = 0
            graphView.m  = 1
            graphView.translateSize  = CGPointMake(100, 100)
            graphView.translateValue = 100
            slider1Slider.maximumValue  = 10
            slider1Slider.minimumValue  = -10
            slider1Slider.value  = Float(graphView.b)
            slider2Slider.maximumValue  = -100
            slider2Slider.minimumValue  = 400
            slider2Slider.value  = Float(graphView.b)
            slider3Slider.maximumValue  = 10
            slider3Slider.minimumValue  = -10
            slider3Slider.value  = Float(graphView.c)
            slider4Slider.maximumValue  = 400
            slider4Slider.minimumValue  = -200
            slider4Slider.value  = Float(graphView.d)
            xSlider.value  = -50
            xValueTicker  = -50
            ySlider.value  = Float(graphView.yForX(Double(xSlider.value)))
            instructionsLabel.text  = "Awesome!\n\nNow you control both!\n\nNotice we now see numbers all over.\n\nX axis is RED and the Y axis is GREEN.\n\nWe can see values for your drawing.\n\nWe can see the formula of the blue line!"
            instructionsBottomLabel.text = "You now control both RED and GREEN.\n\n Explore more graphs!\n Click on the blue buttons on the right!"
            slider1Name.text  = "m"
            slider1Value.text  = String(format: "%.1f", graphView.m)
            slider2Value.text  = String(format: "%.1f", graphView.b)
            slider3Value.text  = String(format: "%.1f", graphView.c/10)
            slider4Value.text  = String(format: "%.1f", graphView.d/10)
            autoXButton.hidden  = false
            autoYButton.hidden  = false
            clearDrawingButton.hidden  = false
            drawingTableView.hidden  = false
            graphView.drawIntersectionPoint  = false
            graphView.drawNumbers  = true
            graphView.drawSinCos  = false
            instructionsBottomLabel.hidden  = false
            nextButton.hidden  = false
            paramView.hidden  = true
            prevButton.hidden  = false
            settingsView.hidden  = false
            slider3Name.hidden  = true
            slider3Slider.hidden  = true
            slider3Value.hidden  = true
            slider4Name.hidden  = true
            slider4Slider.hidden  = true
            slider4Value.hidden  = true
            xLabel.hidden  = false
            xSlider.userInteractionEnabled  = true
            xSliderAuto  = false
            yLabel.hidden  = false
            ySlider.userInteractionEnabled  = true
            ySliderAuto  = false
            break
        case 4:
            graphView.a  = 0
            graphView.b  = 150
            graphView.c  = 0
            graphView.d  = 0
            graphView.m  = 0.2
            graphView.translateSize  = CGPointMake(100, 100)
            graphView.translateValue = 100
            slider1Slider.maximumValue  = 10
            slider1Slider.minimumValue  = -10
            slider1Slider.value  = Float(graphView.b)
            slider2Slider.maximumValue  = -100
            slider2Slider.minimumValue  = 400
            slider2Slider.value  = Float(graphView.b)
            slider3Slider.maximumValue  = 10
            slider3Slider.minimumValue  = -10
            slider3Slider.value  = Float(graphView.c)
            slider4Slider.maximumValue  = 400
            slider4Slider.minimumValue  = -200
            slider4Slider.value  = Float(graphView.d)
            xSlider.value  = -50
            xValueTicker  = -50
            ySlider.value  = Float(graphView.yForX(Double(xSlider.value)))
            instructionsLabel.text  = "Change parameters of the blue line\n\nPlay around with the sliders.\n\n Try to notice what changes."
            slider1Name.text  = "m"
            slider1Value.text  = String(format: "%.1f", graphView.m)
            slider2Value.text  = String(format: "%.1f", graphView.b)
            slider3Value.text  = String(format: "%.1f", graphView.c/10)
            slider4Value.text  = String(format: "%.1f", graphView.d/10)
            autoXButton.hidden  = false
            autoYButton.hidden  = false
            clearDrawingButton.hidden  = false
            drawingTableView.hidden  = false
            graphView.drawIntersectionPoint  = true
            graphView.drawNumbers  = true
            graphView.drawSinCos  = false
            instructionsBottomLabel.hidden  = true
            nextButton.hidden  = false
            paramView.hidden  = false
            prevButton.hidden  = false
            settingsView.hidden  = false
            slider3Name.hidden  = true
            slider3Slider.hidden  = true
            slider3Value.hidden  = true
            slider4Name.hidden  = true
            slider4Slider.hidden  = true
            slider4Value.hidden  = true
            xLabel.hidden  = false
            xSlider.userInteractionEnabled  = true
            xSliderAuto  = false
            yLabel.hidden  = false
            ySlider.userInteractionEnabled  = true
            ySliderAuto  = false
            break
        case 5:
            graphView.a  = 100
            graphView.b  = 0.01
            graphView.c  = 0.3
            graphView.d  = 8.0
            graphView.m  = 1
            graphView.translateSize  = CGPointMake(150, graphView.frame.height/2)
            graphView.translateValue = 150
            slider1Slider.maximumValue  = 400
            slider1Slider.minimumValue  = 0
            slider1Slider.value  = Float(graphView.a)
            slider2Slider.maximumValue  = 0.1
            slider2Slider.minimumValue  = 0
            slider2Slider.value  = Float(graphView.b)
            slider3Slider.maximumValue  = 10
            slider3Slider.minimumValue  = -10
            slider3Slider.value  = Float(graphView.c)
            slider4Slider.maximumValue  = 400
            slider4Slider.minimumValue  = -200
            slider4Slider.value  = Float(graphView.d)
            xSlider.value  = -100
            xValueTicker  = -50
            ySlider.value  = Float(graphView.yForX(Double(xSlider.value)))
            instructionsLabel.text  = "Sin waves!\n\nMany parameters to play with."
            slider1Name.text  = "a"
            slider1Value.text  = String(format: "%.1f", graphView.a/10)
            slider2Value.text  = String(format: "%.2f", graphView.b*10)
            slider3Value.text  = String(format: "%.1f", graphView.c/10)
            slider4Value.text  = String(format: "%.1f", graphView.d/10)
            autoXButton.hidden  = false
            autoYButton.hidden  = false
            clearDrawingButton.hidden  = false
            drawingTableView.hidden  = false
            graphView.drawIntersectionPoint  = true
            graphView.drawNumbers  = true
            graphView.drawSinCos  = true
            instructionsBottomLabel.hidden  = true
            nextButton.hidden  = true
            paramView.hidden  = false
            prevButton.hidden  = false
            settingsView.hidden  = false
            slider3Name.hidden  = false
            slider3Slider.hidden  = false
            slider3Value.hidden  = false
            slider4Name.hidden  = false
            slider4Slider.hidden  = false
            slider4Value.hidden  = false
            xLabel.hidden  = false
            xSlider.userInteractionEnabled  = true
            xSliderAuto  = false
            yLabel.hidden  = false
            ySlider.userInteractionEnabled  = true
            ySliderAuto  = false
            break
        default:
            break
        }
        
        // Stage dependent tasks
        
        xSlider.minimumValue = Float(-graphView.translateSize!.x)
        xSlider.maximumValue = Float(graphView.frame.width) - Float(graphView.translateSize!.x)
        
        ySlider.minimumValue = Float(-graphView.translateSize!.y)
        ySlider.maximumValue = Float(graphView.frame.height) - Float(graphView.translateSize!.y)
        
        xLabel.text = String(format: "X: %.1f", xSlider.value/10)
        yLabel.text = String(format: "Y: %.1f", ySlider.value/10)
        
        writeFormulas()
        showInstructions(false)

    }

    @IBAction func startButtonAction() {
        switch currentStage {
        case 0:
            xSliderAuto = true
            ySliderAuto = true
            countDown()
        case 1:
            xSliderAuto = false
            ySliderAuto = true
            countDown()
        case 2:
            xSliderAuto = true
            ySliderAuto = false
            countDown()
        case 3:
            instructionsLabel.text = "Play with AutoX and AutoY"
            hideInstructions()
        case 4:
            instructionsLabel.text = "Play with parameters"
            hideInstructions()
        case 5:
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
            instructionsBottomLabel.hidden = false
            instructionsBottomLabel.text = "Observe how the red and the green move at the same speed!"
        case 1:
            instructionsBottomLabel.hidden = false
            instructionsBottomLabel.text = "Move the RED slider at the same speed as I do."
        case 2:
            instructionsBottomLabel.hidden = false
            instructionsBottomLabel.text = "Move the GREEN slider at the same speed as I do."
        default:
            break
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("countDownDone", object: nil)
    }
    
    func sliderAnimationEnded() {
        
        switch currentStage {
        case 0:
            currentStage = 1
        case 1:
            currentStage = 2
        case 2:
            currentStage = 3
        default:
            break
        }
        
        updateInterface()
    }
}

