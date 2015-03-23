![logo](https://cloud.githubusercontent.com/assets/1057179/6772810/57a5ca72-d0c3-11e4-88fe-ddc6b9b33339.png)

#Overview#

JumpMarks is an Xcode plugin to navigate your project files by numbered bookmarks. When refactoring or writing new code, we often jump around to different files in our project to compare blocks of code. JumpMarks allows you to set numbered bookmarks (0-9) to jump around these points in your code. Simply type `Shift + Option + [0-9]` to set a mark at the currently selected line in your open file editor, and then type `Option + [0-9]` to jump back to that mark later.

#Installation#

####Build from Source####
- Build the Xcode project. The plugin will be installed in `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins`.
- Restart Xcode.

To uninstall, remove the plugin file `JumpMarks.xcplugin` from `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins` and restart Xcode.

##Acknowledgements##
- The idea came from [DPack](http://www.usysware.com/dpack/Bookmarks.aspx), a plugin for Visual Studio that had this functionality that I wanted to port over.
- The xCode Template plugin used to create this project:  https://github.com/kattrali/Xcode-Plugin-Template
