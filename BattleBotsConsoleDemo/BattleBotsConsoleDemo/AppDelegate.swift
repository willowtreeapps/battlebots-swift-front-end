//
//  AppDelegate.swift
//  BattleBotsConsoleDemo
//
//  Created by Andrew Carter on 6/27/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let renderer = CLIRenderer()
        renderer.runDemo()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

