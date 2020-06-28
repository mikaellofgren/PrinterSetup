//
//  Functions.swift
//  PrinterSetup
//
//  Created by Mikael Löfgren on 2020-03-28.
//  Copyright © 2020 Mikael Löfgren. All rights reserved.
//
import Cocoa
import AppKit
import Foundation

// Create a subclass of AppDelegate
   func appDelegate() -> AppDelegate {
         return NSApplication.shared.delegate as! AppDelegate
     }
    
    var printersArray = [String] ()
    var everyprintersArray = [(CupsPrinterName: String, CupsPPD:String,Printername:String,ShortNickName:String,Location:String,Protocol:String,IP:String)] ()
    var printersProtocolArray = [String] ()
    var printersArrayTemp = [String] ()
    var selectedPrinter = appDelegate().printerslistPopup.titleOfSelectedItem!
    // Variables for tuple printercard
    var cupsprintername = ""
    var cupsppd = ""
    var printername = ""
    var shortnickname = ""
    var location = ""
    var protocolandIp = ""
    var printerprotcol = ""
    var ipaddress = ""
    var printercard = (CupsPrinterName: cupsprintername, CupsPPD: cupsppd, Printername: printername, ShortNickName: shortnickname, Location: location, Protocol: printerprotcol, IP: ipaddress)
    var dnssdName = ""
    var allPPDs = ""
    let ppdListFile = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/PrinterSetup/ppds.txt").path
    let ppdListFilePath = URL(fileURLWithPath: ppdListFile )
    var selectedShortNickName = everyprintersArray.first{ $0.CupsPrinterName == selectedPrinter }?.ShortNickName ?? ""
    var protocolArray = ["lpd","dnssd","smb", "ipp","ipps","http","https"]
    var allPPDsArray = [String] ()
    var shortNickNameAndPPDsArray = [(ShortNickName:String, PPD:String)] ()
    var sortedPPDsArray = [String] ()
    var printerOptionsArray = [String] ()
    var finalOutputString = ""
    var manualCupsName = ""
    var statusCertificateCheckbox = Int ()
    var statusCupsCheckbox = Int ()
    var cupsWebInterface = shell("cupsctl | grep 'WebInterface'").replacingOccurrences(of: "\n", with: "", options: [.regularExpression, .caseInsensitive])
    let plistFile  = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("/Library/Preferences/se.dicom.printersetup.plist").path
    let plistPath = URL(fileURLWithPath: plistFile)
    var versionNumberRead = String ()
    var pkgIdentifierRead = String ()
    var devCertificateRead = String ()
    var selectedCommandColor = NSColor.black
    var selectedVariableColor = NSColor.purple
    var pkgSigned = ""
    var pkgUnSigned = ""




func clearEveryPrinterFields () {
    appDelegate().printerslistPopup.addItems(withTitles: printersArray)
    appDelegate().printerslistPopup.selectItem(at: 0)
    appDelegate().printerPPDPopup.removeAllItems()
    appDelegate().cupsNameTextfield.stringValue = ""
    appDelegate().printerNameTextField.stringValue = ""
    appDelegate().printerLocationTextField.stringValue = ""
    appDelegate().printerProtocolPopup.removeAllItems()
    appDelegate().printerIpaddressComboBox.removeAllItems()
    appDelegate().printerIpaddressComboBox.addItem(withObjectValue:"")
    appDelegate().printerIpaddressComboBox.selectItem(withObjectValue:"")
    
    
    if cupsWebInterface == "WebInterface=no" {
        appDelegate().enableCupsWebbutton.state = NSControl.StateValue.off
        statusCupsCheckbox = 0
        appDelegate().cupsURLbutton.isHidden=true
    } else {
        appDelegate().enableCupsWebbutton.state = NSControl.StateValue.on
        statusCupsCheckbox = 1
        appDelegate().cupsURLbutton.isHidden=false
        }
}

func createcupsNameTextfield () {
        appDelegate().cupsNameTextfield.stringValue = ""
        appDelegate().cupsNameTextfield.stringValue = everyprintersArray.first{ $0.CupsPrinterName == selectedPrinter }?.CupsPrinterName ?? ""
    }

func createprinterNameTextField () {
        appDelegate().printerNameTextField.stringValue = ""
        appDelegate().printerNameTextField.stringValue = everyprintersArray.first{ $0.CupsPrinterName == selectedPrinter }?.Printername ?? ""
    }

func createprinterPPDsPopup () {
    appDelegate().printerPPDPopup.removeAllItems()
    let choosenPrinterShortNickName = everyprintersArray.first{ $0.CupsPrinterName == selectedPrinter }?.ShortNickName ?? ""
    sortedPPDsArray.removeAll()
    sortedPPDsArray += shortNickNameAndPPDsArray.filter{$0.ShortNickName == choosenPrinterShortNickName }.map{ return $0.PPD }
    sortPPDsArray ()
    appDelegate().printerPPDPopup.addItems(withTitles: sortedPPDsArray)
    appDelegate().printerPPDPopup.selectItem(at: 0)
    }

func createPrinterProtocolPopup () {
        appDelegate().printerProtocolPopup.removeAllItems()
        appDelegate().printerProtocolPopup.addItem(withTitle: everyprintersArray.first{ $0.CupsPrinterName == selectedPrinter }?.Protocol ?? "")
        appDelegate().printerProtocolPopup.addItems(withTitles: protocolArray)
        appDelegate().printerProtocolPopup.selectItem(withTitle: everyprintersArray.first{ $0.CupsPrinterName == selectedPrinter }?.Protocol ?? "")
    if appDelegate().printerProtocolPopup.titleOfSelectedItem! == "dnssd" {
        appDelegate().printerIPmenu.isHidden=false
    } else {
        appDelegate().printerIPmenu.isHidden=true
    }
    
    }

func createprinterIpaddressComboBox () {
        appDelegate().printerIpaddressComboBox.removeAllItems()
        appDelegate().printerIpaddressComboBox.addItem(withObjectValue: everyprintersArray.first{ $0.CupsPrinterName == selectedPrinter }?.IP ?? "")
        appDelegate().printerIpaddressComboBox.selectItem(withObjectValue: everyprintersArray.first{ $0.CupsPrinterName == selectedPrinter }?.IP ?? "")
    }

func createprinterLocationTextField () {
        appDelegate().printerLocationTextField.stringValue = everyprintersArray.first{ $0.CupsPrinterName == selectedPrinter }?.Location ?? ""
    }



func generateFinalOutputTextField () {
    let commandAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: selectedCommandColor]
    let variableAttributes = [NSAttributedString.Key.foregroundColor: selectedVariableColor]
    
   if selectedPrinter.contains("[Choose a printer]"){
        return }
    else {
        
        // Variables for Finaloutput
        var finalPPDName = ""
        if appDelegate().printerPPDPopup.titleOfSelectedItem != nil {
            finalPPDName = appDelegate().printerPPDPopup.titleOfSelectedItem!
        } else {
            let warning = NSAlert()
            warning.icon = NSImage(named: "Warning")
            warning.addButton(withTitle: "OK")
            warning.messageText = "Couldnt find matching PPD"
            warning.alertStyle = NSAlert.Style.warning
            warning.informativeText = """
            Make sure you got right PPD file installed
            """
            warning.runModal()
            appDelegate().finalOutputTextField.string = ""
            return }
        
        let finalCupsName = cleanCupsName(appDelegate().cupsNameTextfield.stringValue)
        let finalPrinterName = appDelegate().printerNameTextField.stringValue
        
        var finalLocation = ""
        if appDelegate().printerLocationTextField.stringValue == "" {
        } else {
            finalLocation = appDelegate().printerLocationTextField.stringValue
        }
        
        var finalProtocolName = ""
         if appDelegate().printerProtocolPopup.titleOfSelectedItem != nil {
            finalProtocolName = appDelegate().printerProtocolPopup.titleOfSelectedItem!
            } else {
            let warning = NSAlert()
                       warning.icon = NSImage(named: "Warning")
                       warning.addButton(withTitle: "OK")
                       warning.messageText = "Couldnt find matching Printer protocol"
                       warning.alertStyle = NSAlert.Style.warning
                       warning.informativeText = """
                       Make sure you using standard printer protocols
                       """
                       warning.runModal()
                       appDelegate().finalOutputTextField.string = ""
                   return }
        
        var finalIpAddress = ""
        if appDelegate().printerIpaddressComboBox.stringValue != "" {
            finalIpAddress = appDelegate().printerIpaddressComboBox.stringValue
           } else {
            let warning = NSAlert()
            warning.icon = NSImage(named: "Warning")
            warning.addButton(withTitle: "OK")
            warning.messageText = "Couldnt find matching printer Ip"
            warning.alertStyle = NSAlert.Style.warning
            warning.informativeText = """
            Make sure you using standard printer ip protocols
            """
            warning.runModal()
            appDelegate().finalOutputTextField.string = ""
                  return }
        
        // Get Printer Options
        generatePrinterOptions ()
        
        finalOutputString = """
        #!/bin/bash
        # Script created by PrinterSetup\n
        """
        finalOutputString += "/usr/sbin/lpadmin -p \"FINAL_CUPS_NAME\" \\\n"
        finalOutputString += "-E \\\n"
        finalOutputString += "-D \"FINAL_PRINTER_NAME\" \\\n"
        finalOutputString += "-P \"\(finalPPDName)\" \\\n"

    // Output Location if Locations contains something
        if appDelegate().printerLocationTextField.stringValue != "" {
        finalOutputString += "-L \"LOCATION\" \\\n"
            }
        finalOutputString += "-v \(finalProtocolName)://\(finalIpAddress) \\\n"

    //   Output options
             if printerOptionsArray.isEmpty {
             } else {
                for options in printerOptionsArray {
                    finalOutputString += "-o \(options) \\\n"
                 }
            }

     // Output not shared
        finalOutputString += "-o printer-is-shared=False \n"
           
        
        appDelegate().finalOutputTextField.string = ""
        appDelegate().finalOutputTextField.textStorage?.append(NSAttributedString(string: finalOutputString, attributes: commandAttributes))
    
         // Find Variables and color them
    
    func colorVariabels (range: String, variable: String) {
        let wholeOutput = (appDelegate().finalOutputTextField.textStorage as NSAttributedString?)!.string
        let range = (wholeOutput as NSString).range(of: "\(range)")
        let attributedReplaceText = NSAttributedString(string: "\(variable)", attributes: variableAttributes)
            appDelegate().finalOutputTextField.textStorage?.replaceCharacters(in: range, with: attributedReplaceText)
    }
    
    colorVariabels(range: "FINAL_CUPS_NAME", variable: "\(finalCupsName)")
    colorVariabels(range: "FINAL_PRINTER_NAME", variable: "\(finalPrinterName)")
    colorVariabels(range: "\(finalPPDName)", variable: "\(finalPPDName)")
    if appDelegate().printerLocationTextField.stringValue != "" {
        colorVariabels(range: "LOCATION", variable: "\(finalLocation)")
    }
    colorVariabels(range: "\(finalProtocolName)://\(finalIpAddress)", variable: "\(finalProtocolName)://\(finalIpAddress)")
    

    //   Color printer options
                 if printerOptionsArray.isEmpty {
                 } else {
                    for options in printerOptionsArray {
                        colorVariabels(range: "\(options)", variable: "\(options)")
                }
         }
    colorVariabels(range: "printer-is-shared=False", variable: "printer-is-shared=False")
    }
}


func lookupDNSSDtoIP () {
    if selectedPrinter.contains("[Choose a printer]"){
    appDelegate().exportPopUp.selectItem(at: 0)
    return }
   
    if appDelegate().printerIpaddressComboBox.stringValue != ""  {
    dnssdName = appDelegate().printerIpaddressComboBox.stringValue
    dnssdName = dnssdName.removingPercentEncoding!
    let removeFrom = (dnssdName.range(of: ".")?.lowerBound)
    dnssdName = String(dnssdName.prefix(upTo: removeFrom!))
    } else {return}
    
    
    func regexFunc (for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
            range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
        
        var findIpp = ""
        var findIpps = ""
        appDelegate().spinner.isHidden=false
        appDelegate().spinner.startAnimation(appDelegate())
    
    DispatchQueue.global(qos: .userInteractive).async {
      findIpp = shell("ippfind _ipp._tcp --literal-name '\(dnssdName)' --exec ping -qc 3 {service_hostname} \\;")
      findIpps = shell("ippfind _ipps._tcp --literal-name '\(dnssdName)' --exec ping -qc 3 {service_hostname} \\;")
                 
    DispatchQueue.main.async {
        appDelegate().spinner.isHidden=true
        appDelegate().spinner.stopAnimation(appDelegate())
        var tempIP = regexFunc(for: "(?<=\\().*(?=\\))", in: findIpp)
        tempIP += regexFunc(for: "(?<=\\().*(?=\\))", in: findIpps)

        let dnssdIp = Array(Set(tempIP))
      
        if dnssdIp.isEmpty{
            appDelegate().exportPopUp.selectItem(at: 0)
            let warning = NSAlert()
            warning.icon = NSImage(named: "Warning")
            warning.addButton(withTitle: "OK")
            warning.messageText = "Couldnt resolve to ip"
            warning.alertStyle = NSAlert.Style.warning
            warning.informativeText = """
            Try with this command in terminal.app:
            ippfind _ipp._tcp --literal-name '\(dnssdName)' --exec ping -qc 3 {service_hostname} \\;
            \n
            Also make sure that the printer is turned on and
            on the same network.
            """
            warning.runModal()
            return } else {
            appDelegate().printerProtocolPopup.setTitle("lpd")
            appDelegate().printerIpaddressComboBox.addItem(withObjectValue: dnssdIp.first!)
            appDelegate().printerIpaddressComboBox.selectItem(withObjectValue: dnssdIp.first!)
            appDelegate().exportPopUp.selectItem(at: 0)
            generateFinalOutputTextField ()
        }
        }
        
    
        }
    
    }


func exportAsPkg () {
    if selectedPrinter.contains("[Choose a printer]"){
    appDelegate().exportPopUp.selectItem(at: 0)
    return }
    
          // Save Dialog
            let dialog = NSSavePanel();
            dialog.message = "Select location for output";
            dialog.showsTagField = false;
            dialog.showsResizeIndicator    = true;
            dialog.showsHiddenFiles        = false;
            dialog.canCreateDirectories    = true;
            dialog.nameFieldStringValue = "\(selectedPrinter).pkg"
          
            
            if (dialog.runModal() == NSApplication.ModalResponse.OK) {
                let result = dialog.url // Pathname of the file
                if (result != nil) {
                    let path = result!.path
                    
                    // Create tempdir
                     let scriptsFolder = "/tmp/PrinterSetup/se.pkgscleaner/scripts"
                     let nopayloadFolder = "/tmp/PrinterSetup/se.pkgscleaner/nopayload"
                    
                   
                   if appDelegate().versionTextField.stringValue != "" {
                            versionNumberRead = cleanVersion(appDelegate().versionTextField.stringValue)
                          }
                       
                       if appDelegate().identifierTextField.stringValue != "" {
                           pkgIdentifierRead = appDelegate().identifierTextField.stringValue
                       } else {
                        pkgIdentifierRead = "se.printersetup"
                    }
                    
                    var selectedCertificate = ""
                    var outputPKG = ""
                    
                    do {
                       
                    try FileManager.default.createDirectory(atPath: scriptsFolder, withIntermediateDirectories: true, attributes: nil)
                        try FileManager.default.createDirectory(atPath: nopayloadFolder, withIntermediateDirectories: true, attributes: nil)
                        
                    } catch {
                        print(error)
                    }
                    
                    
                    // Convert scriptsFolder to URL
                    let DocumentDirURL = URL(fileURLWithPath: scriptsFolder )
                    
                    
                    // Get the text in textview to output to a tmp file for calling from pkgsbuild
                    // Save data to file
                    let fileName = "postinstall"
                    let fileURL = DocumentDirURL.appendingPathComponent(fileName)
                    let writeString = (appDelegate().finalOutputTextField.textStorage)!.string
                    
                    do {
                        // Write to the file
                        try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                    } catch let error as NSError {
                        print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
                    }
                    
                    // Remove Extended attributs and Chmod on tempfile
                    _ = shell("/usr/bin/xattr -c '\(fileURL.path)'")
                    _ = shell("/bin/chmod a+x '\(fileURL.path)'")
                   
                    
                // Output Signed pkg
                    if statusCertificateCheckbox == 1 {
                        selectedCertificate = appDelegate().certificatePopUp.stringValue
                        
                        if versionNumberRead != "" {
                        pkgSigned = shell("/usr/bin/pkgbuild --sign '\(selectedCertificate)' --identifier '\(pkgIdentifierRead)' --version '\(versionNumberRead)' --root '\(nopayloadFolder)' --scripts '\(scriptsFolder)' '\(path)'")
                        } else {
                        // If no Version is added then no pkginfo is written to package database
                       pkgSigned = shell("/usr/bin/pkgbuild --sign '\(selectedCertificate)' --identifier '\(pkgIdentifierRead)' --root '\(nopayloadFolder)' --scripts '\(scriptsFolder)' '\(path)'")
                        }
                    
                        outputPKG = pkgSigned as String
                    } else {
                         // Output UnSigned pkg
                        if versionNumberRead != "" {
                          pkgUnSigned = shell("/usr/bin/pkgbuild --identifier '\(pkgIdentifierRead)' --version '\(versionNumberRead)' --root '\(nopayloadFolder)' --scripts '\(scriptsFolder)' '\(path)'")
                        } else {
                        pkgUnSigned = shell("/usr/bin/pkgbuild --identifier '\(pkgIdentifierRead)' --root '\(nopayloadFolder)' --scripts '\(scriptsFolder)' '\(path)'")
                        }
                         outputPKG = pkgUnSigned as String
                    }
                    if outputPKG.contains("Wrote") {
                        
                        
                        let info = NSAlert()
                        info.icon = NSImage(named: "package")
                        info.addButton(withTitle: "OK")
                        info.alertStyle = NSAlert.Style.informational
                        info.messageText = "Successfully exported to:"
                        info.informativeText = "\(path)"
                        info.runModal()
                        
                       // Reset Export as option
                        appDelegate().exportPopUp.selectItem(at: 0)
                    } else {
                   
                        let warning = NSAlert()
                        warning.icon = NSImage(named: "Warning")
                        warning.addButton(withTitle: "OK")
                        warning.messageText = "Something went wrong"
                        warning.alertStyle = NSAlert.Style.warning
                        // Show warning dialog with differents output depending if signed or not
                        if statusCertificateCheckbox == 1 {
                        warning.informativeText = """
    Before you quit the app, try it manually by copy this command into terminal:

    /usr/bin/pkgbuild --sign \"\(selectedCertificate)\" --identifier se.pkgscleaner --root \(nopayloadFolder) --scripts \(scriptsFolder) \(path)
    """
                         } else {
                        warning.informativeText = """
    Before you quit the app, try it manually by copy this command into terminal:

    /usr/bin/pkgbuild --identifier se.pkgscleaner --root \(nopayloadFolder) --scripts \(scriptsFolder) \(path)
    """
                            }
                       
                        warning.runModal()
                        
                        // Reset Export as option
                        appDelegate().exportPopUp.selectItem(at: 0)
                    }
                }
            } else {
                // User clicked on "Cancel"
                // Dont do anything and reset Export as option
                appDelegate().exportPopUp.selectItem(at: 0)
                return
            }
            // End Save Dialog
}


func exportAsMunkiPkgInfo () {
    if selectedPrinter.contains("[Choose a printer]"){
        appDelegate().exportPopUp.selectItem(at: 0)
        return }
    
finalOutputString = (appDelegate().finalOutputTextField.textStorage as NSAttributedString?)!.string
manualCupsName = getCupsNameFromFinalOutput(finalOutputString)
manualCupsName = cleanCupsName(manualCupsName)

appDelegate().spinner.isHidden=false
appDelegate().spinner.startAnimation(appDelegate())

 // Check if Output Cupsname matches selectedPrinter, might been manually changed
               if manualCupsName != selectedPrinter {
               selectedPrinter = manualCupsName
               }
    
let pkgInfo = ("""
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>autoremove</key>
        <false></false>
        <key>catalogs</key>
        <array>
            <string>testing</string>
        </array>
        <key>description</key>
        <string></string>
        <key>display_name</key>
        <string>\(selectedPrinter)</string>
        <key>icon_name</key>
        <string></string>
        <key>installcheck_script</key>
        <string>#!/bin/bash
PRINTER_INSTALLED=$(/usr/bin/lpstat -p | /usr/bin/awk '{print $2}' | /usr/bin/grep "\(selectedPrinter)" | /usr/bin/head -1 )
if [ "$PRINTER_INSTALLED" = "\(selectedPrinter)" ]; then
echo "Printer "\(selectedPrinter)" already installed\"
exit 1
fi
exit</string>
        <key>installer_type</key>
        <string>nopkg</string>
        <key>minimum_os_version</key>
        <string>10.7.0</string>
        <key>name</key>
        <string>\(selectedPrinter)</string>
        <key>postinstall_script</key>
        <string>\(finalOutputString)exit 0</string>
        <key>requires</key>
        <array>
            <string></string>
        </array>
        <key>unattended_install</key>
        <true></true>
        <key>uninstall_method</key>
        <string>uninstall_script</string>
        <key>uninstall_script</key>
        <string>#!/bin/bash
/usr/sbin/lpadmin -x "\(selectedPrinter)\"
exit 0</string>
        <key>uninstallable</key>
        <true></true>
        <key>version</key>
        <string>1.0</string>
    </dict>
</plist>
""")
    
        // Save Dialog
           let dialog = NSSavePanel();
           dialog.showsResizeIndicator  = true;
           dialog.showsHiddenFiles      = false;
           dialog.canCreateDirectories  = true;

        // Default Save value, add .plist
         dialog.nameFieldStringValue = "\(selectedPrinter).plist"
          
           
           if (dialog.runModal() == NSApplication.ModalResponse.OK) {
               let result = dialog.url // Pathname of the file
               if (result != nil) {
                   let path = result!.path
                   
                    let documentDirURL = URL(fileURLWithPath: path)
                   // Save data to file
                   let fileURL = documentDirURL
                   let writeString = pkgInfo
                   do {
                       // Write to the file
                       try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                   } catch let error as NSError {
                       print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
                   }
                   
                   // plutil
                let plutilCheck =  shell("/usr/bin/plutil -lint -s '\(fileURL.path)'")
                if plutilCheck != "" {
                    let warning = NSAlert()
                                       warning.icon = NSImage(named: "Warning")
                                       warning.addButton(withTitle: "OK")
                                       warning.messageText = "Something went wrong"
                                       warning.alertStyle = NSAlert.Style.warning
                                       warning.informativeText = "Try again and check output syntax"
                                       warning.runModal()
                    return
                }
                  
                   
                // Reset Export as option
                appDelegate().spinner.isHidden=true
                appDelegate().spinner.stopAnimation(appDelegate())
                appDelegate().exportPopUp.selectItem(at: 0)
                   
                                let info = NSAlert()
                                    info.icon = NSImage(named: "monkey")
                                    info.addButton(withTitle: "OK")
                                    info.alertStyle = NSAlert.Style.informational
                                    info.messageText = "Successfully exported munki pkg info to:"
                                    info.informativeText = "\(path)"
                                    info.runModal()
                
               }
           } else {
            // User clicked on "Cancel"
            // Dont do anything and reset Export as option
            appDelegate().spinner.isHidden=true
            appDelegate().spinner.stopAnimation(appDelegate())
            appDelegate().exportPopUp.selectItem(at: 0)
               return
           }
           // End Save Dialog
}


func addOutputAsPrinter () {
    if selectedPrinter.contains("[Choose a printer]"){
    appDelegate().exportPopUp.selectItem(at: 0)
    return }
    
    finalOutputString = (appDelegate().finalOutputTextField.textStorage as NSAttributedString?)!.string
    // do we need to check user in lpadmin group
    manualCupsName = getCupsNameFromFinalOutput(finalOutputString)
    manualCupsName = cleanCupsName(manualCupsName)
    appDelegate().spinner.isHidden=false
    appDelegate().spinner.startAnimation(appDelegate())
    
    DispatchQueue.global(qos: .userInteractive).async {
           _ = shell(finalOutputString)
                   getAllPrinters()
                   
      
        DispatchQueue.main.async {
            // Back on the main thread
            appDelegate().printerslistPopup.removeAllItems()
            appDelegate().printerslistPopup.addItems(withTitles: printersArray)
            
           
          // Check if Output Cupsname matches CupsNameTextField, might been manually changed
            if manualCupsName == appDelegate().cupsNameTextfield.stringValue {
            appDelegate().printerslistPopup.selectItem(withTitle: appDelegate().cupsNameTextfield.stringValue)
            } else {
                appDelegate().printerslistPopup.selectItem(withTitle: manualCupsName)
            }
            appDelegate().spinner.isHidden=true
            appDelegate().spinner.stopAnimation(appDelegate())
            appDelegate().exportPopUp.selectItem(at: 0)
            selectedPrinterFunction ()
            
            let info = NSAlert()
            info.icon = NSImage(named: "printer")
            info.addButton(withTitle: "OK")
            info.alertStyle = NSAlert.Style.informational
            info.messageText = "Successfully added printer:"
            info.informativeText = "\(manualCupsName)"
            info.runModal()
        }
    }
    
}


func getCupsNameFromFinalOutput (_ inputString:String) -> String {
var outputString = ""
    let range = NSRange(location: 0, length: inputString.utf16.count)
    let regex = try? NSRegularExpression(pattern: "(\"\\w)(\\w+\")", options: .caseInsensitive)
if let match = regex?.firstMatch(in: inputString, options: [], range: range){
    if let wholeRange = Range(match.range(at: 0), in: inputString) {
      let wholeMatch = inputString[wholeRange]
        outputString = String(wholeMatch)
        outputString = outputString.replacingOccurrences(of: "\"", with: "")
        
    }
}
 return outputString
}


func generatePrinterOptions () {
    var choosenPPD = ""
    if appDelegate().printerPPDPopup.titleOfSelectedItem != nil {
        choosenPPD = appDelegate().printerPPDPopup.titleOfSelectedItem ?? ""
    } else {
        return }
    let choosenCupsPPD = everyprintersArray.first{ $0.CupsPrinterName == selectedPrinter }?.CupsPPD ?? ""
 
        // Create tempdir
        do {
        try FileManager.default.createDirectory(atPath: "/tmp/PrinterSetup", withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
        
        // Make sure we start clean
        for tempfiles in ["/tmp/PrinterSetup/choosen.ppd", "/tmp/PrinterSetup/choosen.ppd"] {
        if FileManager.default.fileExists(atPath: tempfiles) {
               // Delete file
               try? FileManager.default.removeItem(atPath: tempfiles)
               }
        }
        
        if choosenPPD.contains("sample.drv") {
            _ = shell("/usr/libexec/cups/daemon/cups-driverd cat 'drv:///sample.drv/generpcl.ppd' >/tmp/PrinterSetup/choosen.ppd")
            _ = shell("tr '\\r' '\\n' <'\(choosenCupsPPD)' >/tmp/PrinterSetup/cups.ppd")
        } else {
            if choosenPPD.contains("/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/PrintCore.framework/Versions/A/Resources/Generic.ppd") {
                _ = shell("tr '\\r' '\\n' < '/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/PrintCore.framework/Versions/A/Resources/Generic.ppd' >/tmp/PrinterSetup/choosen.ppd")
                _ = shell("tr '\\r' '\\n' <'\(choosenCupsPPD)' >/tmp/PrinterSetup/cups.ppd")
        } else {
                if choosenPPD.hasSuffix(".gz") {
                    _ = shell("gzip -d <'\(choosenPPD)' | tr '\\r\\n' '\\n' >/tmp/PrinterSetup/choosen.ppd")
                    _ = shell("tr '\\r' '\\n' <'\(choosenCupsPPD)' >/tmp/PrinterSetup/cups.ppd")
         } else {
                    _ = shell("tr '\\r' '\\n' <'\(choosenPPD)' >/tmp/PrinterSetup/choosen.ppd")
                    _ = shell("tr '\\r' '\\n' <'\(choosenCupsPPD)' >/tmp/PrinterSetup/cups.ppd")
                }
            }
        }


        let printerOptions = shell("diff '/private/tmp/PrinterSetup/choosen.ppd' '/private/tmp/PrinterSetup/cups.ppd'")
        var printerOptionsArrayTemp = [String] ()
        // Clear Arrays so we start clean
        printerOptionsArrayTemp.removeAll()
        printerOptionsArray.removeAll()
        printerOptionsArrayTemp = printerOptions.components(separatedBy: CharacterSet.newlines)
        
        
     printerOptionsArrayTemp.forEach {
        if $0.hasPrefix("> *Default") {
           var returnValue = ($0.replacingOccurrences(of: "> \\*Default", with: "", options: [.regularExpression, .caseInsensitive]))
           returnValue = (returnValue.replacingOccurrences(of: ": ", with: "=", options: [.regularExpression, .caseInsensitive]))
            printerOptionsArray += returnValue.components(separatedBy: CharacterSet.newlines)
           }
        }
    }


func getPrinterNameFromPPDs () {
   if selectedShortNickName == "Generic PostScript Printer" {
    appDelegate().printerPPDPopup.addItems(withTitles: ["/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/PrintCore.framework/Versions/A/Resources/Generic.ppd"] )
    appDelegate().printerPPDPopup.selectItem(at: 0)
    } else {
    if selectedShortNickName == "Generic PCL Laser Printer" {
        appDelegate().printerPPDPopup.addItems(withTitles: ["sample.drv/generpcl.ppd"] )
        appDelegate().printerPPDPopup.selectItem(at: 0)
    } else {
        createprinterPPDsPopup ()
        }
}
}


func shell(_ command: String) -> String {
       let task = Process()
       task.launchPath = "/bin/bash"
       task.arguments = ["-c", command]

       let pipe = Pipe()
       task.standardOutput = pipe
       task.launch()

       let data = pipe.fileHandleForReading.readDataToEndOfFile()
       let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

       return output
   }


// Get ShortNickName from CupsPPD, that we later use to find the "real" ppd
func getShortNickName (CupsPPD: String) -> String {
    var returnValue = ""
    var path = URL(fileURLWithPath: "")
    // if CupsPPD should be missing path /private/etc/cups/ppd/ then add it
    if CupsPPD.contains("/private/etc/cups/ppd/") {
        path = URL(fileURLWithPath: CupsPPD)
    } else {
        path = URL(fileURLWithPath: "/private/etc/cups/ppd/"+CupsPPD)
    }
    if FileManager.default.fileExists(atPath: CupsPPD){
    do {
    var ppdfile = try String(contentsOf: path, encoding: .utf8)
        ppdfile = ppdfile.replacingOccurrences(of: "\"", with: "", options: [.regularExpression, .caseInsensitive])
    let cupsArrayTemp = ppdfile.components(separatedBy: CharacterSet.newlines)
     cupsArrayTemp.forEach {
              if $0.hasPrefix("*ShortNickName:") {
                 returnValue = ($0.replacingOccurrences(of: "\\*ShortNickName:", with: "", options: [.regularExpression, .caseInsensitive]))
                 returnValue = (returnValue.replacingOccurrences(of: "\t", with: "", options: [.regularExpression, .caseInsensitive]))
                 if returnValue.hasPrefix(" ") {
                 returnValue = String(returnValue.dropFirst())
                 }
             }
     }
    } catch  {
    }
}
    return returnValue
}


// Get all printers to printersArray
func getAllPrinters () {
   var printers = shell("SOFTWARE= LANG=C lpstat -s")
   printers = printers.replacingOccurrences(of: ": ", with: "::", options: [.regularExpression, .caseInsensitive])
   printers = printers.replacingOccurrences(of: "::", with: "|", options: [.regularExpression, .caseInsensitive])
   printers = printers.replacingOccurrences(of: "device for ", with: "", options: [.regularExpression, .caseInsensitive])
   var printersArrayTemp = printers.components(separatedBy: CharacterSet.newlines)
   printersArrayTemp.removeFirst()
   printersArrayTemp = printersArrayTemp.filter({ $0 != ""})

   printersArrayTemp.forEach {
        let printersArrayClean = String(($0.split(separator: "|").first!))
        printersArray += printersArrayClean.components(separatedBy: CharacterSet.newlines)
   }
 

   for everyprinter in printersArray {

   // Make a copy of printersArrayTemp to get printer protocol
    printersProtocolArray = printersArrayTemp
    printersProtocolArray.removeAll { !$0.contains(everyprinter) }

    printersProtocolArray.forEach {
    protocolandIp = String(($0.split(separator: "|").last!))
    printerprotcol = protocolandIp.components(separatedBy: "://")[0]
    ipaddress = protocolandIp.components(separatedBy: "://")[1]
   }

   // Get choosen printers info, where Interface=cupsppd, Description=printername, Location=location
   var printerInfoArrayTemp = [String] ()
   var printerInfo = shell("SOFTWARE= LANG=C lpstat -lp '\(everyprinter)'")
   printerInfo = printerInfo.replacingOccurrences(of: "\t", with: "", options: [.regularExpression, .caseInsensitive])
   printerInfoArrayTemp = printerInfo.components(separatedBy: CharacterSet.newlines)


   printerInfoArrayTemp.forEach {
           if $0.hasPrefix("Interface:") {cupsppd = ($0.replacingOccurrences(of: "Interface: ", with: "", options: [.regularExpression, .caseInsensitive]))}
           if $0.hasPrefix("Description:") {printername = ($0.replacingOccurrences(of: "Description: ", with: "", options: [.regularExpression, .caseInsensitive]))}
           if $0.hasPrefix("Location:") {location = ($0.replacingOccurrences(of: "Location: ", with: "", options: [.regularExpression, .caseInsensitive]))}
   }
    printercard = (CupsPrinterName: everyprinter, CupsPPD: cupsppd, Printername: printername, ShortNickName: getShortNickName(CupsPPD: cupsppd), Location: location, Protocol: printerprotcol, IP: ipaddress)
    everyprintersArray.append(printercard)
    }
   }


func getAllPPDs () {
let documentsPath = "/Library/Printers/PPDs/Contents/Resources"
let url = URL(fileURLWithPath: documentsPath)
let fileManager = FileManager.default
let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: url.path)!
while let subFolders = enumerator.nextObject() as? String {
    if subFolders.hasSuffix(".lproj") {
        // skip only pure folders
    } else {
 allPPDs += "\n/Library/Printers/PPDs/Contents/Resources/"+(subFolders)
    }
}
allPPDsArray = allPPDs.components(separatedBy: CharacterSet.newlines)
allPPDsArray = allPPDsArray.filter({ $0 != ""})
}


func getAllShortNickNameAndPrinterPPDs () {
    var ppdsAndShortnickname = ""
for ppd in allPPDsArray {
    var tempShortNickName = ""
    
   // for ppd in ppdsFiles {
    if ppd.hasSuffix(".gz") {
        // some ppds has Legacy linefeeds that makes zgrep fail need to convert them
           tempShortNickName = shell( "gzip -d <'\(ppd)' | tr '\\r\\n' '\\n'  | zgrep -som1 -E '\\*ShortNickName.+\"'")
    } else {
        // some ppds has Legacy linefeeds that makes zgrep fail need to convert them
   tempShortNickName = shell("tr '\\r\\n' '\\n' <'\(ppd)' | zgrep -som1 -E '\\*ShortNickName.+\"'")
       }
if tempShortNickName.contains("*ShortNickName:") {
    tempShortNickName = tempShortNickName.replacingOccurrences(of: "\\*ShortNickName:", with: "", options: [.regularExpression, .caseInsensitive])
    tempShortNickName = tempShortNickName.replacingOccurrences(of: "\n", with: "", options: [.regularExpression, .caseInsensitive])
    tempShortNickName = tempShortNickName.replacingOccurrences(of: "\t", with: "", options: [.regularExpression, .caseInsensitive])
    tempShortNickName = tempShortNickName.replacingOccurrences(of: "\"", with: "", options: [.regularExpression, .caseInsensitive])
    
    
    if tempShortNickName.hasPrefix(" ") {
    tempShortNickName = String(tempShortNickName.dropFirst())
    }
    
    // Add to variable to use for writing to file later
    ppdsAndShortnickname += "\(tempShortNickName),\(ppd)\n"
   }
    }
            // Write to file
           do {
            let writeString = ppdsAndShortnickname.description
            try FileManager.default.createDirectory(atPath: "/Users/\(NSUserName())/Library/Application Support/PrinterSetup", withIntermediateDirectories: true, attributes: nil)
            try writeString.write(to: ppdListFilePath, atomically: true, encoding: String.Encoding.utf8)
           } catch {
               print(error)
           }
    // Get all ppds from textfile
    getAllPPDfromtxtFile ()
   
}


func getAllPPDfromtxtFile () {
    do {
    let readPPDListFile = try String(contentsOf: ppdListFilePath, encoding: String.Encoding.utf8)
        let cleanPPDListFile = readPPDListFile.replacingOccurrences(of: "\"", with: "", options: .caseInsensitive, range: nil)
        
        let cleanPPDListFileLines = cleanPPDListFile.split(separator:"\n")

        for line in cleanPPDListFileLines {
            var ppdsandshortnicknameFileTemp = [String] ()
            ppdsandshortnicknameFileTemp.removeAll()
            ppdsandshortnicknameFileTemp = line.components(separatedBy: ",")
            let tempTuple = (ShortNickName: ppdsandshortnicknameFileTemp[0], PPD: ppdsandshortnicknameFileTemp[1])
             shortNickNameAndPPDsArray.append(tempTuple)
        }
        } catch  {
            print(error)
        }
}


func sortPPDsArray () {
   var language = Locale.current.collatorIdentifier
    language = String(language!.prefix(2))

    
  let searchLproj = language! + ".lproj"
  var currentIndex = 0
  for ppdPath in sortedPPDsArray {
      if ppdPath.contains(searchLproj) {
              sortedPPDsArray.remove(at: currentIndex)
              sortedPPDsArray.insert(ppdPath, at: 0)
          break
      }
      currentIndex += 1
  }
  }


func countppdListFileLines () -> Int {
    var returnCount = 0
do {
    let ppdListFileLines = try String(contentsOfFile: ppdListFile, encoding: String.Encoding.utf8)
    let ppdListFileLinesCount = ppdListFileLines.components(separatedBy: CharacterSet.newlines)
    // -1 cause it counts last linefeed
    returnCount = ppdListFileLinesCount.count-1
} catch {
        print(error)
    }
      return returnCount
}


func runBackgroundPPDindex () {
     DispatchQueue.global(qos: .userInteractive).async {
        getAllPPDs ()
        
        if allPPDsArray.count == countppdListFileLines() {
            // Read from file directly
            getAllPPDfromtxtFile ()
        } else {
                 getAllShortNickNameAndPrinterPPDs ()
        }
         DispatchQueue.main.async {
             // Back on the main thread
            appDelegate().finalOutputTextField.string = ""
            appDelegate().spinner.stopAnimation(appDelegate())
            appDelegate().spinner.isHidden=true
         }
     }
     }


func selectedPrinterFunction () {
    if appDelegate().printerslistPopup.titleOfSelectedItem != nil {
        selectedPrinter = appDelegate().printerslistPopup.titleOfSelectedItem ?? ""
    } else {
        return }
    
           if selectedPrinter.contains("[Choose a printer]"){
                clearEveryPrinterFields ()
                appDelegate().finalOutputTextField.string = ""
               return
           } else {
                createprinterPPDsPopup ()
                createcupsNameTextfield ()
                createprinterNameTextField ()
                createprinterLocationTextField ()
                createPrinterProtocolPopup ()
                createprinterIpaddressComboBox ()
                selectedShortNickName = everyprintersArray.first{ $0.CupsPrinterName == selectedPrinter }?.ShortNickName ?? ""
                getPrinterNameFromPPDs ()
                generateFinalOutputTextField ()
           }
}


func cleanCupsName(_ inputString:String) -> String {
    var outputString = ""
if let regex = try? NSRegularExpression(pattern: "(\t|\\ |\\#|\\/)", options: .caseInsensitive) {
    outputString = regex.stringByReplacingMatches(in: inputString, options: [], range: NSRange(location: 0, length:  inputString.count), withTemplate: "_")
}
    return outputString
}

func cleanVersion(_ inputString:String) -> String {
    var outputString = ""
if let regex = try? NSRegularExpression(pattern: "[^0-9.]", options: .caseInsensitive) {
    outputString = regex.stringByReplacingMatches(in: inputString, options: [], range: NSRange(location: 0, length:  inputString.count), withTemplate: "")
}
    return outputString
}

func identifierCheck () {
  if appDelegate().identifierTextField.stringValue == "" {
    appDelegate().identifierTextField.stringValue = "se.printersetup"
    }
    }


func cupsCheckBox () {
    // If Checkbox is ON (1) enable cups webinterface
    if statusCupsCheckbox == 1 {
          _ = shell("cupsctl WebInterface=yes")
        appDelegate().cupsURLbutton.isHidden=false
    } else {
        _ = shell("cupsctl WebInterface=no")
        appDelegate().enableCupsWebbutton.state = NSControl.StateValue.off
        statusCupsCheckbox = 0
        appDelegate().cupsURLbutton.isHidden=true
       
    }
    
}

    
// GET ALL PRINTERS PURE SWIFT save here for references
//            func getAllPrinters () {
//            let documentsPath = "/private/etc/cups/ppd/"
//            let url = URL(fileURLWithPath: documentsPath)
//
//            do {
//                let directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
//                let printers = directoryContents.filter{ $0.pathExtension == "ppd" }
//                printersArray = printers.map{ $0.deletingPathExtension().lastPathComponent }
//
//
//            } catch {
//                print(error)
//            }
//            }


//func gettingPrinters () {
//var printerList : Unmanaged<CFArray>?
//let kPMServerLocal = unsafeBitCast(0, to: PMServer.self) // #define kPMServerLocal ((PMServer)NULL)
//PMServerCreatePrinterList(kPMServerLocal, &printerList)
//
//var result : [String : String] = [:]
//
//if let list = printerList {
//    let retainedList = list.takeRetainedValue()
//    let numberOfPrinters = CFArrayGetCount(retainedList)
//    for printerIndex in 0..<numberOfPrinters {
//        let printer = CFArrayGetValueAtIndex(retainedList, printerIndex)
//        let printerID = PMPrinterGetID(OpaquePointer(printer)!)!.takeUnretainedValue() as String
//        let printerName = PMPrinterGetName(OpaquePointer(printer)!)!.takeUnretainedValue() as String
//        result[printerID] = printerName
//        print(PMPrinterIsPostScriptCapable(OpaquePointer(printer!)))
//        // Location
//        print(PMPrinterGetLocation(OpaquePointer(printer!))!.takeUnretainedValue() as String)
//        //print(PMPrinterCopyDeviceURI(OpaquePointer(printer!), UnsafeMutablePointer<Unmanaged<CFURL>?>(OpaquePointer?)))
//
//    }
//    print("Result1 = " + result.description) // Successful
//
//
//}
//
//print("Result2 = " + result.description) // EXC_BAD_ACCESS
//}
