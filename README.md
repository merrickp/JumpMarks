![logo](https://github.com/merrickp/JumpMarks/blob/assets/logo.png)

[![Build Status](https://travis-ci.org/merrickp/JumpMarks.svg?branch=master)](https://travis-ci.org/merrickp/JumpMarks)

# Overview

JumpMarks is an Xcode plugin to navigate your project files by numbered bookmarks. When developing applications, it is often not enough to be able to jump between just two places in our code by navigating forward and backward in history. There may be logical components that we jump around perhaps between model, view, and controller (or view model). When refactoring, we may jump around to different files in our project to compare the old and new blocks of code. Before a code review, we may set all of the locations that we want reviewed in the IDE.

Whatever the need is to navigate your code efficiently, JumpMarks allows you to set numbered bookmarks (0-9) to jump around these points in your code. Simply type `Shift + Option + [0-9]` to set a mark at the currently selected line in your open file editor, and then type `Option + [0-9]` to jump back to that mark later.

# Installation
Install by either:

#### 1. Use Alcatraz (Easy Mode)
- Install from [Alcatraz](http://alcatraz.io)

### or

#### 2. Build from Source (Manual Labor)
- Build the Xcode project. The plugin will be installed in `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins`.
- Restart Xcode.

To uninstall, remove the plugin file `JumpMarks.xcplugin` from `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins` and restart Xcode.

## Usage
#### Toggling JumpMarks:
Toggle by typing <kbd>Shift</kbd> + <kbd>Option</kbd> + [<kbd>0</kbd>-<kbd>9</kbd>]
![toggle_navigation](https://github.com/merrickp/JumpMarks/blob/assets/toggle.gif)

#### Go to specific JumpMark:
Jump directly to numbered mark by typing <kbd>Option</kbd> + [<kbd>0</kbd>-<kbd>9</kbd>]
![jump_navigation](https://github.com/merrickp/JumpMarks/blob/assets/jump.gif)

#### Go to next/previous JumpMark:
Jump to next/prev set mark by typing <kbd>Option</kbd> + <kbd>]</kbd> or <kbd>Option</kbd> + <kbd>[</kbd>, respectively
![next_navigation](https://github.com/merrickp/JumpMarks/blob/assets/next.gif)

Other options can be found in the `JumpMarks` submenu added in the `View` menu in the menu bar.

Marks will be persisted in a plist file named ${USER}.jumpmarks in the project's xcuserdata.

## Acknowledgements
- The idea came from [DPack](http://www.usysware.com/dpack/Bookmarks.aspx), a plugin for Visual Studio that had this functionality that I wanted to port over.
- The xCode Template plugin used to create this project:  https://github.com/kattrali/Xcode-Plugin-Template
