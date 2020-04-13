# CopyPasta ![pasta image](https://github.com/emberOwl/CopyPasta/raw/master/CopyPasta/Assets.xcassets/pasta.imageset/pasta.png "pasta")

CopyPasta is yet another unobtrusive clipboard extension for MacOS. CopyPasta stores the last n(TBD) items that were copied onto the clipboard and can paste any of the items selected. There will be no support for any MacOS versions previous to Catalina.

This is a tool I created for personal use.

## Why use CopyPasta?

- I made this.
- Retains original keyboard shortcut functionality (⌘ + c) and (⌘ + v)
- Extends the storage of (⌘ + c)'d items
- Hella cute menu bar logo

## I don't wanna use CopyPasta

Here are some well developed, free, and open source applications that I would suggest:
- [Clipy](https://github.com/Clipy/Clipy)
- [Maccy](https://github.com/p0deje/Maccy)

## How does this work?

### Copy

With every (⌘ + c) keypress, each copied item is stored in the cache, ordered by approximately the timestamp of the keypress.

### Paste

(⌘ + v) will paste the last item copied.

(⌘ + ^ + v) will bring up a list of the last copied items for selection. Clicking on an item will paste it where the cursor is.

## How does this **really** work?

### Copy

The application polls for changes every 500 milliseconds for changes in the general NSPasteboard. When it encounters a change, it stores the new item in a key value store located in the cache, the key being a SHA-1 hash of the content.  

#### This seems dumb.

In MacOS, [there is currently no better way to monitor the pasteboard for changes](https://stackoverflow.com/a/5033480), [unlike iOS](https://developer.apple.com/documentation/uikit/uipasteboard/1622104-changednotification).

### Paste

A global hotkey listener waits for the keypress combination (⌘ + ^ + v). Upon keypress, it will bring up the list of copied items either in the menu bar popover or a separate window. (TBD) The list is retrieved from the aforementioned key value store.

## Logo
Attributed to [IconKing from freeicons.io](https://freeicons.io/restaurant-and-food-icons/restaurant-pasta-icon-icon). Thank you!

## Thank you
[RayWenderlich was a priceless resource for MacOS application development.](https://www.raywenderlich.com/) Thank you!

#### TODO
- Reformat image (big) and text (scroll)
- Shortcuts
- Sound effects
- Option to reorder menu
- Fix whitespace
- Think about keeping track of timestamps
- drag and drop
- Add PDF formats
