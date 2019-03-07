--
--  AppDelegate.applescript
--  PrinterSetup
--
--  Created by Mikael Löfgren on 2018-12-25.
--  Copyright © 2018 Mikael Löfgren. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
	
	-- IBOutlets
	property theWindow : missing value
	property myPrinterPopUp : missing value
    property myPPDPopUp : missing value
    property myPrinterCupsName : missing value
    property myPrinterName : missing value
    property myLocation : missing value
    property myProtocolnamePopUp : missing value
    property myIpPopUp : missing value
    property myfinalOutput : missing value
    property myExportPopUp : missing value
    # Preferences propertys
    property myPreferencesWindow : missing value
    property myPkgid : missing value
    property myPkgvers : missing value
    property myCreateSignedPkgCheckbox : missing value
    property mySignCertificatePopUp : missing value
    property myCupsWebinterfaceCheckbox : missing value
   
    
# Rerun when a printer is selected
   on didSelectItem:sender
   set choosenPrinter to (myPrinterPopUp's titleOfSelectedItem()) as string
      if choosenPrinter is "[Choose a printer]" then
          clearAllFunc()
       return
       end if
      log sender's titleOfSelectedItem() as text
       ppdFileFunc()
       printerCupsNameFunc()
       printerNameFunc()
       LocationFunc()
       printerProtocolFunc()
       printerIpFunc()
       cupsNameValidatorFunc()
       printerOptionsFunc()
       # Clear final output field
       myfinalOutput's setString_("") as text
       finalOutputFunc()
   end didSelectItem
   
   # When value changes autoupdate Output
   on textValueChanges:sender
        printerOptionsFunc()
       cupsNameValidatorFunc()
       finalOutputFunc()
       end textValueChanges_
   
    
    on exportAsNopayload:sender
        set theText to (myfinalOutput's |string|()) as text
        if theText is "" then
            display dialog "Get Settings before use the export functions" buttons ["OK"] with icon caution
            # Set default value in menu after dialog
            myExportPopUp's setTitle_("Export as...")
            return
        end if
        noPayloadpkgFunc()
        # Set default value in menu after export
        myExportPopUp's setTitle_("Export as...")
 end exportAsNopayload
    
    on exportAsMunkipkginfo:sender
        set theText to (myfinalOutput's |string|()) as text
        if theText is "" then
            display dialog "Get Settings before use the export functions" buttons ["OK"] with icon caution
            # Set default value in menu after dialog
            myExportPopUp's setTitle_("Export as...")
            return
        end if
        munkiPkginfoFunc()
        # Set default value in menu after export
        myExportPopUp's setTitle_("Export as...")
    end exportAsMunkipkginfo
    
    
    on myCheckboxSignedOrNot:sender
         log myCreateSignedPkgCheckbox's state()
        if myCreateSignedPkgCheckbox's state() is 1 then
            #log "Buttom is checked lets get signing certificates"
             createSignPkg()
             else
             # Clear certificate Popup
             mySignCertificatePopUp's removeAllItems()
              mySignCertificatePopUp's setStringValue_("")
             end if
        # To set a default value
        # myCreateSignedPkgCheckbox's setIntValue_([1])
        # log myCreateSignedPkgCheckbox's intValue()
    end myCheckboxSignedOrNot_
    
    
    on myCupsWebinterfaceCheckboxOnorOff:sender
    if myCupsWebinterfaceCheckbox's state() is 1 then
        do shell script ("cupsctl WebInterface=yes") with administrator privileges
        else
        do shell script ("cupsctl WebInterface=no") with administrator privileges
        myCupsWebinterfaceCheckbox's setIntValue_([0])
    end if
    end myCupsWebinterfaceCheckboxOnorOff_
    
    
    on cancel_(sender)
        quit
    end cancel_
    
    
    
############################################################################
# Function to get PPD file
    to ppdFileFunc()
 # Get choosen printer
    set choosenPrinter to (myPrinterPopUp's titleOfSelectedItem()) as string
    
    # Get the Choosen Printers Cups Path
    set cupsPPDpath to do shell script ("SOFTWARE= LANG=C lpstat -l -p " & choosenPrinter & " | grep Interface: | awk '{print $2}'")
    
    # Check for valid path to PPD (lpinfo -m doesnt show Languages folders)
    if cupsPPDpath doesn't contain "/private/etc/cups/ppd/" then
    set shortNickname to do shell script ("grep \"ShortNickName:\" /etc/cups/ppd/" & choosenPrinter & ".ppd | head -n 1 | cut -d \":\" -f 2 | xargs")
  else
 set shortNickname to do shell script ("grep \"ShortNickName:\" <"& cupsPPDpath &" | head -n 1 | cut -d \":\" -f 2 | xargs")
end if

# Get the choosen printer ShortnickName and use that to find the PPD file(s)
    set compressedPPD to do shell script ("find /Library/Printers/PPDs/Contents/Resources -iname '*.gz' -exec zgrep -e \"" & shortNickname & "\" {} + | cut -d \":\" -f 1 | sort -u")
    set uncompressedPPD to do shell script ("grep -a -r \"" & shortNickname & "\" /Library/Printers/PPDs/Contents/Resources | cut -d \":\" -f 1 | sort -u ")
    
    if shortNickname is equal to "Generic PostScript Printer" then
        set uncompressedPPD to "/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/PrintCore.framework/Versions/A/Resources/Generic.ppd"
         log "Generic Postscript Printer is selected" as text
         else
         if shortNickname is equal to "Generic PCL Laser Printer" then
             log "Generic PCL Laser Printer is selected" as text
             set uncompressedPPD to "sample.drv/generpcl.ppd"
             end if
end if
    
   
    # Put uncompressed PPD and compressed results together and show as list
    set allPPDs to every paragraph of uncompressedPPD
    
    # Remove Duplicates Uncompressed PPDs
    set myPPDs to {}
    
    repeat with i from 1 to count of items of allPPDs
        if item i of allPPDs is not in myPPDs then
            set myPPDs to myPPDs & item i of allPPDs
        end if
    end repeat
    
   set allPPDs to every paragraph of compressedPPD
   
    # Remove Duplicates compressed PPDs
    repeat with i from 1 to count of items of allPPDs
        if item i of allPPDs is not in myPPDs then
            set myPPDs to myPPDs & item i of allPPDs
        end if
    end repeat
    
   
    
    # Set PPD popup items
    myPPDPopUp's removeAllItems()
    myPPDPopUp's addItemsWithTitles_(myPPDs)

end ppdFileFunc
# End Function to get PPD file
############################################################################


############################################################################
# Function to clear all if no printer is selected
to clearAllFunc()
 myPPDPopUp's removeAllItems()
 myPrinterCupsName's setStringValue_("")
 myPrinterName's setStringValue_("")
 myLocation's setStringValue_("")
 myProtocolnamePopUp's removeAllItems()
 # Clear ip Popup
 myIpPopUp's removeAllItems()
 myIpPopUp's setStringValue_("")
 myfinalOutput's setString_("")
end clearAllFunc_
# End Function o clear all if no printer is selected
############################################################################


############################################################################
# Function to get PrinterCupsname
to printerCupsNameFunc()

# Set choosen printer as default value in printername dialog
set choosenPrinter to (myPrinterPopUp's titleOfSelectedItem()) as string

# Print choosenprinter in the textfield
myPrinterCupsName's setStringValue_(choosenPrinter)

end printerCupsNameFunc
# End Function to get Printername
############################################################################




############################################################################
# Function to get Printername
to printerNameFunc()

# Get choosen printer
set choosenPrinter to (myPrinterPopUp's titleOfSelectedItem()) as string

# Get choosen printers description name
set printerDescription to do shell script ("SOFTWARE= LANG=C lpstat -l -p " & choosenPrinter & "  | grep Description | /usr/bin/awk -v FS=':' '{print $2}' | sed -e 's/[[:space:]]//'")

# Print printer description name in the textfield
myPrinterName's setStringValue_(printerDescription)

end printerNameFunc
# End Function to get Printername
############################################################################




############################################################################
# Function to get Location
to LocationFunc()

# Get choosen printer
set choosenPrinter to (myPrinterPopUp's titleOfSelectedItem()) as string

# Get choosen printers location
set printerLocation to do shell script ("SOFTWARE= LANG=C lpstat -l -p " & choosenPrinter & "  | grep Location | /usr/bin/awk -v FS=':' '{print $2}' | sed -e 's/[[:space:]]//'")

# Print choosen printers location in the textfield
myLocation's setStringValue_(printerLocation)

end LocationFunc
## End Function to get PrinterProtocol
#############################################################################




############################################################################
# Function to get PrinterProtocol
to printerProtocolFunc()

# Get choosen printer
set choosenPrinter to (myPrinterPopUp's titleOfSelectedItem()) as string

# Get printerprotocol
set printerProtocol to do shell script ("SOFTWARE= LANG=C lpstat -s | /usr/bin/awk -v FS='(device for | ._printer._tcp.local.)' '{print $2}' | grep " & choosenPrinter & " | /usr/bin/awk -v FS=':' '{print $2}' | sed -e 's/[[:space:]]//' | sort -u")

set currentProtocol to every paragraph of printerProtocol

# Set Service popup items (found defaults with lpinfo -v)
myProtocolnamePopUp's removeAllItems()
set protocollist to {"lpd", "smb", "ipp","ipps","http","https"}
myProtocolnamePopUp's addItemsWithTitles_(protocollist) -- add items from a list
myProtocolnamePopUp's addItemsWithTitles_(currentProtocol) -- add value(s) in the popupmenu field
myProtocolnamePopUp's setTitle_(printerProtocol) -- set default value in the popupmenu field

end printerProtocolFunc
## End Function to get PrinterProtocol
#############################################################################




############################################################################
## Function to get IP
to printerIpFunc()

# Get choosen printer
set choosenPrinter to (myPrinterPopUp's titleOfSelectedItem()) as string

# Get choosen printer protocol
set protocolName to (myProtocolnamePopUp's titleOfSelectedItem()) as text

# Clear ip popup
myIpPopUp's removeAllItems()
log protocolName as text

# If bonjour printer (dnssd) then search for IP aswell ipps and ipp to get IP number
if protocolName contains "dnssd" then
    set printerServicename to do shell script ("SOFTWARE= LANG=C lpstat -s | /usr/bin/awk -v FS='(device for | ._printer._tcp.local.)' '{print $2}' | grep " & choosenPrinter & "  | /usr/bin/awk -v FS='//' '{print $2}' | sed -e 's/%20/ /g' -e 's/%40/\\@/g' -e 's/%5B/\\[/g' -e 's/%5D/\\]/g' | /usr/bin/awk -v FS='.' '{print $1}' | sort -u")
    log printerServicename
    
    set IPPS to do shell script ("ippfind _ipps._tcp --name " & quoted form of printerServicename & " --exec ping -qc 1 {service_hostname} \\; | awk -F '[()]' '{print $2}' | sed -e '/^[[:space:]]*$/d'")
     set IPP to do shell script ("ippfind _ipp._tcp --name " & quoted form of printerServicename & " --exec ping -qc 1 {service_hostname} \\; | awk -F '[()]' '{print $2}' | sed -e '/^[[:space:]]*$/d'")
     # Put Ippfinds results of IPPS and IPPS results together and show as list myIPPs
     set allIPPs to every paragraph of IPP
     
     # Remove Duplicates IPP
     set myIPPs to {}
     
     repeat with i from 1 to count of items of allIPPs
         if item i of allIPPs is not in myIPPs then
             set myIPPs to myIPPs & item i of allIPPs
         end if
     end repeat
     
     set allIPPs to every paragraph of IPPS
     
     # Remove Duplicates IPPS
     repeat with i from 1 to count of items of allIPPs
         if item i of allIPPs is not in myIPPs then
             set myIPPs to myIPPs & item i of allIPPs
         end if
     end repeat
    
    # Get the bonjourname
 set bonjourname to do shell script ("SOFTWARE= LANG=C lpstat -s | /usr/bin/awk -v FS='(device for | ._printer._tcp.local.)' '{print $2}' | grep " & choosenPrinter & "  | /usr/bin/awk -v FS='//' '{print $2}' | sort -u")
 
    set currentBonjourname to every paragraph of bonjourname
    myIpPopUp's addItemsWithObjectValues_(myIPPs) -- add value(s) in the Combobox popupmenu field
    myIpPopUp's addItemsWithObjectValues_(currentBonjourname) -- add value(s) in the Combobox popupmenu field
    # Get the first item and set as default in combobox
    set firstcurrentBonjourname to item 1 of currentBonjourname
    myIpPopUp's setStringValue_(firstcurrentBonjourname) -- set default value in the Combobox popupmenu field
    else
    # For other printers get IP
   set printerip to do shell script ("SOFTWARE= LANG=C lpstat -s | /usr/bin/awk -v FS='(device for | ._printer._tcp.local.)' '{print $2}' | grep " & choosenPrinter & "  | /usr/bin/awk -v FS='//' '{print $2}' | sort -u")
   set currentIP to every paragraph of printerip
   log currentIP
   # Get the first item and set as default in combobox
   set firstCurrentip to item 1 of currentIP
   log firstCurrentip
   myIpPopUp's addItemsWithObjectValues_(currentIP) -- add value(s) in the Combobox popupmenu field
   myIpPopUp's setStringValue_(firstCurrentip) -- set default value in the Combobox popupmenu field


end if



end printerIpFunc
## End Function to get IP
############################################################################




############################################################################
# Function for CupsnameValidator
to cupsNameValidatorFunc()

# Get choosen printer
set printerCupsName to (myPrinterCupsName's stringValue()) as text
global illegalCharacter
# Check for no spaces, tabs, # or / in Cups printerqueue name
if printerCupsName contains "/" then
    set illegalCharacter to "/"
    cupsnameAlert()
    else
    if printerCupsName contains "#" then
        set illegalCharacter to "#"
        cupsnameAlert()
        else
        if printerCupsName contains " " then
            set illegalCharacter to "spaces"
            cupsnameAlert()
            else
            if printerCupsName contains "\t" then
                set illegalCharacter to "tab"
                cupsnameAlert()
            else
            if printerCupsName is equal to "" then
display dialog "Cups print queue name is empty\
Please enter a cups print queue name" buttons ["OK"] with icon caution
           end if
        end if
    end if
end if
    end if
end cupsNameValidator
# End Function for CupsnameValidator
############################################################################




############################################################################
# Function for Cupsname Alert
to cupsnameAlert()
# Get choosen printer name
set printerCupsName to (myPrinterCupsName's stringValue()) as text

# Get variable and show warning dialog
global illegalCharacter
set Alert to display dialog "Printer queue name contains " & illegalCharacter & " character(s)\
and will be replaced with underscore" buttons ["OK"] with icon caution

# Replace #, / and space, tabs with underscore bash style
# set adjustedCupsName to do shell script ("printf "& quoted form of printerCupsName &"  | tr '\t#/[[:space:]]' '_'")

# Replace #, / and space, tabs with underscore
set adjustedCupsName to current application's NSString's stringWithString:printerCupsName
set adjustedCupsName to (adjustedCupsName's stringByReplacingOccurrencesOfString:"#|/| |\\t" withString:"_" options:(current application's NSRegularExpressionSearch) range:{0, adjustedCupsName's |length|()}) as text


# Set adjusted Cups printer name
myPrinterCupsName's setStringValue:(adjustedCupsName)

end cupsnameAlert
# End Cupsname Alert
############################################################################




############################################################################
# Function to get Printeroptions
to printerOptionsFunc()

# Get choosen printer
set choosenPrinter to (myPrinterPopUp's titleOfSelectedItem()) as text

# Get choosen ppd
set printerPPD to (myPPDPopUp's titleOfSelectedItem()) as text


# if PPD is generic PCL dont use Printer Descriptions use -m drv:///sample.drv/generpcl.ppd instead of -P for PPD
if printerPPD contains "sample.drv" then

# If PPD is generic PCL get PPD from Cups directly to tmp folder as uncompressedPPD
do shell script ("/usr/libexec/cups/daemon/cups-driverd cat drv:///sample.drv/generpcl.ppd >> /tmp/PrinterSetup/uncompressedPPD")
do shell script ("tr '\\r' '\\n' </etc/cups/ppd/" & choosenPrinter & ".ppd  >/tmp/PrinterSetup/" & choosenPrinter & ".ppd")
else

# Get the options by comparing cups ppd and the selected one
# Copy the Cups PPD and convert from Mac linebreaks CR to Unix linebreaks LF (diff fails unless this is done)
do shell script ("tr '\\r' '\\n' </etc/cups/ppd/" & choosenPrinter & ".ppd  >/tmp/PrinterSetup/" & choosenPrinter & ".ppd")

# If ppd is compressed then make a temp file of the original to compare and convert line endings
do shell script ("if [[ \"" & printerPPD & "\" == *.gz ]]; then
# gunzip to temp file
gunzip < \"" & printerPPD & "\" > /tmp/PrinterSetup/uncompressedPPD
# Change line endings from CR to LF (diff fails unless this is done)
sed -e $'s/\\\r/\\\n/g' -i '' /tmp/PrinterSetup/uncompressedPPD
else
# or just make a copy if not compressed
cp \"" & printerPPD & "\" /tmp/PrinterSetup/uncompressedPPD
# Change line endings from CR to LF (diff fails unless this is done)
sed -e $'s/\\\r/\\\n/g' -i '' /tmp/PrinterSetup/uncompressedPPD
fi")
end if

# Set Global variables
global printerOptions
global printerIsshared


# Compare Cups PPD and selected to get LP options
set lpOptions to do shell script ("diff /tmp/PrinterSetup/uncompressedPPD /tmp/PrinterSetup/" & choosenPrinter & ".ppd | grep \"> [*]Default\" | sed 's/> [*]Default/-o /g' | sed 's/: /=/g'")

# Put all options together and add printer is shared value
if lpOptions is not "" then
    set printerOptionsNewline to every paragraph of lpOptions #& " \\\n"
    #set printerOptionsNewline to lpOptions
    set Applescript's text item delimiters to " \\\n" -- that's "comma space"
    set printerOptions to printerOptionsNewline as text
    set printerIsshared to "-o printer-is-shared=False \\\n"
else
set printerOptions to ""
set printerIsshared to "-o printer-is-shared=False"
end if




end printerOptionsFunc
# End Function to get Printeroptions
############################################################################




############################################################################
# Function for final output
to finalOutputFunc()
# Get choosen ppd
set printerPPD to (myPPDPopUp's titleOfSelectedItem()) as text


# Get Global variables
global printerOptions
global printerIsshared

# Test that we dont have a ip adress and dnssd
set protocolTest to (myProtocolnamePopUp's titleOfSelectedItem()) as text
if protocolTest contains "dnssd" then
    set IP_or_Not to (myIpPopUp's StringValue()) as text
    set testIP to do shell script ("if [[ "& quoted form of IP_or_Not &"  =~ ^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$ ]]; then
    echo \"IPaddress\"
    fi")
    if testIP is "IPaddress" then
        display dialog "Cant use dnssd and ipaddress, use lpd." buttons ["OK"] with icon caution
myProtocolnamePopUp's setTitle_("lpd") -- set default value in the popupmenu field
    end if
end if



# Get all the values and adding Lpadmins options as finaloutput
set sheBang to "#!/bin/bash" as text
set printerCupsName to "-p \"" & (myPrinterCupsName's stringValue()) & "\" \\\n" as text
set printerEnabled to "-E \\\n" as text
set printerRealName to "-D \"" & (myPrinterName's stringValue()) & "\" \\\n" as text
set protocolName to "-v " & (myProtocolnamePopUp's titleOfSelectedItem()) & "://" as text
set printerIP to (myIpPopUp's StringValue()) as text & " \\\n" as text

# if PPD is generic PCL dont use Printer Descriptions use -m drv:///sample.drv/generpcl.ppd instead of -P for PPD
if printerPPD contains "sample.drv" then
    set printerPPD to "-m \"drv:///" & (myPPDPopUp's titleOfSelectedItem()) & "\" \\\n" as text
    else
    set printerPPD to "-P \"" & (myPPDPopUp's titleOfSelectedItem()) & "\" \\\n" as text
end if


set printerLocation to (myLocation's stringValue()) as text
if printerLocation is not "" then
    set finalLocation to "-L \"" & (myLocation's stringValue()) & "\" \\\n" as text
    else
    set finalLocation to ""
end if


# Lpadmin-options: -p=Printername, -v=PrinterIP, -P=PPDpath, -E=Enabled, -o=PrinterOptions\\n
set finaOutputtext to (""& sheBang &"\n/usr/sbin/lpadmin "& printerCupsName &""& printerEnabled &""& printerRealName &""& printerPPD &""& protocolName &""& printerIP &""& finalLocation &""& printerIsshared &""& printerOptions &"")

# Show LP options
myfinalOutput's setString_(finaOutputtext) as text




end finalOutputFunc_
# End Function for final output
############################################################################





############################################################################
# Function to save get developer certificates
on createSignPkg()
    
# Get certificates from Keychain
set certificates to do shell script ("security find-identity -v -p codesigning |  awk -v FS='(:|\")' '{print $3}' | sed '/^[[:space:]]*$/d' | sort -u")
if certificates is equal to "" then
    #if contents of certificatesAll is equal to {} then
        display dialog "Couldnt find any certificates for signing,\
you need a Apple developer account." buttons ["OK"] with icon caution
# And Uncheck Checkbox
myCreateSignedPkgCheckbox's setIntValue_([0])
        else
        set certificatesAll to every paragraph of certificates
        # Get the first item and set as default in combobox
        set firstCertificate to item 1 of certificatesAll
   mySignCertificatePopUp's addItemsWithObjectValues_(certificatesAll) -- add value(s) in the Combobox popupmenu field
   mySignCertificatePopUp's setStringValue_(firstCertificate)
    end if
end createSignPkg
# End Function to save get developer certificates
############################################################################




############################################################################
# Function to get save as no payload pkg
to noPayloadpkgFunc()
try
# Get Choosen printer
#set choosenPrinter to (myPrinterPopUp's titleOfSelectedItem()) as text
set choosenPrinter to (myPrinterCupsName's stringValue()) as text

# Get the final NSScrollView text
set theText to (myfinalOutput's |string|()) as text

# Create tempfiles for pkgbuild
do shell script ("mkdir -p /tmp/PrinterSetup/"& choosenPrinter &"")
do shell script ("mkdir -p /tmp/PrinterSetup/"& choosenPrinter &"/nopayload")
do shell script ("mkdir -p /tmp/PrinterSetup/"& choosenPrinter &"/scripts")


set postinstallFile to "/tmp/PrinterSetup/"& choosenPrinter &"/scripts/postinstall"
set postinstallFile to postinstallFile as string


# Write to theText to the postinstall file
set theOpenedFile to open for access postinstallFile with write permission
set eof of theOpenedFile to 0
write theText to theOpenedFile starting at eof as «class utf8»
close access theOpenedFile

# Make postinstall executable
do shell script "chmod a+x /tmp/PrinterSetup/"& choosenPrinter &"/scripts/postinstall"

# Prompt for a output file for pkgbuild
set resultFile to (choose file name with prompt "Save As File" default name ""& choosenPrinter &".pkg" default location path to desktop) as text
if resultFile does not end with ".pkg" then set resultFile to resultFile & ".pkg"

set resultFile to POSIX path of resultFile


set pkgname to choosenPrinter as text
set pkgvers to (myPkgvers's stringValue()) as text
log pkgvers
set pkgid to (myPkgid's stringValue()) as text
log pkgid
set pkgidAndName to ""& pkgid &"."& pkgname &""
log pkgidAndName


set buildPkg to do shell script "pkgbuild --identifier " & quoted form of pkgidAndName & " --version " & quoted form of pkgvers & " --root /tmp/PrinterSetup/" & quoted form of pkgname & "/nopayload --scripts /tmp/PrinterSetup/" & quoted form of pkgname & "/scripts  " & quoted form of resultFile & " " with administrator privileges
display notification "Succesfully exported pkg to: "& resultFile &""


if myCreateSignedPkgCheckbox's state() is 1 then
    log "Buttom is checked lets build signed pkg"
    set developerID to (mySignCertificatePopUp's StringValue()) as text
    log developerID
    # Extract the target file's parent directory:
    set newDirPath to (current application's NSString's stringWithString:resultFile)
    set newDirPath to (newDirPath's stringByDeletingLastPathComponent()) as text
    # Set a output name for the signed pkg
    set signedPkg to ""& newDirPath &"/"& pkgname &"" & "_signed.pkg" as text
    log signedPkg
do shell script "productsign --sign 'Developer ID Installer:"& developerID &"' "& resultFile &" "& signedPkg &""
 display notification "Succesfully exported signed pkg to: "& signedPkg &""
 return true
    end if

return true

on error
-- Close the file
try
close access file theOpenedFile
display dialog "Failed to build "& pkgname &".pkg\
Quit app and try again" buttons ["OK"] with icon caution
end try
-- Return a boolean indicating that writing failed
return false
  end try



end noPayloadpkgFunc
# End function to get save as no payload pkg
############################################################################




############################################################################
# Function to save as Munki Pkg info
to munkiPkginfoFunc()
try
    
    # Set choosenPrinter to (myPrinterPopUp's titleOfSelectedItem()) as text
    set choosenPrinter to (myPrinterCupsName's stringValue()) as text
    # Get the final NSScrollView text
    set the postInstallscript to (myfinalOutput's |string|()) as text
    
    set theText to "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
    <plist version=\"1.0\">
    <dict>
    <key>autoremove</key>
    <false/>
    <key>catalogs</key>
    <array>
    <string>testing</string>
    </array>
    <key>description</key>
    <string></string>
    <key>display_name</key>
    <string>"& choosenPrinter &"</string>
    <key>icon_name</key>
    <string></string>
    <key>installcheck_script</key>
    <string>#!/bin/bash
    PRINTER_INSTALLED=$(/usr/bin/lpstat -p | /usr/bin/awk '{print $2}' | /usr/bin/grep \""& choosenPrinter &"\" | /usr/bin/head -1 )
if [ \"$PRINTER_INSTALLED\" = \""& choosenPrinter &"\" ]; then
        echo \"Printer "& choosenPrinter &" already installed\"
        exit 1
        fi
        exit</string>
    <key>installer_type</key>
    <string>nopkg</string>
    <key>minimum_os_version</key>
    <string>10.7.0</string>
    <key>name</key>
    <string>"& choosenPrinter &"</string>
    <key>postinstall_script</key>
    <string>"& postInstallscript &"
exit 0</string>
    <key>requires</key>
    <array>
    <string></string>
    </array>
    <key>unattended_install</key>
    <true/>
    <key>uninstall_method</key>
    <string>uninstall_script</string>
    <key>uninstall_script</key>
    <string>#!/bin/bash
/usr/sbin/lpadmin -x \""& choosenPrinter &"\"
exit 0</string>
    <key>uninstallable</key>
    <true/>
    <key>version</key>
    <string>1.0</string>
    </dict>
    </plist>" as text
    
    log theText

    # Prompt for output file the file as munki pkg info
    set resultFile to (choose file name with prompt "Save As File" default name ""& choosenPrinter &".plist" default location path to desktop) as text
    if resultFile does not end with ".plist" then set resultFile to resultFile & ".plist"
    
    # Need a Posix path for plist check
    set finalCheckPath to POSIX path of resultFile
    log finalCheckPath
    # Need file as string for write command
    set resultFile to resultFile as string
    log resultFile
    
    
    # Write to theText to the munki pkg info file
    set theOpenedFile to open for access resultFile with write permission
    set eof of theOpenedFile to 0
    write theText to theOpenedFile starting at eof as «class utf8»
    close access theOpenedFile
    set finalCheck to do shell script "/usr/bin/plutil -lint "& finalCheckPath &" | awk '{print $2}'"
    if finalCheck is "OK" then
        log ""& finalCheckPath &" is OK"
        display notification "Succesfully exported munki pkg info to: "& finalCheckPath &""
    return true
    else
    display dialog "Something went wrong when writing to file "& finalCheckPath &"\
Check file and try again" buttons ["OK"] with icon caution
return false
    end if
    return true
    
on error
    -- Close the file
    try
        close access file theOpenedFile
    end try
    -- Return a boolean indicating that writing failed
    return false
end try



end munkiPkginfoFunc
# End function to save as Munki Pkg info
############################################################################


on applicationWillFinishLaunching_(aNotification)
    # Clear all popupmenus
    myPrinterPopUp's removeAllItems()
   clearAllFunc()
   # Set default values in preferences window
   myPkgvers's setStringValue_("1.0")
    myPkgid's setStringValue_("com.printersetup")
    
    mySignCertificatePopUp's removeAllItems()
    set cupsWeb to do shell script ("cupsctl | grep 'WebInterface' | /usr/bin/awk -v FS='=' '{print $2}'")
    if cupsWeb is equal to "Yes" then
        myCupsWebinterfaceCheckbox's setIntValue_([1])
        else
        myCupsWebinterfaceCheckbox's setIntValue_([0])
    end if
    
    
    # Create a folder for tempfiles
    do shell script ("mkdir -p /tmp/PrinterSetup")
    
    # Get all cupsprinters names
    set cupsNames to do shell script "SOFTWARE= LANG=C lpstat -s | /usr/bin/awk -v FS='(device for | ._printer._tcp.local.)' '{print $2}' | /usr/bin/awk -v FS=':' '{print $1}'| sed -e '1d' | sed '/^[[:space:]]*$/d'"
    #log cupsNames
  if cupsNames is equal to "" then
        display dialog "Please add some printers to the system" buttons ["OK"] with icon caution
       myPrinterPopUp's insertItemWithTitle_atIndex_("[Choose a printer]",0) -- set default value on top in the popupmenu field
        return false
        else
        # Set PrinterPopUp items
        # set theList to {"next item", "another item", "Items added"}
        set myprinters to every paragraph of cupsNames
        #log myprinters
        myPrinterPopUp's insertItemWithTitle_atIndex_("[Choose a printer]",0) -- set default value on top in the popupmenu field
        myPrinterPopUp's addItemsWithTitles_(myprinters)
     end if
  

    

end applicationWillFinishLaunching_
    
on applicationShouldTerminate_(sender)
        -- Delete the temp folder
         do shell script "rm -R /tmp/PrinterSetup"
		return current application's NSTerminateNow
	end applicationShouldTerminate_
	
end script
