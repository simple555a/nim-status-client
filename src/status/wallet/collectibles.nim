import strformat, httpclient, json, chronicles, sequtils
import ../libstatus/core as status

type Collectible* = ref object
    name*, image*: string


# (defn token-of-owner-by-index
#   [contract address index cb]
#   (json-rpc/eth-call
#    {:contract contract
#     :method "tokenOfOwnerByIndex(address,uint256)"
#     :params [address index]
#     :outputs ["uint256"]
#     :on-success (fn [[token]] (cb token))}))

proc tokenOfOwnerByIndex(contract: string, address: string, index: int) =
  let payload = %* [{
    "to": contract,
    "method": "tokenOfOwnerByIndex(address,uint256)",
    # "from": account,
    "params": [address, index]

  }]
  let response = $status.callPrivateRPC("eth_call", payload)
  # FIXME {\"jsonrpc\":\"2.0\",\"id\":0,\"error\":{\"code\":-32602,\"message\":\"missing value for required argument 1\"}}
  debug "CALLED", response

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


proc getAllCollectibles*(address: string): seq[Collectible] =
  result = concat(getCryptoKitties(address)) # TODO add other collectibles

