# podinstall

Run `pod install` from a GUI without cd'ing through all your projects.


## Backstory (you can just skip this, but I need to rant somewhere :P)

As an android devleoper which has been forced to write iOS apps, I was used to Gradle and Android Studio's comfort. 
I was used to edit my `build.gradle` (which for iOS devs is `Podfile`), then press the `Sync Now` button inside my IDE and get all the new dependencies downloaded. This is not possible with Xcode, and since Xcode extensions can't execute `pod install` I wrote a simple application that will list all your projects containing a file with the `.xcworkspace` extension and will let you run `pod install` without opening iTerm and cd'ing into to your project root every f\*ing time.

## How it works

Opening the app the first time will just add you an icon in your menu bar. Once you set your root folder the app will scan recursively this folder looking for `.xcworkspace` files. It will add an entry for every project. Once you set the root folder, this app will scan the folder every time you press the `Refresh` button and every time you restart the app. 
**In order to avoid useless work this app will never scan your folder automatically.**

## Setup

- Run the application, an icon will appear on your menu bar.
- Select the application on the menu bar, a dropdown menu will show up
- Click on the `Set root folder` option
- Select the folder from which this app will start it's scan (this will scan recursively every subfolder)
- From the dropdown click the `Refresh` option; this will actually start the scanning process
- Wait for a notification to appear
- From the dropdown select the `Projects` option; if everything worked you should see your projects listed there
- Click on a project to run `pod install` on the project's folder
- Wait for a notification to appear, telling you that the operation is completed

## Why not on the App Store??? Why no sandbox???

This app is not sandboxed because it is not possible to run `pod install` in a sandboxed environment without getting crazy. Since `pod` relies on ruby one should sandbox: the pod binary, the ruby binary, every folder which needs to be updated, maybe other stuff which I'm not aware of. So this app is not sandboxed.
Since one can't submit an application which is not sandboxed to the App Store...Well this is not on the store. Thanks Apple for that wonderful IDE, Xcode, which is so user friendly and open to developers which works 8h/d with your software. I really, really, really love you and your choices.
