import strformat, httpclient, json, chronicles, sequtils, strutils, tables
import ../libstatus/core as status
import ../libstatus/contracts as contracts
import eth/common/eth_types

type Collectible* = ref object
    name*, image*: string

proc tokenOfOwnerByIndex(contract: Contract, address: EthAddress, index: int) =
  let payload = %* [{
    "to": $contract.address,
    "data": contract.methods["tokenOfOwnerByIndex"].encodeAbi(address, index) # contracts.encodeAbi("tokenOfOwnerByIndex(address,uint256)", address, index)
  }, "latest"]
  let response = status.callPrivateRPC("eth_call", payload)
  debug "TOKEN", response
  # TODO convert token


proc getCryptoKitties*(address: EthAddress): seq[Collectible] =

  # TODO put this in constants
  try:
    let contract = contracts.getContract(Network.Mainnet, "crypto-kitties")
    tokenOfOwnerByIndex(contract, address, 0)
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
    tokenOfOwnerByIndex(contract, address, 0)
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

