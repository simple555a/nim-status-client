type
  Network {.pure.} = enum
    Mainnet,
    Testnet
    
type Contract* = ref object
  name: string
  network: Network
  address: string

const CONTRACTS: seq[Contract] = @[
  Contract(name: "snt", network: Network.Mainnet, address: "0x744d70fdbe2ba4cf95131626614a1763df805b9e"),
  Contract(name: "snt", network: Network.Testnet, address: "0xc55cf4b03948d7ebc8b9e8bad92643703811d162"),
  Contract(name: "tribute-to-talk", network: Network.Testnet, address: "0xC61aa0287247a0398589a66fCD6146EC0F295432"),
  Contract(name: "stickers", network: Network.Mainnet, address: "0x0577215622f43a39f4bc9640806dfea9b10d2a36"),
  Contract(name: "stickers", network: Network.Testnet, address: "0x8cc272396be7583c65bee82cd7b743c69a87287d"),
  Contract(name: "sticker-market", network: Network.Mainnet, address: "0x12824271339304d3a9f7e096e62a2a7e73b4a7e7"),
  Contract(name: "sticker-market", network: Network.Testnet, address: "0x6CC7274aF9cE9572d22DFD8545Fb8c9C9Bcb48AD"),
  Contract(name: "sticker-pack", network: Network.Mainnet, address: "0x110101156e8F0743948B2A61aFcf3994A8Fb172e"),
  Contract(name: "sticker-pack", network: Network.Testnet, address: "0xf852198d0385c4b871e0b91804ecd47c6ba97351"),
]

proc getContract(network: Network, name: string): Contract =
  let found = CONTRACTS.filter(contract => contract.name == name and contract.network == network)
  result = found.len > 0 ? found[0] : nil