local WeaveDelays = {}

WeaveDelays.name                = 'WeaveDelays'
WeaveDelays.slash               = "/weavedelays"
WeaveDelays.version             = 0.3
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
WeaveDelays.controlRightLabelOffsetX = 0.6
WeaveDelays.controlBoxHeight           = 0.33
WeaveDelays.controlBoxWidth            = 0.95
WeaveDelays.controlTopLabelOffsetY     = -3
WeaveDelays.controlRightLabelOffsetY = -4

WeaveDelays.frontBarSkills = {}
WeaveDelays.backBarSkills = {}

WeaveDelays.displayMode = 1
WeaveDelays.maxMode = 5
WeaveDelays.windowShow = false

WeaveDelays.palettes = {
	["uptime"] = {
		[1] = {0,         0, 1.0, 1.0},
		[2] = {80.0,   60.0, 1.0, 1.0},
		[3] = {101.0, 180.0, 1.0, 1.0}
	},
	["delay"] = {
		[1] = {-500, 180.0, 1.0, 1.0},
		[2] = {0,    150.0, 1.0, 1.0},
		[3] = {100,  90.0, 1.0, 1.0},
		[4] = {200,  60.0, 1.0, 1.0},
		[5] = {300,  33.0, 1.0, 1.0},
		[6] = {400,  18.0, 1.0, 1.0},
		[7] = {800,  10.0, 1.0, 1.0},
		[8] = {9999,  0.0, 1.0, 1.0}
	}
}
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

function WeaveDelays.SetColor(c, delay, n)
	if c ~= nil then
		if n > 0 then
			local h,s,v = WeaveDelays.GetPaletteColor(WeaveDelays.palettes["delay"], delay)
			local r,g,b = HSVToRGB(h,s,v)
			c:SetColor(r, g, b, 1.0)
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

function WeaveDelays.GetPaletteColor(p, v)
	local nPoints = #p
	for i=1,nPoints-1 do
		if v > p[i][1] and v <= p[i+1][1] then
			local r = (v-p[i][1])/(p[i+1][1]-p[i][1])
			return p[i][2]+r*(p[i+1][2]-p[i][2]),p[i][3]+r*(p[i+1][3]-p[i][3]),p[i][4]+r*(p[i+1][4]-p[i][4])
		end
	end
	return 0,0,0
end

function WeaveDelays.SetColorR(c, s)
	--WeaveDelays.palettes[paletteName]
	if c ~= nil then
		if s > 0 then
			local h,s,v = WeaveDelays.GetPaletteColor(WeaveDelays.palettes["uptime"], s)
			local r,g,b = HSVToRGB(h,s,v)
			c:SetColor(r,g,b,1.0)
		else
			c:SetColor(0.8,0.8,0.8,0.4)
		end
	end
end

function HSVToRGB(h,s,v)
	if s == 0 then
		return v
	end
	local c = math.floor( h / 60 );
	local d = ( h / 60 ) - c;
	local p = v * ( 1 - s );
	local q = v * ( 1 - s * d );
	local t = v * ( 1 - s * ( 1 - d ) );
	if c == 0 then
		return v, t, p
	elseif c == 1 then
		return q, v, p
	elseif c == 2 then
		return p, v, t
	elseif c == 3 then
		return p, q, v
	elseif c == 4 then
		return t, p, v
	elseif c == 5 then
		return v, p, q
	end
end


function WeaveDelays.ClipRange(s, s_min, s_max)
	return math.max(math.min(s, s_max), s_min)
end

function WeaveDelays.FormatTimeMilliseconds(timeMilliseconds)
	if timeMilliseconds ~= nil then
		return ""..math.floor(timeMilliseconds)
	else
		return "-"
	end
end

function WeaveDelays.FormatTimePercent(timePercent)
	if timePercent ~= nil then
		return ""..math.floor(timePercent).."%"
	else
		return "-"
	end
end


function WeaveDelays.FormatTimeSeconds(timeMilliseconds)
	if timeMilliseconds < 10000 then
		return ""..math.floor(timeMilliseconds*0.01)*0.1
	else
		return ""..math.floor(timeMilliseconds*0.001)
	end
	
end

function WeaveDelays.Update()
	
	local historySize = WeaveDelays.historySize
	if WeaveDelays.inCombat then
		historySize = WeaveDelays.historySizeInCombat
    end
	
	local activeBarIndex = WeaveDelays.log.getActiveBarIndex()
	for i = 1, WeaveDelays.numSlots do
	
		local v_top2   = WeaveDelays.log.getUptime(activeBarIndex, WeaveDelays.slotOffset+i, historySize)
		local v_top, n_top = WeaveDelays.log.getMeanDelaySinceLastLightAttack(activeBarIndex, WeaveDelays.slotOffset+i, historySize)
		local v_bottom, n_bottom = WeaveDelays.log.getMeanDelaySinceLastSkill(activeBarIndex, WeaveDelays.slotOffset+i, historySize)

		local v_total = v_top + v_bottom
		local n_total = n_top + n_bottom

		local s_top2   = WeaveDelays.FormatTimePercent(v_top2)
		local s_bottom = WeaveDelays.FormatTimeMilliseconds(WeaveDelays.ClipRange(v_top, WeaveDelays.displayTimeMin, WeaveDelays.displayTimeMax))
		local s_top    = WeaveDelays.FormatTimeMilliseconds(WeaveDelays.ClipRange(v_total, WeaveDelays.displayTimeMin, WeaveDelays.displayTimeMax))
		
		WeaveDelays.slotTop2LeftLabel[i]:SetText(s_top2)
		
		WeaveDelays.slotTopLeftLabel[i]:SetText(s_top)
		WeaveDelays.slotBottomLeftLabel[i]:SetText(s_bottom)
		
		WeaveDelays.SetColorR(WeaveDelays.slotTopBar2[i], v_top2)
		
		WeaveDelays.SetColor(WeaveDelays.slotTopBar[i], v_total, n_total)
		WeaveDelays.SetColor(WeaveDelays.slotBottomBar[i], v_total, n_total)
		
		WeaveDelays.slotTopRightLabel[i]:SetText(""..WeaveDelays.log.getMissedLightAttacksBefore(activeBarIndex, WeaveDelays.slotOffset+i, historySize))
		WeaveDelays.slotBottomRightLabel[i]:SetText(""..WeaveDelays.log.getMissedLightAttacksAfter(activeBarIndex, WeaveDelays.slotOffset+i, historySize))

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
			elseif WeaveDelays.displayMode == 5 then
				local delta = WeaveDelays.log.getDelayS1_x_S2(j,i)
				local n     = WeaveDelays.log.getTransitionsS1_x_S2(j,i)
				
				if delta ~= nil and delta > 0 and n ~= nil then
					local totalTime = delta * n
					lbl:SetText(WeaveDelays.FormatTimeSeconds(totalTime))
					WeaveDelays.SetColorN(ctl, totalTime/1000)
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
	local statusLbl = WINDOW_MANAGER:GetControlByName("WEAVEDELAYSUI_STATUS_LABEL")
	if WeaveDelays.displayMode == 1 then
		lbl:SetText("t")
		statusLbl:SetText("average time lost between casts of skills x and y")
	elseif WeaveDelays.displayMode == 2 then
		lbl:SetText("C")
		statusLbl:SetText("number of transitions skill x - LA - skill y")
	elseif WeaveDelays.displayMode == 3 then
		lbl:SetText("M")
		statusLbl:SetText("number of transitions skill x - skill y (no LA)")
	elseif WeaveDelays.displayMode == 4 then
		lbl:SetText("R")
		statusLbl:SetText("fraction of missed light attacks between skill x and skill y")
	elseif WeaveDelays.displayMode == 5 then
		lbl:SetText("T")
		statusLbl:SetText("total time lost between casts of skills x and y")
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
	EVENT_MANAGER:RegisterForEvent(WeaveDelays.name.."EventEffectChanged", EVENT_EFFECT_CHANGED, WeaveDelays.EventEffectChanged)

	-- Controls
	WeaveDelays.slotTopBar = {}
	WeaveDelays.slotTopBar2 = {}
	WeaveDelays.slotBottomBar = {}
	WeaveDelays.slotTopLeftLabel = {}
	WeaveDelays.slotTopRightLabel = {}
	WeaveDelays.slotTop2LeftLabel = {}
	WeaveDelays.slotTop2RightLabel = {}
	WeaveDelays.slotBottomLeftLabel = {}
	WeaveDelays.slotBottomRightLabel = {}
	
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

	local drawTier = DT_HIGH
	local drawLevel = 5
	local slot = ZO_ActionBar_GetButton(WeaveDelays.slotOffset+1).slot
	local width,height = slot:GetDimensions()
	height = height * WeaveDelays.controlBoxHeight
	width  = width  * WeaveDelays.controlBoxWidth
	
	local lt2 =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
	lt2:SetFont(WeaveDelays.controlLabelFont)
	lt2:SetDimensions(width, height)
	lt2:SetDrawTier(drawTier)
	lt2:SetDrawLayer(drawLevel+1)
	lt2:SetText("uptime")
	lt2:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	lt2:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,-1.1*width,topBarOffsetHeight+WeaveDelays.controlTopLabelOffsetY-height)
	
	local lt1 =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
	lt1:SetFont(WeaveDelays.controlLabelFont)
	lt1:SetDimensions(width, height)
	lt1:SetDrawTier(drawTier)
	lt1:SetDrawLayer(drawLevel+1)
	lt1:SetText("delay")
	lt1:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	lt1:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,-1.1*width,topBarOffsetHeight+WeaveDelays.controlTopLabelOffsetY+2)

	local lb1 = WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
	lb1:SetDimensions(width, height)
	lb1:SetFont(WeaveDelays.controlLabelFont)
	lb1:SetDrawTier(drawTier)
	lb1:SetDrawLayer(drawLevel+1)
	lb1:SetText("offset")
	lb1:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
	lb1:SetAnchor(TOPLEFT,slot,BOTTOMLEFT,-1.1*width,0)
		
	for i = 1, WeaveDelays.numSlots do
		slot = ZO_ActionBar_GetButton(WeaveDelays.slotOffset+i).slot
		
		width,height = slot:GetDimensions()
		height = height * WeaveDelays.controlBoxHeight
		width  = width  * WeaveDelays.controlBoxWidth
		local t1 = WINDOW_MANAGER:CreateControl(nil, slot, CT_TEXTURE)
		t1:SetDimensions(width, height)
		t1:SetDrawTier(drawTier)
		t1:SetDrawLayer(drawLevel)
		t1:SetColor(1.0,1.0,1.0,0.2)
		t1:SetAnchor(BOTTOMLEFT, slot,TOPLEFT,0,topBarOffsetHeight-1)
		table.insert(WeaveDelays.slotTopBar, t1)
		
		local lt1 =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		lt1:SetFont(WeaveDelays.controlLabelFont)
		lt1:SetDimensions(width, height)
		lt1:SetDrawTier(drawTier)
		lt1:SetDrawLayer(drawLevel+1)
		lt1:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,1,topBarOffsetHeight+WeaveDelays.controlTopLabelOffsetY)
		table.insert(WeaveDelays.slotTopLeftLabel, lt1)
		
		local ltw1 =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		ltw1:SetFont(WeaveDelays.controlLabelFont)
		ltw1:SetDimensions(width*(1.0-WeaveDelays.controlRightLabelOffsetX), height)
		ltw1:SetDrawTier(drawTier)
		ltw1:SetDrawLayer(drawLevel+1)
		ltw1:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,width*WeaveDelays.controlRightLabelOffsetX,topBarOffsetHeight+WeaveDelays.controlRightLabelOffsetY)
		table.insert(WeaveDelays.slotTopRightLabel, ltw1)
		
		local t2 = WINDOW_MANAGER:CreateControl(nil, slot, CT_TEXTURE)
		t2:SetDimensions(width, height)
		t2:SetDrawTier(drawTier)
		t2:SetDrawLayer(drawLevel)
		t2:SetColor(1.0,1.0,1.0,0.2)
		t2:SetAnchor(BOTTOMLEFT, slot,TOPLEFT,0,topBarOffsetHeight-1-height-2)
		table.insert(WeaveDelays.slotTopBar2, t2)
		
		local lt2 =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		lt2:SetFont(WeaveDelays.controlLabelFont)
		lt2:SetDimensions(width, height)
		lt2:SetDrawTier(drawTier)
		lt2:SetDrawLayer(drawLevel+1)
		lt2:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,1,topBarOffsetHeight+WeaveDelays.controlTopLabelOffsetY-height-2)
		table.insert(WeaveDelays.slotTop2LeftLabel, lt2)
		
		local ltw2 =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		ltw2:SetFont(WeaveDelays.controlLabelFont)
		ltw2:SetDimensions(width*(1.0-WeaveDelays.controlRightLabelOffsetX), height)
		ltw2:SetDrawTier(drawTier)
		ltw2:SetDrawLayer(drawLevel+1)
		ltw2:SetAnchor(BOTTOMLEFT,slot,TOPLEFT,width*WeaveDelays.controlRightLabelOffsetX,topBarOffsetHeight+WeaveDelays.controlRightLabelOffsetY-height-2)
		table.insert(WeaveDelays.slotTop2RightLabel, ltw2)
		
		local b1 = WINDOW_MANAGER:CreateControl(nil, slot, CT_TEXTURE)
		b1:SetDimensions(width, height)
		b1:SetDrawTier(drawTier)
		b1:SetDrawLayer(drawLevel)
		b1:SetColor(1.0,1.0,1.0,0.2)
		b1:SetAnchor(TOPLEFT,slot,BOTTOMLEFT,0,1)
		table.insert(WeaveDelays.slotBottomBar, b1)

		local lb1 = WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		lb1:SetDimensions(width, height)
		lb1:SetFont(WeaveDelays.controlLabelFont)
		lb1:SetDrawTier(drawTier)
		lb1:SetDrawLayer(drawLevel+1)
		lb1:SetAnchor(TOPLEFT,slot,BOTTOMLEFT,1,-2)
		table.insert(WeaveDelays.slotBottomLeftLabel, lb1)
		
		local lbw1 =  WINDOW_MANAGER:CreateControl(nil, slot, CT_LABEL)
		lbw1:SetFont(WeaveDelays.controlLabelFont)
		lbw1:SetDimensions(width*(1.0-WeaveDelays.controlRightLabelOffsetX), height)
		lbw1:SetDrawTier(drawTier)
		lbw1:SetDrawLayer(drawLevel+1)
		lbw1:SetAnchor(TOPLEFT,slot,BOTTOMLEFT,width*WeaveDelays.controlRightLabelOffsetX,-2)
		table.insert(WeaveDelays.slotBottomRightLabel, lbw1)
		
	end
	
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
	
	local statusLbl = WINDOW_MANAGER:CreateControl("WEAVEDELAYSUI_STATUS_LABEL", parentControl, CT_LABEL)
	statusLbl:SetFont("ZoFontGameMedium")
	statusLbl:SetColor(0.9,0.9,0.9,0.9)
	statusLbl:SetDimensions(450, 32)
	statusLbl:SetDrawTier(2)
	statusLbl:SetDrawLayer(6)
	statusLbl:SetAnchor(TOPLEFT, parentControl, TOPLEFT, 10, 465)
	
	statusLbl:SetText(WeaveDelays.name.." v"..WeaveDelays.version)
	
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

function WeaveDelays.EventEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	if sourceType == COMBAT_UNIT_TYPE_PLAYER then
		if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_FADED or changeType == EFFECT_RESULT_UPDATED then
			local matched = false
			for i =1,#WeaveDelays.frontBarSkills do
				if WeaveDelays.frontBarSkills[i] == abilityId then
					matched = true
					break
				end
			end
			for i =1,#WeaveDelays.backBarSkills do
				if WeaveDelays.backBarSkills[i] == abilityId then
					matched = true
					break
				end
			end
			if matched and (endTime - beginTime) > 0 then	
				WeaveDelays.log.updateAbilityDuration(abilityId, 1000 * (endTime - beginTime))
			end
		end
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
        WeaveDelays.ToggleWindow()
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
