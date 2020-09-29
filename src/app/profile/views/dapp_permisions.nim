import NimQml
import Tables
import json
import json_serialization
import sequtils
import strutils
from ../../../status/libstatus/types import Setting, PendingTransactionType, RpcException
import ../../../status/threads
import ../../../status/ens as status_ens
import ../../../status/libstatus/wallet as status_wallet
import ../../../status/libstatus/settings as status_settings
import ../../../status/libstatus/utils as libstatus_utils
import ../../../status/libstatus/tokens as tokens
import ../../../status/status
from eth/common/utils import parseAddress
import ../../../status/wallet
import sets
import stew/byteutils
import eth/common/eth_types, stew/byteutils

QtObject:
  type DappsPermissionManager* = ref object of QAbstractListModel
    status: Status

  proc setup(self: DappsPermissionManager) = self.QAbstractListModel.setup

  proc delete(self: DappsPermissionManager) =
    self.usernames = @[]
    self.QAbstractListModel.delete

  proc newDappsPermissionManager*(status: Status): DappsPermissionManager =
    new(result, delete)
    result.status = status
    result.setup
