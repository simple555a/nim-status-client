import NimQml
import Tables
import json
import chronicles

import ../../status/status
import ../../status/chat as status_chat
import ../../status/chat/[chat, message]
import ../../status/libstatus/types

import views/channels_list
import views/message_list
import views/chat_item
import views/sticker_pack_list
import views/sticker_list

logScope:
  topics = "chats-view"

QtObject:
  type
    ChatsView* = ref object of QAbstractListModel
      status: Status
      chats*: ChannelsList
      callResult: string
      messageList: Table[string, ChatMessageList]
      activeChannel*: ChatItemView
      activeStickerPackId*: int
      stickerPacks*: StickerPackList
      stickers*: Table[int, StickerList]

  proc setup(self: ChatsView) = self.QAbstractListModel.setup

  proc delete(self: ChatsView) = self.QAbstractListModel.delete

  proc newChatsView*(status: Status): ChatsView =
    new(result, delete)
    result.status = status
    result.chats = newChannelsList()
    result.activeChannel = newChatItemView()
    result.activeStickerPackId = -1
    result.messageList = initTable[string, ChatMessageList]()
    result.stickerPacks = newStickerPackList()
    result.stickers = initTable[int, StickerList]()
    result.setup()

  proc addStickerPackToList*(self: ChatsView, stickerPack: StickerPack) =
    discard self.stickerPacks.addStickerPackToList(stickerPack)
    let stickerList = newStickerList()
    for sticker in stickerPack.stickers:
      discard stickerList.addStickerToList(sticker)
    self.stickers[stickerPack.id] = stickerList
  
  proc getStickerPackList(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.stickerPacks)

  QtProperty[QVariant] stickerPacks:
    read = getStickerPackList

  proc getStickerList(self: ChatsView): QVariant {.slot.} =
    if self.activeStickerPackId > -1:
      result = newQVariant(self.stickers[self.activeStickerPackId])
    else:
      result = newQVariant(newStickerList())

  QtProperty[QVariant] stickers:
    read = getStickerList
    notify = activeStickerPackChanged

  proc getChatsList(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.chats)

  QtProperty[QVariant] chats:
    read = getChatsList

  proc getChannelColor*(self: ChatsView, channel: string): string {.slot.} =
    self.chats.getChannelColor(channel)

  proc activeChannelChanged*(self: ChatsView) {.signal.}

  proc setActiveChannelByIndex*(self: ChatsView, index: int) {.slot.} =
    if(self.chats.chats.len == 0): return
    var response = self.status.chat.markAllChannelMessagesRead(self.activeChannel.id)
    if not response.hasKey("error"):
      self.chats.clearUnreadMessagesCount(self.activeChannel.chatItem)
    let selectedChannel = self.chats.getChannel(index)
    if self.activeChannel.id == selectedChannel.id: return
    self.activeChannel.setChatItem(selectedChannel)
    self.status.chat.setActiveChannel(selectedChannel.id)
    self.activeChannelChanged()

  proc getActiveChannelIdx(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.chats.chats.findIndexById(self.activeChannel.id))

  QtProperty[QVariant] activeChannelIndex:
    read = getActiveChannelIdx
    write = setActiveChannelByIndex
    notify = activeChannelChanged
  
  proc activeStickerPackChanged*(self: ChatsView) {.signal.}

  proc setActiveStickerPackById*(self: ChatsView, id: int) {.slot.} =
    if self.activeStickerPackId == id:
      return

    self.activeStickerPackId = id
    self.activeStickerPackChanged()

  proc getactiveStickerPackId(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.activeStickerPackId)

  QtProperty[QVariant] activeStickerPack:
    read = getactiveStickerPackId
    write = setActiveStickerPackByIndex
    notify = activeStickerPackChanged

  proc setActiveChannel*(self: ChatsView, channel: string) =
    if(channel == ""): return
    self.activeChannel.setChatItem(self.chats.getChannel(self.chats.chats.findIndexById(channel)))
    self.activeChannelChanged()

  proc getActiveChannel*(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.activeChannel)

  QtProperty[QVariant] activeChannel:
    read = getActiveChannel
    write = setActiveChannel
    notify = activeChannelChanged

  proc upsertChannel(self: ChatsView, channel: string) =
    if not self.messageList.hasKey(channel):
      self.messageList[channel] = newChatMessageList(channel)
  
  proc messagePushed*(self: ChatsView) {.signal.}

  proc pushMessages*(self:ChatsView, messages: seq[Message]) =
    for msg in messages:
      self.upsertChannel(msg.chatId)
      self.messageList[msg.chatId].add(msg)
      self.messagePushed()

  proc getMessageList(self: ChatsView): QVariant {.slot.} =
    self.upsertChannel(self.activeChannel.id)
    return newQVariant(self.messageList[self.activeChannel.id])

  QtProperty[QVariant] messageList:
    read = getMessageList
    notify = activeChannelChanged

  proc pushChatItem*(self: ChatsView, chatItem: Chat) =
    discard self.chats.addChatItemToList(chatItem)
    self.messagePushed()

  proc sendMessage*(self: ChatsView, message: string) {.slot.} =
    discard self.status.chat.sendMessage(self.activeChannel.id, message)
  
  proc sendSticker*(self: ChatsView, hash: string, pack: int) {.slot.} =
    discard self.status.chat.sendSticker(self.activeChannel.id, hash, pack)

  proc joinChat*(self: ChatsView, channel: string, chatTypeInt: int): int {.slot.} =
    self.status.chat.join(channel, ChatType(chatTypeInt))

  proc joinGroup*(self: ChatsView) {.slot.} =
    self.status.chat.confirmJoiningGroup(self.activeChannel.id)

  proc messagesLoaded*(self: ChatsView) {.signal.}

  proc loadMoreMessages*(self: ChatsView) {.slot.} =
    trace "Loading more messages", chaId = self.activeChannel.id
    self.status.chat.chatMessages(self.activeChannel.id, false)
    self.messagesLoaded();

  proc leaveActiveChat*(self: ChatsView) {.slot.} =
    self.status.chat.leave(self.activeChannel.id)

  proc updateChats*(self: ChatsView, chats: seq[Chat]) =
    for chat in chats:
      self.upsertChannel(chat.id)
      self.chats.updateChat(chat)
      if(self.activeChannel.id == chat.id):
        self.activeChannel.setChatItem(chat)
        self.activeChannelChanged()

  proc blockContact*(self: ChatsView, id: string): string {.slot.} =
    return self.status.chat.blockContact(id)
