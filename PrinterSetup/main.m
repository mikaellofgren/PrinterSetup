//
//  main.m
//  PrinterSetup
//
//  Created by Mikael Löfgren on 2018-12-25.
//  Copyright © 2018 Mikael Löfgren. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[]) {
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}
