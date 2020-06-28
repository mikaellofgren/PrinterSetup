//
//  AppDelegate.swift
//  PrinterSetup
//
//  Created by Mikael Löfgren on 2020-03-27.
//  Copyright © 2020 Mikael Löfgren. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var spinner: NSProgressIndicator!
    @IBOutlet weak var window: NSWindow!
    @IBOutlet var printerslistPopup: NSPopUpButton!
    @IBOutlet var finalOutputTextField: NSTextView!
    @IBOutlet var printerPPDPopup: NSPopUpButton!
    @IBOutlet var cupsNameTextfield: NSTextField!
    @IBOutlet var printerNameTextField: NSTextField!
    @IBOutlet var printerLocationTextField: NSTextField!
    @IBOutlet var printerProtocolPopup: NSPopUpButton!
    @IBOutlet var printerIpaddressComboBox: NSComboBox!
    @IBOutlet var exportPopUp: NSPopUpButton!
    
    @IBOutlet var printerIPmenu: NSMenuItem!
    @IBOutlet var preferencesWindow: NSView!
    
   // Preferences
    @IBOutlet var versionTextField: NSTextField!
    @IBOutlet var identifierTextField: NSTextField!
    @IBOutlet var signPKGButton: NSButton!
    @IBOutlet var certificatePopUp: NSComboBox!
    @IBOutlet var commandColor: NSColorWell!
    @IBOutlet var variableColor: NSColorWell!
    @IBOutlet var enableCupsWebbutton: NSButton!
    @IBOutlet var cupsURLbutton: NSButton!
    
    
    // Preferences
    @IBAction func versionFieldSender(_ sender: NSTextField) {
       createPlist()
    }
    
    @IBAction func identifierFieldSender(_ sender: NSTextField) {
      identifierCheck ()
      createPlist()
    }
  
    @IBAction func signPKGButtonPressed(_ sender: NSButton) {
        statusCertificateCheckbox = sender.state.rawValue
        certificateCheckBox ()
        createPlist()
    }
 
       @IBAction func commandColorSender(_ sender: NSColorWell) {
        selectedCommandColor = sender.color
        generateFinalOutputTextField ()
        }
        
        @IBAction func variabelColorSender(_ sender: NSColorWell) {
        selectedVariableColor = sender.color
        generateFinalOutputTextField ()
        
    }
        
    
    @IBAction func enableCupsWebInterface(_ sender: NSButton) {
        statusCupsCheckbox = sender.state.rawValue
        cupsCheckBox ()
        }
    
    @IBAction func openCupsWebInterface(_ sender: Any) {
        let url = URL(string: "http://127.0.0.1:631")!
               if NSWorkspace.shared.open(url) {
    }
    }
    
    
    
    
    // Export options
    @IBAction func lookupPrinterIp(_ sender: NSMenuItem) {
        lookupDNSSDtoIP ()
    }
    
    @IBAction func noPayloadPkg(_ sender: Any) {
        exportAsPkg ()
       }
   
    @IBAction func munkiPkgInfo(_ sender: Any) {
    exportAsMunkiPkgInfo ()
    }
   
    @IBAction func outputAsPrinter(_ sender: Any) {
        addOutputAsPrinter ()
       }
   
  
    @IBAction func selectedPrinterSender(_ sender: NSPopUpButton) {
      selectedPrinterFunction ()
                  }
    
    @IBAction func selectedPPDsender(_ sender: Any) {
        generateFinalOutputTextField ()
    }
    
    @IBAction func selectedCupsNameSender(_ sender: Any) {
         generateFinalOutputTextField ()
    }
    
    @IBAction func selectedPrinterNameSender(_ sender: Any) {
         generateFinalOutputTextField ()
    }
    
    @IBAction func selectedPrinterLocationSender(_ sender: Any) {
         generateFinalOutputTextField ()
    }
   
    @IBAction func selectedProtocolSender(_ sender: Any) {
        generateFinalOutputTextField ()
    }
    
    @IBAction func selectedPrinterIpSender(_ sender: Any) {
        generateFinalOutputTextField ()
    }
    
func applicationDidFinishLaunching(_ aNotification: Notification) {
    func appDelegate() -> AppDelegate {
            return NSApplication.shared.delegate as! AppDelegate
        }
            // Start everything here
            appDelegate().finalOutputTextField.textStorage?.append(NSAttributedString(string:"Before start we need to index all your PPD files...This message will self-destruct when done"))
            appDelegate().spinner.isHidden=false
            self.spinner.startAnimation(self)
            runBackgroundPPDindex ()
            getAllPrinters()
            clearEveryPrinterFields ()
            readPlist()
           }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        createPlist()
        // If tempfolder exist
        if FileManager.default.fileExists(atPath: "/tmp/PrinterSetup") {
        // Delete tempfolder
        try? FileManager.default.removeItem(atPath: "/tmp/PrinterSetup")
        }
        exit(0);
        
        
    }


}

