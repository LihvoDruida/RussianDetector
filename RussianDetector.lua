local addonName, ns = ...
local addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0")
_G.RaidAssistent = addon

local checkMembers = ns.CheckGroupMembers:new()
local settingsProvider = ns.SettingsProvider:new()
local eventHandler = ns.EventHandler:new()

local function LogMessage(message)
  print("|cFFFF7D0A<|r|cFFFFFF00" .. addonName .. "|r|cFFFF7D0A>|r " .. message)
end

local function createInterfaceOptions()
  settingsProvider:Build()

  local namespace = "RussianDetector"
  LibStub("AceConfig-3.0"):RegisterOptionsTable(namespace, ns.Options)

  local configDialogLib = LibStub("AceConfigDialog-3.0")
  configDialogLib:AddToBlizOptions(namespace, "RussianDetector", nil, "General")
  configDialogLib:AddToBlizOptions(namespace, "Причетні", "RussianDetector", "Contributors")
end

local function OnPlayerLogin()
  settingsProvider:Load()
  createInterfaceOptions()

  local enableToxicityWarning, enableLeaveGroup, enableLeaveRaid = settingsProvider.GetTranslatorsState()

  local translators = {
    { enabled = enableToxicityWarning, func = SendToxicityWarning },
    { enabled = enableLeaveGroup,      func = GroupUtils_LeaveGroup },
    { enabled = enableLeaveRaid,       func = GroupUtils_LeaveRaid },
  }

  function ProcessRussianPlayers(playerNames)
    local playerList = table.concat(playerNames, "\n")
    LogMessage("Players with Cyrillic names detected:\n" .. playerList)
    -- Check if either enableLeaveGroup or enableLeaveRaid is enabled
    local leaveGroupEnabled = false
    local leaveRaidEnabled = false
    for _, translator in ipairs(translators) do
      if translator.enabled then
        translator.func()
        if translator.func == GroupUtils_LeaveGroup then
          leaveGroupEnabled = true
        elseif translator.func == GroupUtils_LeaveRaid then
          leaveRaidEnabled = true
        end
      end
    end
    -- Call WarnRussianPlayersDetected only if the corresponding translator is enabled
    if leaveGroupEnabled or leaveRaidEnabled then
      WarnRussianPlayersDetected(playerList)
    end
  end
end

local function initializeAddon()
  if initialized then
    return
  end

  StaticPopupDialogs["ADDON_TRANSLATOR_RESET_SETTINGS"] = {
    text = "Ви впевнені, що хочете скинути всі налаштування до стандартних значень?",
    button1 = "Продовжити",
    button2 = "Скасувати",
    OnAccept = function() settingsProvider:Reset() end,
    OnShow = function() PlaySound(SOUNDKIT.RAID_WARNING) end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
  }

  function addon:OnEnable()
    self:RegisterEvent("GROUP_ROSTER_UPDATE", checkMembers.CheckGroupMembers)
    LogMessage("Addon activated.")
  end
end

local function OnAddOnLoaded(_, name)
  if name == addonName then
    initializeAddon()
    if not IsLoggedIn() then
      eventHandler:Register(OnPlayerLogin, "PLAYER_LOGIN")
    else
      OnPlayerLogin()
    end
  end
end

eventHandler:Register(OnAddOnLoaded, "ADDON_LOADED")
