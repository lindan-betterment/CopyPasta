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
    lazy var clip_keys = delegate.pasteboardItemTimeStamps
    @IBOutlet weak var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Register observer notification
        //NotificationCenter.default.addObserver(self, selector: #selector(updateClip), name: NSNotification.Name(rawValue: "update"), object: nil)
        // Inform view of table data.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // Call when item added to clipboard
    @objc func updateClip() {
        // Print statement debugging
        print("update")
        self.tableView.reloadData()
    }
}

// MARK: Actions

extension ClipViewController: NSTableViewDataSource {
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return clip_keys.count
  }

}

extension ClipViewController {
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

}
