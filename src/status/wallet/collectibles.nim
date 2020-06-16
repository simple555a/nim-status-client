import strformat, httpclient, json, chronicles, sequtils, strutils
import ../libstatus/core as status
import ../libstatus/utils as utils

type Collectible* = ref object
    name*, image*: string

proc tokenOfOwnerByIndex(contract: string, address: string, index: int) =
  let encodedMethod = utils.encodeMethod("tokenOfOwnerByIndex(address,uint256)")

  var postfixedAccount: string = address
  postfixedAccount.removePrefix("0x")

  let payload = %* [{
    "to": contract,
    "data": fmt"0x{encodedMethod}{postfixedAccount}{toHex(index, 64)}"
  }, "latest"]
  let response = status.callPrivateRPC("eth_call", payload)
  debug "TOKEN", response
  # TODO convert token


proc getCryptoKitties*(address: string): seq[Collectible] =

  # TODO put this in constants
  try:
    tokenOfOwnerByIndex("0x06012c8cf97bead5deae237070f9587f8e7a266d", address, 0)
  except Exception as e:
    error "oh noes", err=e.msg
  

  # TODO handle offset (recursive method?)
  # Crypto kitties has a limit of 20
  let url: string = fmt"https://api.cryptokitties.co/kitties?limit=20&offset=0&owner_wallet_address={address}&parents=false"
  let client = newHttpClient()
  client.headers = newHttpHeaders({ "Content-Type": "application/json" })

  let response = client.request(url)
  let kitties = parseJson(response.body)["kitties"]
  result = @[]
  for kitty in kitties:
    result.add(Collectible(name: kitty["name"].str, image: kitty["image_url"].str))



proc getStrikers*(address: string) =
  # TODO put this in constants
  try:
    tokenOfOwnerByIndex("0xdcaad9fd9a74144d226dbf94ce6162ca9f09ed7e", address, 0)
  except Exception as e:
    error "oh noes", err=e.msg
  

  # TODO handle offset (recursive method?)
  # Crypto kitties has a limit of 20
  # let url: string = fmt"https://api.cryptokitties.co/kitties?limit=20&offset=0&owner_wallet_address={address}&parents=false"
  # let client = newHttpClient()
  # client.headers = newHttpHeaders({ "Content-Type": "application/json" })

  # let response = client.request(url)
  # let kitties = parseJson(response.body)["kitties"]
  # result = @[]
  # for kitty in kitties:
  #   result.add(Collectible(name: kitty["name"].str, image: kitty["image_url"].str))


proc getAllCollectibles*(address: string): seq[Collectible] =
  result = concat(getCryptoKitties(address)) # TODO add other collectibles

