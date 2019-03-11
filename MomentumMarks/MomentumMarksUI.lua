MOMENTUM_MARKS_UI_SETTINGS = MOMENTUM_MARKS_UI_SETTINGS or {
  ["locked"] = false,
}

local CoreUtils = CoreUtils

--[[ ================= CREATE ====================== ]]

local function MomentumMarksUI_OnStartMoving(self)
  if not MOMENTUM_MARKS_UI_SETTINGS.locked then
    self:StartMoving()
  end
end

local function MomentumMarksUI_OnStopMovingOrSizing(self)
  if not MOMENTUM_MARKS_UI_SETTINGS.locked then
    self:StopMovingOrSizing()
  end
end

--[[
  Function for creating the group, containing all of the marks (Action Buttons)
]]
local function MomentumMarksUI_CreateGroup()
  local group = CreateFrame("Frame", "MarkerGroup", UIParent)
  group:SetMovable(true)
  group:EnableMouse(true)
  group:RegisterForDrag("LeftButton")
  group:SetClampedToScreen(true)
  group:SetPoint("CENTER");
  group:SetWidth(400);
  group:SetHeight(64);
  group:SetUserPlaced(true)
  group.texture = group:CreateTexture("ARTWORK");
  group.texture:SetAllPoints();
  group.texture:SetTexture(1.0, 0.5, 0);
  group.texture:SetAlpha(0.5);
  group:SetMovable(true)
  group:EnableMouse(true)
  group:RegisterForDrag("LeftButton")
  group:SetScript("OnDragStart", MomentumMarksUI_OnStartMoving)
  group:SetScript("OnDragStop", MomentumMarksUI_OnStopMovingOrSizing)
  return group
end

--[[
  Function for creating the group, containing all of the marks (Action Buttons)
]]
local function MomentumMarksUI_CreateTankSelector()
  local tank_selector = CreateFrame("Frame", "TankSelector", UIParent)
  tank_selector:SetMovable(true)
  tank_selector:EnableMouse(true)
  tank_selector:RegisterForDrag("LeftButton")
  tank_selector:SetClampedToScreen(true)
  tank_selector:SetPoint("CENTER");
  tank_selector:SetWidth(670);
  tank_selector:SetHeight(180);
  tank_selector:SetUserPlaced(true)
  tank_selector.texture = tank_selector:CreateTexture("ARTWORK");
  tank_selector.texture:SetAllPoints();
  tank_selector.texture:SetTexture(1.0, 0.5, 0);
  tank_selector.texture:SetAlpha(0.5);
  tank_selector:SetMovable(true)
  tank_selector:RegisterForDrag("LeftButton")
  tank_selector:SetScript("OnDragStart", MomentumMarksUI_OnStartMoving)
  tank_selector:SetScript("OnDragStop", MomentumMarksUI_OnStopMovingOrSizing)
  tank_selector:Hide()
  return tank_selector
end

--[[
  Function for creating the group, containing all of the marks (Action Buttons)
]]
local function MomentumMarksUI_CreateTankSelectorFrames(tank_selector)
  local tank_frames = {}
  local x_offset, y_offset
  for i = 1, 40, 1 do
    x_offset = (math.floor((i - 1) / 5) * 80) + 15
    y_offset = (((i - 1) % 5) * -30) - 15
    local frame = CreateFrame("Button", "TankSelectorFrame", tank_selector)
    frame:SetPoint("TOPLEFT", tank_selector, "TOPLEFT", x_offset, y_offset)
    frame:EnableMouse(true)
    frame:SetWidth(80);
    frame:SetHeight(30);
    frame.texture = frame:CreateTexture("ARTWORK");
    frame.texture:SetAllPoints();
    frame.texture:SetTexture(0, 0, 0);
    frame.texture:SetAlpha(1);
    frame.text = frame:CreateFontString()
    frame.text:SetFont("Fonts/FRIZQT__.TTF", 10)
    frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.text:SetText("")
    tank_frames[i] = frame
  end

  return tank_frames
end

--[[
  Function for creating the group, containing all of the marks (Action Buttons)
]]
local function MomentumMarksUI_CreateTankSelectorToggle()
  local tank_selector_toggle = CreateFrame("Button", "TankSelectorToggle", UIParent)
  tank_selector_toggle:SetMovable(true)
  tank_selector_toggle:EnableMouse(true)
  tank_selector_toggle:RegisterForDrag("LeftButton")
  tank_selector_toggle:SetClampedToScreen(true)
  tank_selector_toggle:SetPoint("CENTER");
  tank_selector_toggle:SetWidth(64);
  tank_selector_toggle:SetHeight(20);
  tank_selector_toggle:SetUserPlaced(true)
  tank_selector_toggle.texture = tank_selector_toggle:CreateTexture("ARTWORK");
  tank_selector_toggle.texture:SetAllPoints();
  tank_selector_toggle.texture:SetTexture(0, 0, 0);
  tank_selector_toggle.texture:SetAlpha(1);
  tank_selector_toggle:SetMovable(true)
  tank_selector_toggle:EnableMouse(true)
  tank_selector_toggle:RegisterForDrag("LeftButton")
  tank_selector_toggle:SetScript("OnDragStart", MomentumMarksUI_OnStartMoving)
  tank_selector_toggle:SetScript("OnDragStop", MomentumMarksUI_OnStopMovingOrSizing)

  local text = tank_selector_toggle:CreateFontString()
	text:SetFont("Fonts/FRIZQT__.TTF", 12)
	text:SetPoint("CENTER", tank_selector_toggle, "CENTER", 0, 0)
  text:SetText("TANKS")

  return tank_selector_toggle
end

--[[
  Function for an ActionButton for a specific mark index (1-8) and raidIndex (1-40)
  Also adds the ActionButton to the given group frame
]]
local function MomentumMarksUI_CreateActionButtonForTank(tankIdx, group)
  local name = "MomentumMarksUI_Tank_" .. tankIdx
  local x_offset = (10 + 40) * (tankIdx - 1)

  local btn = CreateFrame("Button", name, group, "SecureActionButtonTemplate")
  btn:SetHeight(40)
  btn:SetWidth(40)
  btn:SetPoint("TOPLEFT", group, "TOPLEFT", x_offset, -2)
  btn:EnableMouse(true)
  btn:SetAttribute("type1", "macro") -- left click causes macro
  btn:SetAttribute("macrotext1", "") -- text for macro on left click

  return btn
end

local function MomentumMarksUI_CreateTextForButton(btn)
  local text = btn:CreateFontString()
	text:SetFont("Fonts/FRIZQT__.TTF", 12)
	text:SetPoint("BOTTOM", btn, "BOTTOM", 7, -20)
  text:SetText("")
  btn:SetFontString(text)
  return text
end

local function MomentumMarksUI_CreateMarkerForTank(tankIdx, btn)
  icon_name = icon_name or "MomentumMarksUI_Unit_Icon_" .. tankIdx
  local marker = btn:CreateTexture(icon_name, "BACKGROUND")
  marker:SetWidth(40)
  marker:SetHeight(40)
  marker:SetPoint("TOPLEFT", 7, -6)
  marker:SetAlpha(0);
  return marker
end

local function MomentumMarksUI_CreateTextures()
  local indexes = CoreUtils.Range(1, 8)
  local textures = CoreUtils.Map(indexes, function(idx)
    return "Interface/TARGETINGFRAME/UI-RaidTargetingIcon_" .. idx
  end)

  textures["unmarked"] = "Interface\\Icons\\INV_Sword_39"
  textures["none"] = "Interface\\Icons\\INV_Helmet_09"

  return textures
end

function MomentumMarksUI_UpdateTargetTexture(tank_target, target)
  if not target then
    tank_target.marker:SetTexture(tank_target.textures["none"])
    tank_target.marker:SetAlpha(0.3)
  elseif (target.marker) then
    tank_target.marker:SetTexture(tank_target.textures[target.marker])
    tank_target.marker:SetAlpha(1)
  else
    tank_target.marker:SetTexture(tank_target.textures["unmarked"])
    tank_target.marker:SetAlpha(1)
  end
end

function MomentumMarksUI_UpdateTargetPlayers(tank_target, target)
  if target then tank_target.text:SetText(tostring(target.players))
  else tank_target.text:SetText("") end
end

--[[ ================= EXPORT ====================== ]]

local MomentumMarksUI = { MarkerGroup = nil, TankSelector = nil, TankSelectorToggle = nil}

function MomentumMarksUI:New()
  local q = q or {}
  setmetatable(q, self)
  self.__index = self
  self.MarkerGroup = MomentumMarksUI_CreateGroup()
  self.TankSelector = MomentumMarksUI_CreateTankSelector()
  self.TankSelectorToggle = MomentumMarksUI_CreateTankSelectorToggle()
  self.TankSelector.tank_frames = MomentumMarksUI_CreateTankSelectorFrames(self.TankSelector)

  local tank_targets = {}
  for i = 1, 8, 1 do
    tank_targets[i] = {}
    tank_targets[i].btn = MomentumMarksUI_CreateActionButtonForTank(i, self.MarkerGroup)
    tank_targets[i].marker = MomentumMarksUI_CreateMarkerForTank(i, tank_targets[i].btn)
    tank_targets[i].text = MomentumMarksUI_CreateTextForButton(tank_targets[i].btn)
    tank_targets[i].textures = MomentumMarksUI_CreateTextures()
  end

  self.MarkerGroup.tank_targets = tank_targets

  return q
end

function MomentumMarksUI:Lock()
  MOMENTUM_MARKS_UI_SETTINGS.locked = true
  self.MarkerGroup.texture:SetAlpha(0);
  self.TankSelector.texture:SetAlpha(0);

  self.TankSelector:Hide()
  self.TankSelectorToggle.texture:SetTexture(0, 0, 0)
end

function MomentumMarksUI:Unlock()
  MOMENTUM_MARKS_UI_SETTINGS.locked = false
  self.MarkerGroup.texture:SetAlpha(0.5);
  self.TankSelector.texture:SetAlpha(0.5);

  self.TankSelector:Show()
  self.TankSelectorToggle.texture:SetTexture(1.0, 0.5, 0)
end

function MomentumMarksUI:OnToggleTankSelector(cb)
  self.TankSelectorToggle:SetScript("OnClick", cb)
end

function MomentumMarksUI:OnSelectTank(cb)
  CoreUtils.Map(self.TankSelector.tank_frames, function(tank_frame)
    tank_frame:SetScript("OnClick", cb)
  end)
end

function MomentumMarksUI:SetTanks(tanks)
  local values = CoreUtils.Values(tanks)
  self.MarkerGroup.tank_targets = CoreUtils.Map(self.MarkerGroup.tank_targets, function(tank_target, i)
    -- clear current tank
    tank_target.btn:SetAttribute("assist", nil)
    tank_target.tank_name = nil
    tank_target.btn:Hide()

    if values[i] then
      -- assign tank to tank_target
      tank_target.btn:SetAttribute("macrotext1", "/assist " .. tanks[values[i]]) -- text for macro on left click
      tank_target.tank_name = values[i]
      tank_target.btn:Show()
    end
    return tank_target
  end)
end

function MomentumMarksUI:SetTargets(targets)
  if not self.MarkerGroup then return end

  local target, marker
  CoreUtils.Map(self.MarkerGroup.tank_targets, function(tank_target)
    if not tank_target.tank_name then return end
    target = targets[tank_target.tank_name]
    MomentumMarksUI_UpdateTargetTexture(tank_target, target)
    MomentumMarksUI_UpdateTargetPlayers(tank_target, target)
  end)
end

function MomentumMarksUI:PopulateSelectTankFrames(tanks)
  local name, color, frame, classFileName, _
  for i = 1, 40, 1 do
    frame = self.TankSelector.tank_frames[i]
    name = GetRaidRosterInfo(i)
    _, classFileName = UnitClass("raid" .. i)
    color = RAID_CLASS_COLORS[classFileName]
    if (name) then
      frame.name = name
      frame.text:SetText(name)
      frame.text:SetTextColor(color.r, color.g, color.b)

      if tanks[name] then frame.texture:SetTexture(0.5, 0.5, 0.5)
      else frame.texture:SetTexture(0, 0, 0) end
    else
      frame.name = nil
      frame.text:SetTextColor(0, 0, 0)
    end
  end
end

if CoreUtils.IsMomentum() then MOM_UI = MomentumMarksUI:New() end