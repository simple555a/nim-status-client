import NimQml, os, strformat, strutils, parseUtils, chronicles, json
import ../../status/status
import ../../status/libstatus/settings as status_settings
import ../../status/libstatus/types
import ./views/bookmark_list

QtObject:
  type BrowserView* = ref object of QObject
    status*: Status
    bookmarks*: BookmarkList

  proc setup(self: BrowserView) =
    self.QObject.setup

  proc delete*(self: BrowserView) =
    self.QObject.delete
    self.bookmarks.delete

  proc newBrowserView*(status: Status): BrowserView =
    new(result, delete)
    result = BrowserView()
    # result.bookmarks = newBookmarkList(status)
    result.status = status
    result.setup

  proc init*(self: BrowserView) =
    let bookmarksJSON = status_settings.getSetting[string](Setting.Bookmarks, "[]").parseJson
    debug "BOOKMARKS", bookmarksJSON
    var bookmarks: seq[Bookmark] = @[]
    for bookmark in bookmarksJSON:
      bookmarks.add(Bookmark(url: bookmark.getStr, name: "Name", image: ""))
    self.bookmarks.setNewData(bookmarks)


  # proc getBookmarks*(self: BrowserView, bookmark: string) {.slot.} =
  #   let bookmarks = status_settings.getSetting[string](Setting.Bookmarks, "[]").parseJson

  proc getBookmarks*(self: BrowserView): QVariant {.slot.} =
    return newQVariant(self.bookmarks)

  QtProperty[QVariant] mnemonic:
    read = getMnemonic

  proc addBookmark*(self: BrowserView, bookmark: string) {.slot.} =
    self.bookmarks.addBookmarkItemToList(Bookmark(url: bookmark, name: "Name", image: ""))
    var bookmarksJSON: seq[string] = @[]
    for bookmark in self.bookmarks.bookmarks:
      bookmarksJSON.add(bookmark.url)
    discard status_settings.saveSetting(Setting.Bookmarks, $bookmarksJSON)
