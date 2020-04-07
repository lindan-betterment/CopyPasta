//
//  ClipViewController.swift
//  CopyPasta
//
//  Created by linda on 4/2/20.
//  Copyright © 2020 linda. All rights reserved.
//

import Cocoa
import PINCache

class ClipViewController: NSViewController {
    // TODO: Refresh with new clips?
    let delegate = (NSApplication.shared.delegate) as! AppDelegate
    lazy var clip_keys = delegate.pasteboardItemKeys
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var progressIndicator: NSProgressIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        // Register observer notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "refreshNotif"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinner), name: NSNotification.Name(rawValue: "startSpinnerNotif"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideSpinner), name: NSNotification.Name(rawValue: "endSpinnerNotif"), object: nil)
        // Inform view of table data.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.target = self
    }
    
    // Call when item added to clipboard
    @objc func refresh() {
        DispatchQueue.main.async {
            // refresh clip items
            self.clip_keys = self.delegate.pasteboardItemKeys
            self.tableView.reloadData()
        }
    }
    @objc func showSpinner() {
        DispatchQueue.main.async {
            self.progressIndicator.isHidden = false
            self.progressIndicator.startAnimation(self)
        }
    }
    
    @objc func hideSpinner() {
        DispatchQueue.main.async {
            self.progressIndicator.isHidden = true
            self.progressIndicator.stopAnimation(self)
        }
    }
}

// MARK: Actions

extension ClipViewController: NSTableViewDataSource {
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return clip_keys.count
  }

}

extension ClipViewController {
    @IBAction func clear_pasteboard(_ sender: NSButton) {
        // Quickly clear out user UI for fast feedback
        
        // empty locally stored keys
        clip_keys = [String]()
        // update the tableview
        refresh()
        
        // Actually clear out items
        
        // empty AppDelegate pasteboard keys
        self.delegate.pasteboardItemKeys = []
        
        // clear cache items
        PINCache.shared().removeAllObjects()
    }
    
  @IBAction func quit(_ sender: NSButton) {
    NSApplication.shared.terminate(sender)
  }
}

extension ClipViewController {
  // MARK: Storyboard instantiation
  static func freshController() -> ClipViewController {
    // Get a reference to Main.storyboard.
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    // Create a Scene identifier that matches the one you set just before.
    let identifier = NSStoryboard.SceneIdentifier("ClipViewController")
    // Instantiate ClipViewController and return it.
    guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? ClipViewController else {
      fatalError("Why cant i find ClipViewController? - Check Main.storyboard")
    }
    return viewcontroller
  }
}

extension ClipViewController: NSTableViewDelegate {

  fileprivate enum CellIdentifiers {
    static let ClipCell = "ClipCellID"
  }
    func getClip(clipKey: String) -> String {
        return PINCache.shared().object(forKey: clipKey) as? String ?? ""
    }
        
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    var text: String = ""
    var cellIdentifier: String = ""
    let item = getClip(clipKey: clip_keys[row])
    
    // If nothing in clipboard, display nothing
    // TODO: replace with guard statement, probably?
    if item == "" {
        return nil
    }

    // Populate the cell.
    if tableColumn == tableView.tableColumns[0] {
      text = item
      cellIdentifier = CellIdentifiers.ClipCell
    }
    
    // Repeat for the coming cells.
    
    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = text
      return cell
    }
    return nil
  }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        // clear pasteboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        // move selection onto pasteboard
        if tableView.selectedRow > clip_keys.count - 1 {
            return
        }
        pasteboard.setString(getClip(clipKey: clip_keys[tableView.selectedRow]), forType: NSPasteboard.PasteboardType.string)
        
        /* NOTES
            Originally wanted to programatically Cmd + V, but the cursor would be in the incorrect area. Idea was abandoned.
            
            Challenges for that idea include:
                - https://stackoverflow.com/questions/17693408/enable-access-for-assistive-devices-programmatically-on-10-9
                - https://stackoverflow.com/questions/57683783/unable-to-simulate-keystrokes-in-macos-mojave-app
                - https://stackoverflow.com/questions/7018354/remove-sandboxing
        */
    }

}
