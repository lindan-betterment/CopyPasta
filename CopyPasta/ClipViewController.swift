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
    let delegate = (NSApplication.shared.delegate) as! AppDelegate
    lazy var clip_keys = delegate.pasteboardItemTimeStamps
    @IBOutlet var textLabel: NSTextField!
    
    var currentClipIndex: Int = 0 {
      didSet {
        updateClip()
      }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        currentClipIndex = 0
    }
    
    func updateClip() {
        var clip_text = ""
        
        PINCache.shared().object(forKey: self.clip_keys[self.currentClipIndex]) { (cache, key, object) in
            if let clip = object as? NSCoding {
                clip_text = "\(self.clip_keys[self.currentClipIndex]): \(clip)"
                
                // This block is async because setting string value must be used from main thread only
                DispatchQueue.main.async {
                    print(clip_text)
                    self.textLabel.stringValue = String(clip_text)
                }
            }
        }
    }
}

// MARK: Actions

extension ClipViewController {
  @IBAction func previous(_ sender: NSButton) {
    // TODO: replace with SwiftUI List
    // currentClipIndex = (currentClipIndex - 1 + clip_keys.count) % clip_keys.count
  }

  @IBAction func next(_ sender: NSButton) {
    // TOOD: replace with SwiftUI List
    // currentClipIndex = (currentClipIndex + 1) % clip_keys.count
    // print(currentClipIndex)
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
