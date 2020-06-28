import Foundation
import AppKit

public func getAllKeyChainIdentityItems() -> [String] {
    
    let query: [String: Any] = [
        kSecClass as String : kSecClassIdentity,
        kSecReturnData as String  : kCFBooleanTrue!,
        kSecReturnAttributes as String : kCFBooleanTrue!,
        kSecReturnRef as String : kCFBooleanTrue!,
        kSecMatchLimit as String: kSecMatchLimitAll
    ]
    
    var result: AnyObject?
    
    let lastResultCode = withUnsafeMutablePointer(to: &result) {
        SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }
    
    var values = [String]()
    
    if lastResultCode == noErr {
        let array = result as? Array<Dictionary<String, Any>>
        
        for item in array! {
            let label = item[kSecAttrLabel as String] as? String
            if label!.contains("Developer") {
                values.append(label!)
                
            }
            
        }
    }
    
    return values
}


 func createCertificatePopup () {
                
                let myIdentities = getAllKeyChainIdentityItems()
                var developerIdentitiesTemp = Set<String>()
                var developerIdentities:Array = [String]()
    
                for items in myIdentities {
                    let lastItems = items.components(separatedBy: ":").last!
                    let lastItemsClean = String(lastItems.dropFirst())
                    developerIdentitiesTemp.insert(lastItemsClean)
                    developerIdentities = Array(developerIdentitiesTemp)
                }
    
            if developerIdentities.isEmpty == false {
                    appDelegate().certificatePopUp.isEnabled = true
                    appDelegate().certificatePopUp.removeAllItems()
                // Add an item to the list
                    appDelegate().certificatePopUp.addItems(withObjectValues: developerIdentities)
                    appDelegate().certificatePopUp.selectItem(at: 0)
                 } else {
                    // If no certificate is found Checkbox to Off and variable to 0
                    appDelegate().certificatePopUp.addItems(withObjectValues: ["No Developer Certificates found"])
                    // Set the state to Off
                    appDelegate().signPKGButton.state = NSControl.StateValue.off
                     statusCertificateCheckbox = 0
    }
}

func certificateCheckBox () {
    // If Checkbox is ON (1) try get Certificates
       if statusCertificateCheckbox == 1 {
             createCertificatePopup ()
       } else {
           appDelegate().signPKGButton.state = NSControl.StateValue.off
           statusCertificateCheckbox = 0
           appDelegate().certificatePopUp.removeAllItems()
           
           appDelegate().certificatePopUp.addItem(withObjectValue: "")
            appDelegate().certificatePopUp.selectItem(at: 0)
       }
}
