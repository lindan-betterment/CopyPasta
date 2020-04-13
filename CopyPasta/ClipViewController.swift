//
//  ClipViewController.swift
//  CopyPasta
//
//  Created by linda on 4/2/20.
//  Copyright © 2020 linda. All rights reserved.
//

import Cocoa
import PINCache
import AVFoundation

class ClipViewController: NSViewController, NSPopoverDelegate {
    // TODO: Refresh with new clips?
    let delegate = (NSApplication.shared.delegate) as! AppDelegate
    lazy var clips = delegate.pasteboardItems
    lazy var popover = delegate.popover
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    
    let tv = NSTextFieldCell()
    
    var input_audio_player = AVAudioPlayer()
    var selection_audio_player = AVAudioPlayer()
    var clear_audio_player = AVAudioPlayer()
    
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
        popover.delegate = self
        
        // Initilize sound file
        
        let input_sound = Bundle.main.path(forResource: "Quick Fart", ofType: "wav")
        let selection_sound = Bundle.main.path(forResource: "Sharp Fart", ofType: "wav")
        let clear_sound = Bundle.main.path(forResource: "Lawn Mower Fart", ofType: "wav")
        
        do {
            input_audio_player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: input_sound!))
            selection_audio_player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: selection_sound!))
            clear_audio_player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: clear_sound!))
        }
        catch {
            // These errors are generally not important
            print(error)
        }
    }
    
    // Call when item added to clipboard
    @objc func refresh() {
        DispatchQueue.main.async {
            // refresh clip items
            self.clips = self.delegate.pasteboardItems
            print(self.clips.count)
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
    
    // MARK: - Popover Delegate
    
    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        return true
    }
}

// MARK: Actions

extension ClipViewController: NSTableViewDataSource {
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return clips.count
  }

}

extension ClipViewController {
    @IBAction func clear_pasteboard(_ sender: NSButton) {
        // Quickly clear out user UI for fast feedback
        clear_audio_player.play()
        
        // empty locally stored keys
        clips = [Clip]()
        // update the tableview
        refresh()
        
        // Actually clear out items
        
        // empty AppDelegate pasteboard keys
        self.delegate.pasteboardItems = [Clip]()
        
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
    func getClip(clipKey: String) -> NSCoding {
        return PINCache.shared().object(forKey: clipKey) as! NSCoding
    }
        
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    var text: String = ""
    var cellIdentifier: String = ""
    let item = getClip(clipKey: clips[row].hash)
    
    // If nothing in clipboard, display nothing
        if row > clips.count {
            return nil
        }

    // Populate the cell.
    if tableColumn == tableView.tableColumns[0] {
        text = clips[row].menu_view
      cellIdentifier = CellIdentifiers.ClipCell
    }
    
    // Repeat for the coming cells.
    
    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      
        if type(of: item) === NSBitmapImageRep.self {
            let new_image = item as! NSBitmapImageRep
            cell.imageView?.image = NSImage(data: new_image.tiffRepresentation!)
            cell.textField?.stringValue = ""
        }
        else {
            cell.imageView?.image = nil
            // This does bad things for some reason
            // cell.imageView?.isHidden = true
            cell.textField?.stringValue = text
        }
        input_audio_player.play()
      return cell
    }
    return nil
  }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        // clear pasteboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        // move selection onto pasteboard
        if tableView.selectedRow > clips.count - 1 {
            return
        }
        
        let selected_clip = getClip(clipKey: clips[tableView.selectedRow].hash)
        selection_audio_player.play()
        
        if type(of: selected_clip) === NSBitmapImageRep.self {
            let selected_img = selected_clip as! NSBitmapImageRep
            let pasteboard_img = NSImage(data: selected_img.tiffRepresentation!)
            pasteboard.writeObjects([pasteboard_img!])
        }
        else {
            pasteboard.writeObjects([selected_clip as! NSString])
        }
        //pasteboard.setString(clips[tableView.selectedRow].menu_view, forType: NSPasteboard.PasteboardType.string)
        
        /* NOTES
            Originally wanted to programatically Cmd + V, but the cursor would be in the incorrect area. Idea was abandoned.
            
            Challenges for that idea include:
                - https://stackoverflow.com/questions/17693408/enable-access-for-assistive-devices-programmatically-on-10-9
                - https://stackoverflow.com/questions/57683783/unable-to-simulate-keystrokes-in-macos-mojave-app
                - https://stackoverflow.com/questions/7018354/remove-sandboxing
        */
    }
    
    // "Dynamically" resizing cell height
    // Will need to change text/img view to increase size
    // Probably need to add scroll
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        tv.font = NSFont.systemFont(ofSize: 13)
        let item = clips[row].menu_view
        tv.stringValue = item

        let yourHeight = tv.cellSize(forBounds: NSMakeRect(CGFloat(0.0), CGFloat(0.0), 435, CGFloat(Float.greatestFiniteMagnitude))).height
        return yourHeight
    }
}
