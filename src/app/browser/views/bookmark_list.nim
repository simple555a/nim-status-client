import NimQml, Tables
import strutils
import ../../../status/status
import ../../../status/libstatus/types

type
  ChannelsRoles {.pure.} = enum
    Name = UserRole + 1,
    Url = UserRole + 2
    Image = UserRole + 3

QtObject:
  type
    BookmarkList* = ref object of QAbstractListModel
      bookmarks*: seq[Bookmark]
      status: Status

  proc setup(self: BookmarkList) = self.QAbstractListModel.setup

  proc delete(self: BookmarkList) = 
    self.bookmarks = @[]
    self.QAbstractListModel.delete

  proc newBookmarkList*(status: Status): BookmarkList =
    new(result, delete)
    result.bookmarks = @[]
    result.status = status
    result.setup()

  method rowCount*(self: BookmarkList, index: QModelIndex = nil): int = self.bookmarks.len

  method data(self: BookmarkList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.bookmarks.len:
      return

    let bookmarkItem = self.bookmarks[index.row]

    let bookmarkItemRole = role.ChannelsRoles
    case bookmarkItemRole:
      of ChannelsRoles.Name: result = newQVariant(bookmarkItem.name)
      of ChannelsRoles.Url: result = newQVariant(bookmarkItem.url)
      of ChannelsRoles.Image: result = newQVariant(bookmarkItem.image)

  method roleNames(self: BookmarkList): Table[int, string] =
    {
      ChannelsRoles.Name.int:"name",
      ChannelsRoles.Url.int:"url",
      ChannelsRoles.Image.int: "image",
    }.toTable

  proc addBookmarkItemToList*(self: BookmarkList, bookmark: Bookmark) =
    self.beginInsertRows(newQModelIndex(), self.bookmarks.len, self.bookmarks.len)
    self.bookmarks.add(bookmark)
    self.endInsertRows()

#   proc getBookmarkIndexByUrl*(self: BookmarkList, bookmark: Bookmark)

  proc removeBookmarkItemFromList*(self: BookmarkList, index: int) =
    self.beginRemoveRows(newQModelIndex(), index, index)
    self.bookmarks.delete(index)
    self.endRemoveRows()


  proc setNewData*(self: BookmarkList, bookmarkList: seq[Bookmark]) =
    self.beginResetModel()
    self.bookmarks = bookmarkList
    self.endResetModel()
  
  proc getBookmarkByUrl*(self: BookmarkList, url: string): Bookmark =
    for bookmark in self.bookmarks:
      if bookmark.url == url:
        return bookmark

