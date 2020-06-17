import strformat, httpclient, json, chronicles, sequtils, strutils
import ../libstatus/core as status
# import ../libstatus/utils as utils
import ../libstatus/contracts as contracts
import eth/common/eth_types

type Collectible* = ref object
    name*, image*: string

proc tokenOfOwnerByIndex(contractAddress, address: EthAddress, index: int) =
  let encodedMethod = contracts.encodeMethod("tokenOfOwnerByIndex(address,uint256)")

  let payload = %* [{
    "to": $contractAddress,
    "data": contracts.encodeAbi("tokenOfOwnerByIndex(address,uint256)", address, index) #fmt"0x{encodedMethod}{contracts.encodeParam(address)}{contracts.encodeParam(index)}"
  }, "latest"]
  let response = status.callPrivateRPC("eth_call", payload)
  debug "TOKEN", response
  # TODO convert token


proc getCryptoKitties*(address: EthAddress): seq[Collectible] =

  # TODO put this in constants
  try:
    let contract = contracts.getContract(Network.Mainnet, "crypto-kitties")
    tokenOfOwnerByIndex(contract.address, address, 0)
  except Exception as e:
    error "oh noes", err=e.msg
  

  # TODO handle offset (recursive method?)
  # Crypto kitties has a limit of 20
  let url: string = fmt"https://api.cryptokitties.co/kitties?limit=20&offset=0&owner_wallet_address={$address}&parents=false"
  let client = newHttpClient()
  client.headers = newHttpHeaders({ "Content-Type": "application/json" })

  let response = client.request(url)
  let kitties = parseJson(response.body)["kitties"]
  result = @[]
  for kitty in kitties:
    result.add(Collectible(name: kitty["name"].str, image: kitty["image_url"].str))



proc getStrikers*(address: EthAddress) =
  # TODO put this in constants
  try:
    let contract = contracts.getContract(Network.Mainnet, "strikers")
    tokenOfOwnerByIndex(contract.address, address, 0)
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


proc getAllCollectibles*(address: EthAddress): seq[Collectible] =
  result = concat(getCryptoKitties(address)) # TODO add other collectibles

