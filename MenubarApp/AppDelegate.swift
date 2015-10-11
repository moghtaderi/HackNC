//
//  AppDelegate.swift
//  MenubarApp
//
//  Created by Reza Moghtaderi on 10/10/2015.
//  Copyright (c) 2015 Reza Moghtaderi. All rights reserved.
//

import Cocoa
import ORSSerial

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ORSSerialPortDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var distanceLabel: NSMenuItem!
    var serialPort: ORSSerialPort!
    var timer: NSTimer!
    var currentZoomLevel: Int?
    var desiredZoomLevel: Int?
    var zoomInScript: NSAppleScript!
    var zoomOutScript: NSAppleScript!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let icon = NSImage(named: "statusIcon")
        icon?.template = true
        
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        serialPort = ORSSerialPort(path: "/dev/cu.usbmodem1411")
        serialPort?.baudRate = 76800
        serialPort?.open()
        serialPort?.delegate = self
    }
    
    
    @IBAction func toggleClicked(sender: NSMenuItem) {
        
        let message : Character = "1"
        let data = String(message).dataUsingEncoding(NSUTF8StringEncoding)
        serialPort?.sendRequest(ORSSerialRequest(dataToSend: data!, userInfo: nil, timeoutInterval: -1, responseDescriptor: nil))
        
        let tell: String = "tell application \"System Events\"\n"
        let pressKeys: String = "keystroke \"-\" using {command down, option down}\n"
        let pressKeys2: String = "keystroke \"+\" using {command down, option down}\n"
        let endTell: String = "end tell"
        zoomOutScript = NSAppleScript(source: tell + pressKeys + endTell)!
        zoomInScript = NSAppleScript(source: tell + pressKeys2 + endTell)!
        
        if(sender.state == NSOnState) {
            sender.state = NSOffState
            sender.title = "Enable Magic Zoom"
            distanceLabel.title = "Distance: N/A"
            timer.invalidate()
            for(var i = 0; i<40; i++){
                zoomOutScript.executeAndReturnError(nil)
                currentZoomLevel = 30
            }
        }
        else {
            sender.state = NSOnState
            distanceLabel.title = "Distance: 30 in"
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "update", userInfo: nil, repeats: false)
                sender.title = "Disable Magic Zoom"
            currentZoomLevel = 30
        }
    }
    
    func update(){
        updateZoom()
        if(abs(desiredZoomLevel!-currentZoomLevel!) > 3){
            timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "update", userInfo: nil, repeats: false)
        }else{
            timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "update", userInfo: nil, repeats: false)
        }
    }
    
    func updateZoom(){
        if(desiredZoomLevel > 5 && desiredZoomLevel < 40)
        {
        while(abs(desiredZoomLevel!-currentZoomLevel!)>3){
            if(desiredZoomLevel < currentZoomLevel){
                zoomInScript.executeAndReturnError(nil)
                    currentZoomLevel?--
                if(currentZoomLevel < 5){
                    currentZoomLevel = 5
                    desiredZoomLevel = 5
                }
            }else{
                zoomOutScript.executeAndReturnError(nil)
                currentZoomLevel?++
                if(currentZoomLevel > 25){
                    currentZoomLevel = 30
                    desiredZoomLevel = 30
                }
            }

        }
        }
    }
    
//    func zoomIn(){
//        let src = CGEventSourceCreate(CGEventSourceStateID(rawValue: 0)!)
//        
//        let cmdd = CGEventCreateKeyboardEvent(src, 0x37, true)
//        let cmdu = CGEventCreateKeyboardEvent(src, 0x37, false)
//        let optd = CGEventCreateKeyboardEvent(src, 0x3D, true)
//        let optu = CGEventCreateKeyboardEvent(src, 0x3D, false)
//        let plusd = CGEventCreateKeyboardEvent(src, 0x18, true)
//        let plusu = CGEventCreateKeyboardEvent(src, 0x18, false)
////        let minsd = CGEventCreateKeyboardEvent(src, 0x4E, true)
////        let minsu = CGEventCreateKeyboardEvent(src, 0x4E, false)
//        
//        let flags = CGEventFlags.MaskAlternate.rawValue & CGEventFlags.MaskCommand.rawValue
//        CGEventSetFlags(plusd, CGEventFlags(rawValue: flags)!)
//        
//        
//        let loc = CGEventTapLocation(rawValue: 0)
//        
//        CGEventPost(loc!, cmdd)
//        CGEventPost(loc!, optd)
//        CGEventPost(loc!, plusd)
//        CGEventPost(loc!, plusu)
//        CGEventPost(loc!, optu)
//        CGEventPost(loc!, cmdu)
//    }
//    
//    func zoomOut(){
//        
//    }
    
    func serialPort(serialPort: ORSSerialPort, requestDidTimeout request: ORSSerialRequest) {
        //print("REQUEST TIMED OUT!")
    }
    
    func serialPort(serialPort: ORSSerialPort, didReceiveResponse responseData: NSData, toRequest request: ORSSerialRequest) {
        print("response: \(NSString(data: responseData, encoding: NSUTF8StringEncoding))")
    }
    
    func serialPort(serialPort: ORSSerialPort, didReceiveData data: NSData) {
        if((timer?.valid) != nil){
            print(NSString(data: data, encoding: NSUTF8StringEncoding)!)
            desiredZoomLevel = NSString(data: data, encoding: NSUTF8StringEncoding)?.integerValue
            distanceLabel.title = "Distance: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)"
        }
    }
    
    func serialPortWasRemovedFromSystem(serialPort: ORSSerialPort) {
        print("PORT REMOVED!")
        serialPort.close()
    }

}


extension NSData {
    
    /// Create hexadecimal string representation of NSData object.
    ///
    /// :returns: String representation of this NSData object.
    
    func hexadecimalString() -> String {
        let string = NSMutableString(capacity: length * 2)
        var byte: UInt8 = 0
        
        for i in 0 ..< length {
            getBytes(&byte, range: NSMakeRange(i, 1))
            string.appendFormat("%02x", byte)
        }
        
        return string as String
    }
}

