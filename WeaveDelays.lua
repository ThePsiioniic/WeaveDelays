local WeaveDelays = {}

WeaveDelays.name                = 'WeaveDelays'
WeaveDelays.slash               = "/weavedelays"
WeaveDelays.version             = 0.2
WeaveDelays.DefaultSavedVars    = {savedRuns = {}}
WeaveDelays.displayTimeMax      = 999
WeaveDelays.displayTimeMin      = -99
WeaveDelays.historySize 	    = 99999
WeaveDelays.historySizeInCombat = 5
WeaveDelays.numSlots            = 6
WeaveDelays.slotOffset          = 2

WeaveDelays.inCombat           = false
WeaveDelays.lastLAtime 	       = 0
WeaveDelays.lastSkillStartTime = 0
WeaveDelays.lastSkillEndTime   = 0
WeaveDelays.lastSkillSlotId    = 0
WeaveDelays.lastSkillBarIdx    = 0
WeaveDelays.skillBarIdx        = 0
WeaveDelays.skillBarIdx0Id     = -1
WeaveDelays.skillsSinceLastLA  = 0
WeaveDelays.banditsFound       = false

WeaveDelays.controlLabelFont           = "ZoFontGameSmall"
WeaveDelays.controlWarningLabelOffsetX = 0.6
WeaveDelays.controlBoxHeight           = 0.33
WeaveDelays.controlBoxWidth            = 0.95
WeaveDelays.controlTopLabelOffsetY     = -3
WeaveDelays.controlWarningLabelOffsetY = -4

WeaveDelays.frontBarSkills = {}
WeaveDelays.backBarSkills = {}

WeaveDelays.displayMode = 1
WeaveDelays.maxMode = 4
WeaveDelays.windowShow = false

function WeaveDelays.Reset()
	WeaveDelays.log.reset()
	WeaveDelays.frontBarSkills = {}
	WeaveDelays.backBarSkills = {}
end

WeaveDelaysInterface = WeaveDelaysInterface or {}

function WeaveDelaysInterface.ToggleWindow()
	WeaveDelays.ToggleWindow()
end
function WeaveDelaysInterface.ToggleMode()
	WeaveDelays.ToggleMode()
end

function WeaveDelays.ToggleWindow()
	WeaveDelays.windowShow = not WeaveDelays.windowShow
	WEAVEDELAYSUI:SetHidden(not WeaveDelays.windowShow)
	if WeaveDelays.windowShow then
		WeaveDelays.UpdateReport()
	end
end

function WeaveDelays.ToggleMode()
	WeaveDelays.displayMode = WeaveDelays.displayMode +1
	if WeaveDelays.displayMode > WeaveDelays.maxMode then
		WeaveDelays.displayMode = 1
	end
	if WeaveDelays.windowShow then
		WeaveDelays.UpdateReport()
	end
end

function WeaveDelays.SetColor(c, s, n)
	if c ~= nil then
		if n > 0 then
			if s > 500 then
				c:SetColor(1.0,0.0,0.0,1.0)
			elseif s > 300 then
				c:SetColor(0.8,0.2,0.0,1.0)
			elseif s > 200 then
				c:SetColor(0.8,0.6,0.2,1.0)
			elseif s > 150 then
				c:SetColor(0.7,0.7,0.2,1.0)
			elseif s > 100 then
				c:SetColor(0.4,0.9,0.2,1.0)
			elseif s > 70 then
				c:SetColor(0.3,1.0,0.0,1.0)
			elseif s > 50 then
				c:SetColor(0.1,1.0,0.4,1.0)
			elseif s > -50 then
				c:SetColor(0.0,1.0,1.0,1.0)
			elseif s > -150 then
				c:SetColor(1.0,0.0,1.0,1.0)
			else
				c:SetColor(1.0,1.0,1.0,0.2)
			end
		elseif c == -1 then
			c:SetColor(0.8,0.8,0.8,0.4)
		else
			c:SetColor(1.0,1.0,1.0,0.2)
		end
	end
end

function WeaveDelays.SetColorN(c, s)
	if c ~= nil then
		if s > 20 then
			c:SetColor(1.0,0.0,0.0,1.0)
		elseif s > 10 then
			c:SetColor(0.8,0.2,0.0,1.0)
		elseif s > 5 then
			c:SetColor(0.8,0.6,0.2,1.0)
		elseif s > 4 then
			c:SetColor(0.7,0.7,0.2,1.0)
		elseif s > 3 then
			c:SetColor(0.4,0.9,0.2,1.0)
		elseif s > 1 then
			c:SetColor(0.3,1.0,0.0,1.0)
		elseif s > 0 then
			c:SetColor(0.1,1.0,0.4,1.0)
		elseif s == 0 then
			c:SetColor(0.1,0.2,0.8,0.3)
		else
			c:SetColor(0.8,0.8,0.8,0.4)
		end
	end
end

function WeaveDelays.ClipRange(s, s_min, s_max)
	return math.max(math.min(s, s_max), s_min)
end

function WeaveDelays.FormatTimeMilliseconds(timeMilliseconds)
	return ""..math.floor(timeMilliseconds)
end

function WeaveDelays.Update()
	
	local historySize = WeaveDelays.historySize
	if WeaveDelays.inCombat then
		historySize = WeaveDelays.historySizeInCombat
    end
	
	local activeBarIndex = WeaveDelays.log.getActiveBarIndex()
	for i = 1, WeaveDelays.numSlots do
	
		local v, n = WeaveDelays.log.getMeanDelaySinceLastSkill(activeBarIndex, WeaveDelays.slotOffset+i, historySize)
		local s = WeaveDelays.ClipRange(v, WeaveDelays.displayTimeMin, WeaveDelays.displayTimeMax)
		WeaveDelays.slotBottomLabel[i]:SetText(WeaveDelays.FormatTimeMilliseconds(s))
		WeaveDelays.SetColor(WeaveDelays.slotBottomBar[i], s, n)
		
		v, n = WeaveDelays.log.getMeanDelaySinceLastLightAttack(activeBarIndex, WeaveDelays.slotOffset+i, historySize)
		s = WeaveDelays.ClipRange(v, WeaveDelays.displayTimeMin, WeaveDelays.displayTimeMax)
		WeaveDelays.slotTopLabel[i]:SetText(WeaveDelays.FormatTimeMilliseconds(s))
		WeaveDelays.SetColor(WeaveDelays.slotTopBar[i], s, n)
		
		WeaveDelays.slotTopWarningLabel[i]:SetText(""..WeaveDelays.log.getMissedLightAttacksBefore(activeBarIndex, WeaveDelays.slotOffset+i, historySize))
		WeaveDelays.slotBottomWarningLabel[i]:SetText(""..WeaveDelays.log.getMissedLightAttacksAfter(activeBarIndex, WeaveDelays.slotOffset+i, historySize))

	end
end

function WeaveDelays.UpdateReport()
	local parentControl = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSUIBG')
	for i = 0,5 do
		if WeaveDelays.frontBarSkills[i+1] ~= nil then
			local ctl = WINDOW_MANAGER:GetControlByName("WEAVEDELAYSUI_GRID_TOP_HEADER_"..(i+1))
			ctl:SetTexture(WeaveDelays.GetTextureFromAbilityId(WeaveDelays.frontBarSkills[i+1]))
		end
	end
	for i = 6,11 do
		if WeaveDelays.backBarSkills[i-5] ~= nil then
			local ctl = WINDOW_MANAGER:GetControlByName("WEAVEDELAYSUI_GRID_TOP_HEADER_"..(i+1))
			ctl:SetTexture(WeaveDelays.GetTextureFromAbilityId(WeaveDelays.backBarSkills[i-5]))
		end
	end
	for i = 0,5 do
		if WeaveDelays.frontBarSkills[i+1] ~= nil then
			local ctl = WINDOW_MANAGER:GetControlByName("WEAVEDELAYSUI_GRID_LEFT_HEADER_"..(i+1))
			ctl:SetTexture(WeaveDelays.GetTextureFromAbilityId(WeaveDelays.frontBarSkills[i+1]))
		end
	end
	for i = 6,11 do
		if WeaveDelays.backBarSkills[i-5] ~= nil then
			local ctl = WINDOW_MANAGER:GetControlByName("WEAVEDELAYSUI_GRID_LEFT_HEADER_"..(i+1))
			ctl:SetTexture(WeaveDelays.GetTextureFromAbilityId(WeaveDelays.backBarSkills[i-5]))
		end
	end
	
	local nMax = 0
	
	for i = 1,12 do
		for j = 1,12 do
			local lbl = WINDOW_MANAGER:GetControlByName("WEAVEDELAYSUI_LABEL_"..i.."_"..j)
			local ctl = WINDOW_MANAGER:GetControlByName("WEAVEDELAYSUI_GRID_"..i.."_"..j)
			
			if WeaveDelays.displayMode == 1 then
				local delta = WeaveDelays.log.getDelayS1_x_S2(j,i)
				if delta ~= nil then
					lbl:SetText(WeaveDelays.FormatTimeMilliseconds(delta))
					WeaveDelays.SetColor(ctl, delta, 1)
				else
					lbl:SetText("")
					WeaveDelays.SetColor(ctl, 0, -1)
				end
			elseif WeaveDelays.displayMode == 2 then
				local delta = WeaveDelays.log.getTransitionsS1_x_S2(j,i)
				if delta ~= nil and delta > 0  then
					lbl:SetText(WeaveDelays.FormatTimeMilliseconds(delta))
					WeaveDelays.SetColorN(ctl, delta)
				else
					lbl:SetText("")
					WeaveDelays.SetColorN(ctl, -1)
				end
			elseif WeaveDelays.displayMode == 3 then
				local delta = WeaveDelays.log.getMissingLightAttacksS1_x_S2(j,i)
				if delta ~= nil and delta > -1  then
					lbl:SetText(WeaveDelays.FormatTimeMilliseconds(delta))
					WeaveDelays.SetColorN(ctl, delta)
				else
					lbl:SetText("")
					WeaveDelays.SetColorN(ctl, -1)
				end
			elseif WeaveDelays.displayMode == 4 then
			
				local m = WeaveDelays.log.getMissingLightAttacksS1_x_S2(j,i)
				local c = WeaveDelays.log.getTransitionsS1_x_S2(j,i)
				local r = 0
				if c > 0 then
					r = math.floor(100*m/c)
				end
				if r ~= nil and c > 0 and r > 0 and r < 101  then
					lbl:SetText(WeaveDelays.FormatTimeMilliseconds(r))
					WeaveDelays.SetColorN(ctl, r)
				else
					lbl:SetText("")
					WeaveDelays.SetColorN(ctl, -1)
				end
			else
				lbl:SetText("")
				lbl:SetText("")
				WeaveDelays.SetColor(ctl, 0, -1)
			end
		end
	end
			
	local lbl = WINDOW_MANAGER:GetControlByName("WEAVEDELAYSUI_HEADER_LABEL")
	if WeaveDelays.displayMode == 1 then
		lbl:SetText("T")
	elseif WeaveDelays.displayMode == 2 then
		lbl:SetText("C")
	elseif WeaveDelays.displayMode == 3 then
		lbl:SetText("M")
	elseif WeaveDelays.displayMode == 4 then
		lbl:SetText("R")
	end
	
	
end

function WeaveDelays.playerActionSlotAbilityUsed(e, slotId)
	WeaveDelays.log.slotUsed(slotId)
	WeaveDelays.Update()
end

function  WeaveDelays.OnWeaponSwap(_, activeWeaponPair, locked)
	WeaveDelays.log.weaponSwap(activeWeaponPair)
	WeaveDelays.Update()
	if activeWeaponPair == 1 and #WeaveDelays.frontBarSkills < 1 then
		for i=0,5 do
			table.insert(WeaveDelays.frontBarSkills, GetSlotBoundId(3+i))
		end
	elseif activeWeaponPair == 2 and #WeaveDelays.backBarSkills < 1 then
		for i=0,5 do
			table.insert(WeaveDelays.backBarSkills, GetSlotBoundId(3+i))
		end
	end
end

function WeaveDelays.OnPlayerCombatState(event, inCombat)
	if inCombat and not WeaveDelays.inCombat then
		WeaveDelays.inCombat = inCombat
		WeaveDelays.Reset()
		WeaveDelays.Update()
	elseif not inCombat and WeaveDelays.inCombat then
		WeaveDelays.inCombat = inCombat
		WeaveDelays.Update()
		WeaveDelays.log.analyze()
		WeaveDelays.UpdateReport()
		
	end
end

function WeaveDelays.GetAbilityIndexFromAbilityId(abilityId)
    local hasProgression, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
    if hasProgression then
		local _, morph, rank = GetAbilityProgressionInfo(progressionIndex)
        local name, texture, abilityIndex = GetAbilityProgressionAbilityInfo(progressionIndex, morph, rank)
		return abilityIndex
	else
	    return 0
    end
end

function WeaveDelays.GetTextureFromAbilityId(abilityId)
    local hasProgression, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
    if hasProgression then
		local _, morph, rank = GetAbilityProgressionInfo(progressionIndex)
        local name, texture, abilityIndex = GetAbilityProgressionAbilityInfo(progressionIndex, morph, rank)
		return texture
	else
	    return 0
    end
end

function WeaveDelays:Initialize()
	-- Saved Vars
	WeaveDelays.savedVariables = ZO_SavedVars:New("WeaveDelaysSettings", 1, nil, WeaveDelays.DefaultSavedVars)

	WeaveDelays.log = WeaveDelayLog.new()
	WeaveDelays.log.reset()
	
	-- Events
	EVENT_MANAGER:RegisterForEvent(WeaveDelays.name.."playerActionSlotAbilityUsed", EVENT_ACTION_SLOT_ABILITY_USED, WeaveDelays.playerActionSlotAbilityUsed)
	EVENT_MANAGER:RegisterForEvent(WeaveDelays.name.."WeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, WeaveDelays.OnWeaponSwap)
	EVENT_MANAGER:RegisterForEvent(WeaveDelays.name.."PlayerCombatState", EVENT_PLAYER_COMBAT_STATE, WeaveDelays.OnPlayerCombatState)

	-- Controls
	WeaveDelays.slotTopBar = {}
	WeaveDelays.slotBottomBar = {}
	WeaveDelays.slotTopLabel = {}
	WeaveDelays.slotTopWarningLabel = {}
	WeaveDelays.slotBottomLabel = {}
	WeaveDelays.slotBottomWarningLabel = {}
	
	-- shift top bar if bandits is found
	if BUI and BUI.Vars then
		WeaveDelays.banditsFound = true
	end
	local topBarOffsetHeight = 0
	if WeaveDelays.banditsFound then
		local slot = ZO_ActionBar_GetButton(3).slot
		local width,height = slot:GetDimensions()
		topBarOffsetHeight = -height/2
	end
	
	for i = 1, WeaveDelays.numSlots do
		local slot = ZO_ActionBar_GetButton(WeaveDelays.slotOffset+i).slot
		
		local width,height = slot:GetDimensions()
		height = height * WeaveDelays.controlBoxHeight
		width  = width  * WeaveDelays.controlBoxWidth
		local drawTier = DT_HIGH
		local drawLevel = 5
		local t1 = WINDOW_MANAGER:CreateControl(nil, slot, CT_TEXTURE)
		t1:SetDimensions(width, height)
		t1:SetDrawTier(drawTier)
		t1:SetDrawLayer(drawLevel)
		t1:SetColor(1.0,1.0,1.0,0.2)
		t1:SetAnchor(BOTTOMLEFT, slot,TOPLEFT,0,topBarOffsetHeight-1)
		table.insert(WeaveDelays.slotTopBar, t1)
		
		local b1 = WINDOW_MANAGER:CreateControl(nil, slot, CT_TEXTURE)
		b1:SetDimensions(width, height)
		b1:SetDrawTier(drawTier)
		b1:SetDrawLayer(drawLevel)
		b1:SetColor(1.0,1.0,1.0,0.2)
		b1:SetAnchor(TOPLEFT,slot,BOTTOMLEFT,0,1)
		table.insert(WeaveDelays.slotBottomBar, b1)
		
		local lt1 =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		lt1:SetFont(WeaveDelays.controlLabelFont)
		lt1:SetDimensions(width, height)
		lt1:SetDrawTier(drawTier)
		lt1:SetDrawLayer(drawLevel+1)
		lt1:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,1,topBarOffsetHeight+WeaveDelays.controlTopLabelOffsetY)
		table.insert(WeaveDelays.slotTopLabel, lt1)
		
		local lb1 = WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		lb1:SetDimensions(width, height)
		lb1:SetFont(WeaveDelays.controlLabelFont)
		lb1:SetDrawTier(drawTier)
		lb1:SetDrawLayer(drawLevel+1)
		lb1:SetAnchor(TOPLEFT,slot,BOTTOMLEFT,1,-2)
		table.insert(WeaveDelays.slotBottomLabel, lb1)
		
		local ltw1 =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		ltw1:SetFont(WeaveDelays.controlLabelFont)
		ltw1:SetDimensions(width*(1.0-WeaveDelays.controlWarningLabelOffsetX), height)
		ltw1:SetDrawTier(drawTier)
		ltw1:SetDrawLayer(drawLevel+1)
		ltw1:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,width*WeaveDelays.controlWarningLabelOffsetX,topBarOffsetHeight+WeaveDelays.controlWarningLabelOffsetY)
		table.insert(WeaveDelays.slotTopWarningLabel, ltw1)
		
		local lbw1 =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		lbw1:SetFont(WeaveDelays.controlLabelFont)
		lbw1:SetDimensions(width*(1.0-WeaveDelays.controlWarningLabelOffsetX), height)
		lbw1:SetDrawTier(drawTier)
		lbw1:SetDrawLayer(drawLevel+1)
		lbw1:SetAnchor(TOPLEFT,slot,BOTTOMLEFT,width*WeaveDelays.controlWarningLabelOffsetX,-2)
		table.insert(WeaveDelays.slotBottomWarningLabel, lbw1)
		
	end
	
	d(GetSlotBoundId(3),WeaveDelays.GetTextureFromAbilityId(GetSlotBoundId(3)))
	--WINDOW_MANAGER:GetControlByName('WEAVEDELAYSUIx00'):SetNormalTexture(WeaveDelays.GetTextureFromAbilityId(GetSlotBoundId(3)))
	--WINDOW_MANAGER:GetControlByName('WEAVEDELAYSUIx01'):SetNormalTexture(WeaveDelays.GetTextureFromAbilityId(GetSlotBoundId(4)))
	--WINDOW_MANAGER:GetControlByName('WEAVEDELAYSUIx02'):SetNormalTexture(WeaveDelays.GetTextureFromAbilityId(GetSlotBoundId(5)))
	
	local parentControl = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSUIBG')
	for i = 0,12 do		
		local ctl = WINDOW_MANAGER:CreateControl("WEAVEDELAYSUI_GRID_TOP_HEADER_"..i, parentControl, CT_TEXTURE)
		ctl:SetDimensions(32, 32)
		ctl:SetDrawTier(2)
		ctl:SetDrawLayer(5)
		ctl:SetAlpha(0.8)
		ctl:SetAnchor(TOPLEFT, parentControl, TOPLEFT, 5+i*35, 5)
	end
	for i = 1,12 do		
		local ctl = WINDOW_MANAGER:CreateControl("WEAVEDELAYSUI_GRID_LEFT_HEADER_"..i, parentControl, CT_TEXTURE)
		ctl:SetDimensions(32, 32)
		ctl:SetDrawTier(2)
		ctl:SetDrawLayer(5)
		ctl:SetAlpha(0.8)
		ctl:SetAnchor(TOPLEFT, parentControl, TOPLEFT, 5, 5+i*35)
	end
	
	local lbl = WINDOW_MANAGER:CreateControl("WEAVEDELAYSUI_HEADER_LABEL", parentControl, CT_LABEL)
	lbl:SetFont(WeaveDelays.controlLabelFont)
	lbl:SetColor(0.2,0.2,0.2,0.8)
	lbl:SetDimensions(32, 32)
	lbl:SetDrawTier(2)
	lbl:SetDrawLayer(6)
	lbl:SetAnchor(TOPLEFT, parentControl, TOPLEFT, 10, 10)
			
	for i = 1,12 do	
		for j = 1,12 do
			local ctl = WINDOW_MANAGER:CreateControl("WEAVEDELAYSUI_GRID_"..i.."_"..j, parentControl, CT_TEXTURE)
			ctl:SetDimensions(32, 32)
			ctl:SetDrawTier(2)
			ctl:SetDrawLayer(5)
			ctl:SetColor(0.8,0.8,0.8,0.4)
			ctl:SetAnchor(TOPLEFT, parentControl, TOPLEFT, 5+j*35, 5+i*35)
			local lbl = WINDOW_MANAGER:CreateControl("WEAVEDELAYSUI_LABEL_"..i.."_"..j, parentControl, CT_LABEL)
			lbl:SetFont(WeaveDelays.controlLabelFont)
			lbl:SetDimensions(32, 32)
			lbl:SetDrawTier(2)
			lbl:SetDrawLayer(6)
			lbl:SetAnchor(TOPLEFT, parentControl, TOPLEFT, 10+j*35, 10+i*35)
		end
	end
	
	
	ZO_CreateStringId("SI_BINDING_NAME_WD_TOGGLE", "Toggle WeaveDelays window")
	ZO_CreateStringId("SI_BINDING_NAME_WD_TOGGLE_MODE", "Toggle WeaveDelays mode")
	
end

function WeaveDelays.OnAddOnLoaded(eventCode, addonName)
	if addonName == "BanditsUserInterface" then
		WeaveDelays.banditsFound = true
	end
	
	if addonName == WeaveDelays.name then
		WeaveDelays:Initialize()
		EVENT_MANAGER:UnregisterForEvent(WeaveDelays.name, EVENT_ADD_ON_LOADED)
	end
end



--function WeaveDelays.MoveUI()
--	local x, y = WEAVEDELAYSUI:GetCenter()
--	WEAVEDELAYSUI:ClearAnchors()
--	WEAVEDELAYSUI:SetAnchor(CENTER, GuiRoot, TOPLEFT, x, y)
--end


SLASH_COMMANDS[WeaveDelays.slash] = function (cmd)
    local commands = {}
    local index = 1
	local num = 0
	
    for i in string.gmatch(cmd, "%S+") do
        if (i ~= nil and i ~= "") then
            commands[index] = i
            index = index + 1
        end
    end

    if #commands == 0 then
        return CHAT_SYSTEM:AddMessage("Please enter a valid command")
    end

    if #commands == 1 then
		if commands[1] == "reset" then
			WeaveDelays.Reset()
		elseif commands[1] == "update" then
			WeaveDelays.Update()
			WeaveDelays.UpdateReport()
		end
	end
end

EVENT_MANAGER:RegisterForEvent(WeaveDelays.name, EVENT_ADD_ON_LOADED, WeaveDelays.OnAddOnLoaded)
