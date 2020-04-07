//
//  AppDelegate.swift
//  CopyPasta
//
//  Created by linda on 4/1/20.
//  Copyright © 2020 linda. All rights reserved.
//  https://www.raywenderlich.com/450-menus-and-popovers-in-menu-bar-apps-for-macos#toc-anchor-001

import Cocoa
import PINCache

// hashing for quick duplicate check
import CommonCrypto

extension String {
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    // member variables
    var timer: DispatchSourceTimer!
    let pasteboard: NSPasteboard = .general
    var lastChangeCount: Int = 0
    var pasteboardItemKeys:[String] = []
    
    /* TODO: keep track of timestamp?
    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 100000)
    }
    */

    // Create the application icon with fixed length
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    // Create the popover window
    let popover = NSPopover()
    
    @objc func togglePopover(_ sender: Any?) {
      if popover.isShown {
        closePopover(sender: sender)
      } else {
        showPopover(sender: sender)
      }
    }

    func showPopover(sender: Any?) {
      if let button = statusItem.button {
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
      }
    }

    func closePopover(sender: Any?) {
      popover.performClose(sender)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
          button.image = NSImage(named:NSImage.Name("pasta"))
          button.action = #selector(togglePopover(_:))
        }
        popover.contentViewController = ClipViewController.freshController()
        
        // Start async listen for pasteboard change
        timer = DispatchSource.makeTimerSource()
        // Start NOW every 0.5 seconds
        timer.schedule(deadline: .now(), repeating: .milliseconds(500), leeway: .seconds(0))
        timer.setEventHandler(handler: {
            // Check if pasteboard changed
            if self.pasteboard.changeCount != self.lastChangeCount {
                // Update counter
                self.lastChangeCount = self.pasteboard.changeCount
                // Add current value to key value store
                let read = self.pasteboard.pasteboardItems
                let clipboard = read!.first!.string(forType: .string)
                if clipboard! != nil {
                    // Get timestamp?
                    // let timestamp = self.getCurrentMillis()
                    
                    // Get hash
                    let key = clipboard!.sha1()
                    
                    if !self.pasteboardItemKeys.contains(key) {
                        // Update view for fast user feedback
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "startSpinnerNotif"), object: nil)
                        // Slow user down with "loading" icon
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshNotif"), object: nil)
                        
                        // Add to array of ids
                        self.pasteboardItemKeys.append(key)
                        // TODO: read is not a proper NSCoding obj
                        // Also this is slow
                        PINCache.shared().setObject(clipboard! as NSCoding, forKey: key)
                       
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "endSpinnerNotif"), object: nil)
                    }
                }
            }
        })

        // Vroom vroom bitch
        timer.resume()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CopyPasta")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }
}

