--[[ ================= STORED VARIABLES ====================== ]]
MOMENTUM_MARKS_SETTINGS = MOMENTUM_MARKS_SETTINGS or {
  ["Tanks"] = {},
  ["sync"] = true
}

--[[ ================= LOCAL VARIABLES ====================== ]]
local CoreUtils = CoreUtils
local MM = {}

--[[
  =======================
  COMMANDS

  /mom lock
  /mom unlock
  =======================
]]
SLASH_MOMENTUMMARKS1 = '/mom'
function SlashCmdList.MOMENTUMMARKS(msg)
  if (msg == 'lock') then
    MOM_UI:Lock()
  elseif (msg == 'unlock') then
    MOM_UI:Unlock()
  elseif (msg) then
    MomentumMarks_ParseTanks(msg)
  end

end

--[[ ================= CALLBACKS ====================== ]]

--[[

  Function callback for the OnLoad hook

]]
function MomentumMarks_OnLoad(self)
  if not CoreUtils.IsMomentum then return end

  self:SetScript("OnEvent", MomentumMarks_OnEvent)
  self:SetScript("OnUpdate", MomentumMarks_OnUpdate)
  self:RegisterEvent("PLAYER_ENTERING_WORLD");
  self:RegisterEvent("PLAYER_REGEN_DISABLED");
  self:RegisterEvent("PLAYER_REGEN_ENABLED");
  self:RegisterEvent("CHAT_MSG_ADDON")

  MOM_UI = MomentumMarksUI:New()
  MOM_UI:OnToggleTankSelector(MomentumMarks_OnToggleTankSelector)
  MOM_UI:OnSelectTank(MomentumMarks_OnSelectTank)
end

--[[

  Function callback for the OnUpdate hook

]]
function MomentumMarks_OnUpdate(self, sinceLastUpdate)
  self.sinceLastTargetsUpdate = (self.sinceLastTargetsUpdate or 0) + sinceLastUpdate;
  self.sinceLastBroadcast = (self.sinceLastBroadcast or 0) + sinceLastUpdate;

  if MOM_UI.MarkerGroup and MOMENTUM_MARKS_SETTINGS.Tanks and self.sinceLastTargetsUpdate >= 0.1 then
    self.sinceLastTargetsUpdate = 0;
    local targets = MomentumMarks_ScanForTargets()
    MOM_UI:SetTargets(targets)
  end
end

--[[

  Function callback for the OnEvent hook

]]
function MomentumMarks_OnEvent(self, event, prefix, message, channel, sender)
  if ( event == "PLAYER_ENTERING_WORLD" ) then
    if MOMENTUM_MARKS_SETTINGS.locked then MOM_UI:Lock() end
    if not MOMENTUM_MARKS_SETTINGS.sync then MOM_UI.TankSelectorToggle.texture:SetTexture(0.5, 0.5, 0.5) end
    if (not MomentumMarks_IsRaidLeader()) then MomentumMarks_RequestBroadcast()
    else MomentumMarks_CleanTanks() end
  end

  if ( event == "PLAYER_REGEN_DISABLED") then
    MM.Combat = true
  end

  if ( event == "PLAYER_REGEN_ENABLED") then
    MM.Combat = false
  end

  if (event == "CHAT_MSG_ADDON" and prefix == "MomentumMarks") then
    if (MOMENTUM_MARKS_SETTINGS.sync) then MomentumMarks_Recieve(event, prefix, message, sender) end
  end
end

--[[

  Function callback for the ToggleTankSelector Click event

]]
function MomentumMarks_OnToggleTankSelector()
  local button = GetMouseButtonClicked();
  if MOM_UI.TankSelector then
    if button == "RightButton" then MomentumMarks_OnToggleSync()
    elseif MOM_UI.TankSelector:IsShown() then MOM_UI.TankSelector:Hide()
    else
      MOM_UI:PopulateSelectTankFrames(MOMENTUM_MARKS_SETTINGS.Tanks)
      MOM_UI.TankSelector:Show()
    end
  end
end

function MomentumMarks_OnToggleSync()
  MOMENTUM_MARKS_SETTINGS.sync = not MOMENTUM_MARKS_SETTINGS.sync
  if not MOMENTUM_MARKS_SETTINGS.sync then MOM_UI.TankSelectorToggle.texture:SetTexture(0.5, 0.5, 0.5)
  else
    MOM_UI.TankSelectorToggle.texture:SetTexture(0, 0, 0)
    MomentumMarks_RequestBroadcast()
  end
end

--[[

  Function callback for the SelectTankFrame click event

]]
function MomentumMarks_OnSelectTank(self)
  if not MOMENTUM_MARKS_SETTINGS.Tanks[self.name] then
    MOMENTUM_MARKS_SETTINGS.Tanks[self.name] = self.name
    self.texture:SetTexture(0.5, 0.5, 0.5)
  else
    MOMENTUM_MARKS_SETTINGS.Tanks[self.name] = nil
    self.texture:SetTexture(0, 0, 0)
  end

  MomentumMarks_UpdateTanks(MOMENTUM_MARKS_SETTINGS.Tanks)
end

--[[ ================= TANKS ====================== ]]

--[[

  Function that parses the current tanks from a string of the form:

  name1 name2 name3

]]
function MomentumMarks_ParseTanks(names)
  local tanks = {}
  for name in string.gmatch(names, "[^%s]+") do
   tanks[name] = name
  end

  MomentumMarks_UpdateTanks(tanks)
end

--[[

  Function that returns true IFF you are the current raidleader

]]
function MomentumMarks_IsRaidLeader()
  local player_name = GetUnitName("player")
  local name, rank
  for i = 1, 40, 1 do
    name, rank = GetRaidRosterInfo(i);
    if name == player_name then
      return rank == 2
    end
  end

  return false
end

--[[

  Sets the current tanks, given a tables of tank names
  Also broadcasts the tanks IFF you are the raid leader

]]
function MomentumMarks_SetTanks(tanks)
  MOMENTUM_MARKS_SETTINGS.Tanks = tanks
  if (MomentumMarks_IsRaidLeader()) then MomentumMarks_Broadcast(tanks) end
end

--[[

  Function that removes any tanks that are not currently in the raid

]]
function MomentumMarks_CleanTanks()
  local names = {}
  local name
  for i = 1, 40, 1 do
    name = GetRaidRosterInfo(i)
    if name then names[name] = name end
  end

  local tanks = CoreUtils.Filter(MOMENTUM_MARKS_SETTINGS.Tanks or {}, function(name) return names[name] end)
  MomentumMarks_UpdateTanks(tanks)
end

--[[

  Function that updates the tank targets, given a table of tanks

]]
function MomentumMarks_UpdateTanks(tanks)
  MOM_UI:SetTanks(tanks)
  MomentumMarks_SetTanks(tanks)
end

--[[ ================= TARGETS ====================== ]]

--[[

  Function that scans the current tanks targets for their mark and number of player who targets that mark

]]
function MomentumMarks_ScanForTargets()
  local players = {}
  local tanks = {}

  local num_raid_members = GetRealNumRaidMembers()
	for i = 1, num_raid_members, 1 do
    local name = GetRaidRosterInfo(i)
    local unit, marker, guid

		if (name) then
      unit = "raid"..tostring(i).."target"
      if UnitExists(unit) then
        guid = UnitGUID(unit)
        marker = GetRaidTargetIndex(unit)
        if guid then
          players[guid] = (players[guid] or 0) + 1
          if MOMENTUM_MARKS_SETTINGS.Tanks[name] then
            tanks[name] = {
              ["guid"] = guid,
              ["marker"] = marker,
            }
          end
        end
      end
    end
  end

  local target
  return CoreUtils.Reduce(tanks, function(targets, tank, name)
    targets[name] = {
      ["players"] = players[tank.guid],
      ["marker"] = tank.marker
    }

    return targets
  end, {})
end

--[[ ================= COMMUNICATION ====================== ]]

--[[

  Function for broadcasting the current table of tanks

]]
function MomentumMarks_Broadcast(tanks)
  local msg = CoreUtils.Reduce(tanks, function(acc, name)
    if acc == "" then return name end

    return acc .. " " .. name
  end, "")

  SendAddonMessage("MomentumMarks", msg, "RAID")
end

--[[

  Function for requesting a broadcast of teh current tanks

]]
function MomentumMarks_RequestBroadcast()
  SendAddonMessage("MomentumMarks", "REQUEST_BROADCAST", "RAID")
end

--[[

  Function callback for receiving a message from a broadcast

]]
function MomentumMarks_Recieve(event, prefix, message, sender)
  if (prefix == "MomentumMarks") then
    if (message == "REQUEST_BROADCAST" and MomentumMarks_IsRaidLeader()) then MomentumMarks_Broadcast(MOMENTUM_MARKS_SETTINGS.Tanks)
    elseif (sender ~= UnitName("player")) then MomentumMarks_ParseTanks(message or "") end
  end
end