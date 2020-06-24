import core, json, tables

proc saveSettings*(key: string, value: string): string =
  callPrivateRPC("settings_saveSetting", %* [
    key, $value
  ])

proc getSettings*(): JsonNode =
  callPrivateRPC("settings_getSettings").parseJSON()["result"]
  # TODO: return an Table/Object instead

proc getSetting*(name: string): string =
  let settings: JsonNode = getSettings()
  result = settings{name}.getStr
