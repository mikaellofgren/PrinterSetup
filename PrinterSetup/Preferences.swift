//
//  Preferences.swift
//  PrinterSetup
//
//  Created by Mikael Löfgren on 2024-12-18.
//  Copyright © 2024 Mikael Löfgren. All rights reserved.
//

import Foundation
import AppKit


public func createPlist() {
    
    
    
// Use with optionals ? so the Codable is more loose
struct Preferences: Codable {

    var versionnumber: String?
    var pkgidentifier: String?
    var devcertificate: String?
    //var choosencommandcolor: Any?
    //var choosenvariablecolor: NSColor?

    }
    
    

// Get values from Preferences Window
    // remove all except 0-9 and . for Version Number
    versionNumberRead = cleanVersion(appDelegate().versionTextField.stringValue)
    appDelegate().versionTextField.stringValue = versionNumberRead
    
    pkgIdentifierRead = appDelegate().identifierTextField.stringValue
    devCertificateRead = appDelegate().certificatePopUp.stringValue


let preferences = Preferences(versionnumber: versionNumberRead, pkgidentifier: pkgIdentifierRead, devcertificate: devCertificateRead)

let encoder = PropertyListEncoder()
  encoder.outputFormat = .xml

do {
    let data = try encoder.encode(preferences)
    try data.write(to: plistPath)
} catch {
    print(error)
}
}







public func readPlist() {
struct PreferencesRead: Decodable {
    private enum CodingKeys: String, CodingKey {
        case versionnumber, pkgidentifier, devcertificate, choosencommandcolor, choosenvariablecolor
    }
    var versionnumber: String? = nil
    var pkgidentifier: String? = nil
    var devcertificate: String? = nil
    var choosencommandcolor: String? = nil
    var choosenvariablecolor: String? = nil
}



if FileManager.default.fileExists(atPath: plistFile){
    
    func parsePlist() -> PreferencesRead {
        let data = try! Data(contentsOf: plistPath)
        let decoder = PropertyListDecoder()
        return try! decoder.decode(PreferencesRead.self, from: data)
    }

    let readPlistValues = parsePlist()
    
    if readPlistValues.versionnumber != nil {
           versionNumberRead = readPlistValues.versionnumber!
          }
    
    if readPlistValues.pkgidentifier != nil {
        pkgIdentifierRead = readPlistValues.pkgidentifier!
    }
    
    if readPlistValues.devcertificate != nil {
          devCertificateRead = readPlistValues.devcertificate!
       }
   
    
    
} else {
print("\(plistFile) not found.")
}

    if versionNumberRead != "" {
        appDelegate().versionTextField.stringValue = versionNumberRead
       }
    
    if pkgIdentifierRead != "" {
       appDelegate().identifierTextField.stringValue = pkgIdentifierRead
    }
    
    if devCertificateRead != "" {
        appDelegate().certificatePopUp.removeAllItems()
        appDelegate().signPKGButton.state = NSControl.StateValue.on
        statusCertificateCheckbox = 1
        appDelegate().certificatePopUp.addItem(withObjectValue: devCertificateRead)
        appDelegate().certificatePopUp.selectItem(withObjectValue: devCertificateRead)
        
    }

   


}

