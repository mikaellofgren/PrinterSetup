<img src="https://github.com/mikaellofgren/PrinterSetup/blob/master/images/printersetupicon.png" width="50%"></img><br>
# PrinterSetup<br>

A simple printer utility that generates lpadmin output to add printers.<br>
It also generates lpadmin options from the PPD file.<br>
From options lookup the ip number of a bonjour (dnssd) printer (you need to be on the same network as the printer)<br>
Export output as no payload pkg and munki pkg info.<br>
From the preferences settings you can choose to generate a signed pkg and enable Cups Webinterface.<br>
<br>

You can also use it to export any bashscript by simply paste your bashscript to the Final settings field<br>
and give the output a name in the Cups print queue name field and then choose the export options.<br>

<img src="https://github.com/mikaellofgren/PrinterSetup/blob/master/images/printersetupinterface.png" width="50%"></img><br>


Download latest version here: https://github.com/mikaellofgren/PrinterSetup/releases

System requirements: 10.13 or later<br>
Icon: vecteezy.com<br>



## Export for manual distribution
If you want to export for manual distribution, make sure you got the printerdriver installer<br>
then add this command before the lpadmin command, and change: CHANGE_ME_TO_PRINTERDRIVER_NAME<br>
in the command to match the name of the printerdriver installer then Export as no payload pkg.<br>
<br>
Put the no payload pkg and printerdriver installer into a folder and run only the<br>
no payload pkg, if everythings works it should first install the printerdriver and then add the printer.<br>
<br>

If you want to hide the printerdriver installer add a period before the filename<br>
dont forget to change in the command too.<br>

Create a .dmg imagefile for distribution from discutility of the folder containing the the hidden printerdriver installer and the no payload pkg.<br>
<br>


```
#!/bin/bash
PATH_SCRIPT=$(dirname "$1")
/usr/sbin/installer -pkg "$PATH_SCRIPT/CHANGE_ME_TO_PRINTERDRIVER_NAME.pkg" -target /
```
