import Cocoa

let PROJECT_ROOT_KEY = "ProjectRootKey"
let PODFILE = "Podfile"
let WORKSPACE = "xcworkspace"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    private var cocoapodsProjects: [Project] = []
    private var cocoapodsProjectUrls: [URL: String] = [:]
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        loadBookmarks()
        setupButton()
        refreshProjectList(nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func setupButton(){
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("cocoapods_icon"))
        }
        updateMenu()
    }
    
    func updateMenu() {
        let menu = NSMenu()
        
        let projectMenu = NSMenu()
        let projectMenuItem = NSMenuItem(title: "Projects", action: nil, keyEquivalent: "")
        projectMenu.title = "ProjectsMenu"
        cocoapodsProjects.forEach {
            let item = NSMenuItem(title: $0.name, action: #selector(AppDelegate.podInstall), keyEquivalent: "")
            projectMenu.addItem(item)
        }
        
        menu.setSubmenu(projectMenu, for: projectMenuItem)
        menu.addItem(projectMenuItem)
        
        menu.addItem(NSMenuItem(title: "Set root folder", action: #selector(AppDelegate.setRootFolder(_:)), keyEquivalent: "f"))
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(AppDelegate.refreshProjectList(_:)), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func refreshProjectList(_ sender: Any?) {
        cocoapodsProjectUrls = [:]
        
        DispatchQueue(label: "scan-root").async {
            if let rootFolder = self.getRootFolder() {
                self.scan(folder: rootFolder)
                "Folder scanned".notify()
                self.cocoapodsProjects = self.cocoapodsProjectUrls.map {
                    Project(
                        path: $0.key.absoluteURL,
                        name: $0.value
                    )
                }
                self.updateMenu()
            } else {
                // TODO: alert "You must set root before refreshing project list"
            }
        }
    }
    
    @objc func setRootFolder(_ sender: Any?) {
        print("setRootFolder")
        allowFolder { url in
            UserDefaults.standard.set(url, forKey: PROJECT_ROOT_KEY)
        }
    }
    
    @objc func podInstall(_ sender: Any?) {
        if let menuItem = sender as? NSMenuItem {
            let projectName = menuItem.title
            guard let project = cocoapodsProjects.first(where: { $0.name == projectName }) else {
                return
            }
            
            guard let scriptPath = Bundle.main.path(forResource: "Script", ofType: "command") else {
                print("Missing Script.command")
                return
            }
            
            "running `pod install`...".notify()
            
            let proc = Process()
            proc.launchPath = scriptPath
            proc.arguments = [project.path.path]
            proc.launch()
            proc.waitUntilExit()

            
            if proc.terminationStatus == 0 {
                "`pod install` completed".notify()
            } else {
                "`pod install` failed!".notify()
            }
            
        }
    }
    
    private func getRootFolder() -> URL? {
        return UserDefaults.standard.url(forKey: PROJECT_ROOT_KEY)
    }
    
    private func scan(folder: URL){
        do {
            let files = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            if files.contains(where:  { $0.lastPathComponent == PODFILE }) {
                if let projectName = files.first(where: { $0.pathExtension == WORKSPACE }) {
                    // This is a folder with a project using Cocoapods!
                    cocoapodsProjectUrls[folder] = projectName.lastPathComponent.replacingOccurrences(of: ".\(WORKSPACE)", with: "")
                }
            } else {
                files.filter { $0.hasDirectoryPath }.forEach {
                    scan(folder: $0)
                }
            }
        } catch {
            print(error)
        }
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}

extension String {
    func notify(){
        print(self)
        let notification = NSUserNotification()
        notification.identifier = "podinstall-\(Date())"
        notification.informativeText = self
        notification.soundName = NSUserNotificationDefaultSoundName
        //notification.contentImage = NSImage(named: "AppIcon")
        //notification.setValue(NSImage(named: "AppIcon"), forKey: "_identityImage")
        
        NSUserNotificationCenter.default.deliver(notification)
    }
}
