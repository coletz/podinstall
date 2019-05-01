import Foundation
import Cocoa

var bookmarks: [URL: Data]?

func bookmarkPath() -> String{
    var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    url = url.appendingPathComponent("Bookmarks.dict")
    return url.path
}

func loadBookmarks(){
    let path = bookmarkPath()
    bookmarks = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [URL: Data]
    bookmarks?.forEach { restoreBookmark($0) }
}

func saveBookmarks(){
    let path = bookmarkPath()
    NSKeyedArchiver.archiveRootObject(bookmarks, toFile: path)
}

func storeBookmark(url: URL){
    do {
        let data = try url.bookmarkData(options: NSURL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        bookmarks?[url] = data
        
        saveBookmarks()
    } catch {
        print ("Error storing bookmarks")
    }
    
}

func restoreBookmark(_ bookmark: (key: URL, value: Data)) {
    let restoredUrl: URL?
    var isStale = false
    
    Swift.print ("Restoring \(bookmark.key)")
    do {
        restoredUrl = try URL.init(resolvingBookmarkData: bookmark.value, options: NSURL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
    }
    catch
    {
        Swift.print ("Error restoring bookmarks")
        restoredUrl = nil
    }
    
    if let url = restoredUrl {
        if isStale {
            Swift.print ("URL is stale")
        } else {
            if !url.startAccessingSecurityScopedResource()
            {
                Swift.print ("Couldn't access: \(url.path)")
            }
        }
    }
    
}

func allowFolder(_ callback: @escaping (URL) -> Void){
    let panel = NSOpenPanel()
    panel.allowsMultipleSelection = false
    panel.canChooseDirectories = true
    panel.canCreateDirectories = true
    panel.canChooseFiles = false
    panel.begin { result in
        
        guard result == NSApplication.ModalResponse.OK, panel.urls.isEmpty == false, let url = panel.urls.first else {
            return
        }
        
        storeBookmark(url: url)
        callback(url)
    }
}
