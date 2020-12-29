WeaveDelays = WeaveDelays or { }
local WeaveDelays = WeaveDelays

WeaveDelays.name                = 'WeaveDelays'
WeaveDelays.slash               = "/weavedelays"
WeaveDelays.version             = 0.4
WeaveDelays.DefaultSavedVars    = {["delayBarOffsetX"]=300,["delayBarOffsetY"]=300,["delayBar2OffsetX"]=300,["delayBar2OffsetY"]=400,["numDelayBarSlots"]=5,["numDelayBarRows"]=1,["showDelayBar"]=true,["showAbilityRecastBar"]=false,["showSkillsInDelayBar"]=false,["showDelayBarOnlyInCombat"]=false,["showDelayBarAfterCombat"]=10,["unlockUI"]=false,["showActionBarAddon"]=true}
WeaveDelays.displayTimeMax      = 999
WeaveDelays.displayTimeMin      = -99.
WeaveDelays.historySize 	    = 99999
WeaveDelays.historySizeInCombat = 5
WeaveDelays.numSlots            = 6
WeaveDelays.slotOffset          = 2
WeaveDelays.playerName = GetRawUnitName("player")

WeaveDelays.inCombat           = false
WeaveDelays.startCombatSlotId  = -1
WeaveDelays.startCombattime    = -1
WeaveDelays.lastLAtime 	       = 0
WeaveDelays.lastSkillStartTime = 0
WeaveDelays.lastSkillEndTime   = 0
WeaveDelays.lastSkillSlotId    = 0
WeaveDelays.lastSkillBarIdx    = 0
WeaveDelays.skillBarIdx        = 0
WeaveDelays.skillBarIdx0Id     = -1
WeaveDelays.skillsSinceLastLA  = 0
WeaveDelays.banditsFound       = false
WeaveDelays.actionDurationReminderFound = falsew
WeaveDelays.repositionHealthBar = true

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

WeaveDelays.textureCache = {}
WeaveDelays.textureCache[114716] = "/esoui/art/icons/ability_sorcerer_thunderstomp_proc.dds"

WeaveDelays.effectiveAbilityDurations = {
	[20779] = 20000,
	[23213] = 23000,
	[24328] = 6000,
	[32673] = 6000,
	[39053] = 10000,
	[39073] = 10000,
	[39095] = 23000,
	[40058] = 12000,
	[40094] = 8000,
	[40382] = 18000,
	[40457] = 12000,
	[40465] = 16000,
	[41958] = 30000,
	[42028] = 9000,
	[42038] = 8000,
	[50079] = 10000,
	[61500] = 8000,
	[103706] = 36000,
	[117850] = 10000,
	[118008] = 12000,
	[118726] = 16000,
--	[117749] = 2900,
	}
	
WeaveDelays.abilityPriorities = {
	[117850] = 100,
	[39053] = 1000,
	[118726] = 500,
	[40457] = 50,
	[40382] = 18000,
	[118008] = 12000,
	[42028] = 9000,
	[117749] = 2900,
	[40465] = 16000,
	}
WeaveDelays.trackedAbilities = {}

	
WeaveDelays.palettes = {
	["uptime"] = {
		[1] = {0,         0, 1.0, 1.0},
		[2] = {80.0,   60.0, 1.0, 1.0},
		[3] = {101.0, 180.0, 1.0, 1.0}
	},
	["delay"] = {
		[1] = {-500, 180.0, 1.0, 1.0},
		[2] = {0,    150.0, 1.0, 1.0},
		[3] = {50,  90.0, 1.0, 1.0},
		[4] = {100,  60.0, 1.0, 1.0},
		[5] = {150,  33.0, 1.0, 1.0},
		[6] = {200,  18.0, 1.0, 1.0},
		[7] = {400,  10.0, 1.0, 1.0},
		[8] = {9999,  0.0, 1.0, 1.0}
	}
}
function WeaveDelays.Reset()
	WeaveDelays.log.reset()
	WeaveDelays.frontBarSkills = {}
	WeaveDelays.backBarSkills = {}
end

WeaveDelaysInterface = WeaveDelaysInterface or {}

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 UI
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function WeaveDelaysInterface.ToggleWindow()
	WeaveDelays.ToggleWindow()
end

function WeaveDelays.ToggleWindow()
	WeaveDelays.windowShow = not WeaveDelays.windowShow
	WEAVEDELAYSUI:SetHidden(not WeaveDelays.windowShow)
end


function WeaveDelaysSaveDelayBarPosition()
	WeaveDelays.savedVariables.delayBarOffsetX = WEAVEDELAYSBAR:GetLeft()
	WeaveDelays.savedVariables.delayBarOffsetY = WEAVEDELAYSBAR:GetTop()
end


function WeaveDelays.restoreDelayBarPosition()
	WEAVEDELAYSBAR:ClearAnchors()
	WEAVEDELAYSBAR:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, WeaveDelays.savedVariables.delayBarOffsetX, WeaveDelays.savedVariables.delayBarOffsetY)
end

function WeaveDelaysSaveDelayBar2Position()
	WeaveDelays.savedVariables.delayBar2OffsetX = WEAVEDELAYSBAR2:GetLeft()
	WeaveDelays.savedVariables.delayBar2OffsetY = WEAVEDELAYSBAR2:GetTop()
end

function WeaveDelays.restoreDelayBar2Position()
	WEAVEDELAYSBAR2:ClearAnchors()
	WEAVEDELAYSBAR2:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, WeaveDelays.savedVariables.delayBar2OffsetX, WeaveDelays.savedVariables.delayBar2OffsetY)
end

function WeaveDelays.OnReticleHiddenUpdate()
	if not WeaveDelays.savedVariables.unlockUI then
		if WeaveDelays.savedVariables.showDelayBar then
			WEAVEDELAYSBAR:SetHidden(IsReticleHidden())
		end
		if WeaveDelays.savedVariables.showAbilityRecastBar then
			WEAVEDELAYSBAR2:SetHidden(IsReticleHidden())
		end
	else
		if WeaveDelays.savedVariables.showDelayBar then
			WEAVEDELAYSBAR:SetHidden(false)
		end
		if WeaveDelays.savedVariables.showAbilityRecastBar then
			WEAVEDELAYSBAR2:SetHidden(false)
		end
	end
end


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 color helper functions
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function WeaveDelays.SetColor(c, delay, n)
	if c ~= nil then
		if n > 0 then
			local h,s,v = WeaveDelays.GetPaletteColor(WeaveDelays.palettes["delay"], delay)
			local r,g,b = HSVToRGB(h,s,v)
			c:SetColor(r, g, b, 1.0)
		elseif delay == -1 then
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

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 string formatting
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 draw UI
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function WeaveDelays.UiLoop()
	if WeaveDelays.inCombat then
		WeaveDelays.UpdateAbilityRecastBar()
	end
end


function WeaveDelays.Update(fullCombat)
	WeaveDelays.UpdateActionBar(fullCombat)
	WeaveDelays.UpdateDelayBar()
	WeaveDelays.UpdateAbilityRecastBar()
end

function WeaveDelays.UpdateActionBar(fullCombat)

	-- actionBar
	--local historySize = WeaveDelays.historySizeInCombat
	local historySize = WeaveDelays.savedVariables.numDelayBarSlots * WeaveDelays.savedVariables.numDelayBarRows
	if fullCombat ~= nil and fullCombat then
		historySize = WeaveDelays.historySize
    end
	
	local combos = WeaveDelays.log.getLastCombos(historySize)
	
	local activeBarIndex = WeaveDelays.log.getActiveBarIndex()
	
	local delays = {}
	local missedLightAttacks = {}
	local missedLightAttacksAfterSkill = {}

	for i = 1, WeaveDelays.numSlots do
		table.insert(delays, {})
		table.insert(missedLightAttacks, 0)
		table.insert(missedLightAttacksAfterSkill, 0)
	end
	
	-- {skillIndex, boundID, 0, lightAttackRegistered, lightAttackConfirmed, lightAttackQueued, skillCastTime, activeBarIndex}
	
	-- analysis
	for i=1,#combos do
		local combo = combos[i]
		if combo[8] == activeBarIndex then
			if combo[3] < 2500 then
				table.insert(delays[combo[1]], combo[3])
			end
			if not combo[4] or not combo[5] then
				missedLightAttacks[combo[1]] = missedLightAttacks[combo[1]] + 1
			end
		end
		
		if combos[i+1] ~= nil and combos[i+1][8] == activeBarIndex and (not combo[4] or not combo[5]) then
			missedLightAttacksAfterSkill[combos[i+1][1]] = missedLightAttacksAfterSkill[combos[i+1][1]] + 1
		end
			
	end
	
	-- action bar
	for i = 1, WeaveDelays.numSlots do
	
		local uptime = WeaveDelays.log.getUptime(activeBarIndex, WeaveDelays.slotOffset+i, historySize)
		WeaveDelays.SetColorR(WeaveDelays.slotTopBar2[i], uptime)
		WeaveDelays.slotTop2LeftLabel[i]:SetText(WeaveDelays.FormatTimePercent(uptime))
		
		local meanDelay, n_total = WeaveDelays.log.getMean(delays[i], #delays[i])
		local meanDelayFormatted = WeaveDelays.FormatTimeMilliseconds(WeaveDelays.ClipRange(meanDelay, WeaveDelays.displayTimeMin, WeaveDelays.displayTimeMax))
		WeaveDelays.slotTopLeftLabel[i]:SetText(meanDelayFormatted)
		
		local missedLightAttacksFormatted = tostring(missedLightAttacks[i])
		WeaveDelays.slotTopRightLabel[i]:SetText(missedLightAttacksFormatted)
		
		local missedLightAttacksAfterSkillFormatted = tostring(missedLightAttacksAfterSkill[i])
		WeaveDelays.slotBottomRightLabel[i]:SetText(missedLightAttacksAfterSkillFormatted)
		
		WeaveDelays.slotBottomLeftLabel[i]:SetText("")
		
		WeaveDelays.SetColor(WeaveDelays.slotTopBar[i], meanDelay, n_total)
		WeaveDelays.SetColor(WeaveDelays.slotBottomBar[i], meanDelay, n_total)

	end
end

function WeaveDelays.UpdateDelayBar()

	if not WeaveDelays.savedVariables.showDelayBar then
		return
	end
	
	-- delay bar
	local bg = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBARBG')
	local n  = WeaveDelays.savedVariables.numDelayBarSlots * WeaveDelays.savedVariables.numDelayBarRows
	
	local lastCombos 
	
	if historySize == n then
		lastCombos = combos
	else
		lastCombos = WeaveDelays.log.getLastCombos(n)
	end
	
	local gameTime = GetGameTimeMilliseconds() 

	
	for i = 1, n do
		local barBox     = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBARL'..i)
		local barMarker  = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBARB'..i)
		local barPicture = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBARS'..i)
		local barQueueFlag = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBARQ'..i)
		
		if lastCombos[n+1-i] ~= nil then
			local combo             = lastCombos[n+1-i]
			local lightAttackMissed = not (combo[4] and combo[5])
			local t                 = combo[3]
			
			if combo[7]~= nil and gameTime - combo[7] > 100 then
				if not lightAttackMissed then
					barQueueFlag:SetText("")
				elseif not combo[4] then
					barQueueFlag:SetText("M")
				elseif combo[6] then
					barQueueFlag:SetText("Q")
				else
					barQueueFlag:SetText("X")
				end
			else
				barQueueFlag:SetText("")
			end
			
			
			if lightAttackMissed ~= nil and lightAttackMissed then
				barMarker:SetColor(1.0,1.0,1.0,0.0)
				t = 1000
			else
				barMarker:SetColor(1.0,1.0,1.0,1.0)
			end
			
			if t < 1 then
				t = 1
			end
			if t > 950 then
				t = 950
			end
			
			if combo[7]~= nil and gameTime - combo[7] > 100 then
				WeaveDelays.SetColor(barBox, t, 1)
			else
				barBox:SetColor(1.0,1.0,1.0,0.1)
			end
			
			if t > 450 then
				t = 450
			end
			barMarker:SetAnchor(TOPLEFT, barBox, TOPLEFT, math.floor(t/10.0), -4)
			
			if WeaveDelays.savedVariables.showSkillsInDelayBar then
				local boundId  = combo[2]
				barPicture:SetColor(1.0,1.0,1.0,1.0)
				barPicture:SetTexture(WeaveDelays.GetTextureFromAbilityId(boundId))
			end
		else
			barMarker:SetColor(1.0,1.0,1.0,0.2)
			barBox:SetColor(1.0,1.0,1.0,0.2)
			if WeaveDelays.savedVariables.showSkillsInDelayBar then
				barPicture:SetTexture(nil)
				barPicture:SetColor(1.0,1.0,1.0,0.1)
			end
			barQueueFlag:SetText("")
		end
	end
end

function WeaveDelays.UpdateAbilityRecastBar()

	if not WeaveDelays.savedVariables.showAbilityRecastBar then
		return
	end
	
	-- tracked ability bar
	local gameTime = GetGameTimeMilliseconds() 
	local bg = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2BG')
	
	local abilityIndex = 1
	local abilitiesSortedByPriority = {}
	local abilitiesTimeoutPassed = {}
	for k,v in pairs(WeaveDelays.trackedAbilities) do
		table.insert(abilitiesSortedByPriority, {k,v[1]})
		table.insert(abilitiesSortedByPriority, {k,v[1]+v[2]})
	end
	table.sort(abilitiesSortedByPriority, function(a,b) return a[2] < b[2] end)
	
	for i,p in ipairs(abilitiesSortedByPriority) do
		abilityId, abilityTimeout = unpack(p)
		local abilityIcon  = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2S'..abilityIndex)
		local abilityTimer = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2T'..abilityIndex)
		
		local timeToCast = abilityTimeout-gameTime
		local t0 = timeToCast
		while t0 > 1000 do
			abilityIcon:SetTexture(nil)
			abilityIcon:SetColor(1.0,1.0,1.0,0.2)
			abilityTimer:SetColor(1.0,1.0,1.0,1.0)
			abilityTimer:SetText("S")
			abilityIndex = abilityIndex + 1
			if abilityIndex > 10 then 
				break
			end
		    abilityIcon  = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2S'..abilityIndex)
		    abilityTimer = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2T'..abilityIndex)
			t0 = t0 - 1000
		end
		if abilityIndex > 10 then 
			break
		end
		if timeToCast > 0 or abilitiesTimeoutPassed[abilityId] == nil then
			abilityIcon:SetColor(1.0,1.0,1.0,1.0)
			abilityIcon:SetTexture(WeaveDelays.GetTextureFromAbilityId(abilityId))
			abilityTimer:SetText(""..math.floor((timeToCast)*0.01)*0.1)
			if timeToCast < 0 then
				abilityTimer:SetColor(1.0,0.0,0.0,1.0)
				abilitiesTimeoutPassed[abilityId] = true
			else
				abilityTimer:SetColor(1.0,1.0,1.0,1.0)
			end
			abilityIndex = abilityIndex + 1
		end
		if abilityIndex > 10 then 
			break
		end
	end
	while abilityIndex < 10 do
		local abilityIcon  = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2S'..abilityIndex)
		local abilityTimer = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2T'..abilityIndex)
		abilityIcon:SetTexture(nil)
		abilityIcon:SetColor(1.0,1.0,1.0,0.1)
		abilityTimer:SetText("")
		abilityIndex = abilityIndex + 1
	end
end

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 combat events
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function WeaveDelays.OnCombatEvent(eventCode,  result, isError,  abilityName,  abilityGraphic,  abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue,  powerType,  damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

	if abilityActionSlotType == ACTION_SLOT_TYPE_LIGHT_ATTACK and sourceName == WeaveDelays.playerName then
		if result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE or results == ACTION_RESULT_HEAL or result == ACTION_RESULT_CRITICAL_HEAL then
			WeaveDelays.log.confirmLightAttack()
			WeaveDelays.Update()
		elseif result == ACTION_RESULT_QUEUED then
			WeaveDelays.log.flagLightAttackQueued()
		end
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
				--d("upd time: effectName="..effectName .. "=> ".. abilityId.." t=".. 1000 * (endTime - beginTime))
				
			end
		end
	end
end

function WeaveDelays.playerActionSlotAbilityUsed(e, slotId)
	WeaveDelays.log.slotUsed(slotId)
	if WeaveDelays.inCombat then
		WeaveDelays.Update()
	end
	local abilityId = GetSlotBoundId(slotId)
	if WeaveDelays.effectiveAbilityDurations[abilityId] ~= nil then
		WeaveDelays.trackedAbilities[abilityId] = {GetGameTimeMilliseconds() + WeaveDelays.effectiveAbilityDurations[abilityId], WeaveDelays.effectiveAbilityDurations[abilityId]}
	end
end

function  WeaveDelays.OnWeaponSwap(_, activeWeaponPair, locked)
	WeaveDelays.log.weaponSwap(activeWeaponPair)
	if WeaveDelays.inCombat then
		WeaveDelays.UpdateActionBar()
		WeaveDelays.UpdateDelayBar()
	else
		WeaveDelays.UpdateActionBar(true)
	end
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
		WeaveDelays.enterCombat()
	elseif not inCombat and WeaveDelays.inCombat then
		WeaveDelays.Update(true)
		WeaveDelays.inCombat = inCombat
		WeaveDelays.leaveCombat()
	end
end

function WeaveDelays.enterCombat()
	WeaveDelays.log.startCombat()
	WeaveDelays.Update()
end

function WeaveDelays.leaveCombat()
	WeaveDelays.log.endCombat()
	WeaveDelays.trackedAbilities = {}
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
	if WeaveDelays.textureCache[abilityId] ~= nil then
		return WeaveDelays.textureCache[abilityId]
	else
		local hasProgression, progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
		if hasProgression then
			local _, morph, rank = GetAbilityProgressionInfo(progressionIndex)
			local name, texture, abilityIndex = GetAbilityProgressionAbilityInfo(progressionIndex, morph, rank)
			WeaveDelays.textureCache[abilityId] = texture
			return texture
		else
			return 0
		end
	end
end


-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--                 init
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function WeaveDelays:Initialize()
	-- Saved Vars
	WeaveDelays.savedVariables = ZO_SavedVars:New("WeaveDelaysVars", 1, nil, WeaveDelays.DefaultSavedVars)
	if WeaveDelays.savedVariables.numDelayBarSlots == nil or WeaveDelays.savedVariables.numDelayBarSlots < 1 then
		WeaveDelays.savedVariables.numDelayBarSlots = 1
	end
	WeaveDelays.log = WeaveDelayLog.new()
	WeaveDelays.log.reset()
	
	-- Events
	EVENT_MANAGER:RegisterForEvent(WeaveDelays.name.."playerActionSlotAbilityUsed", EVENT_ACTION_SLOT_ABILITY_USED, WeaveDelays.playerActionSlotAbilityUsed)
	EVENT_MANAGER:RegisterForEvent(WeaveDelays.name.."WeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, WeaveDelays.OnWeaponSwap)
	EVENT_MANAGER:RegisterForEvent(WeaveDelays.name.."PlayerCombatState", EVENT_PLAYER_COMBAT_STATE, WeaveDelays.OnPlayerCombatState)
	EVENT_MANAGER:RegisterForEvent(WeaveDelays.name.."EventEffectChanged", EVENT_EFFECT_CHANGED, WeaveDelays.EventEffectChanged)

	EVENT_MANAGER:RegisterForEvent(WeaveDelays.name, EVENT_COMBAT_EVENT, WeaveDelays.OnCombatEvent)
	
	EVENT_MANAGER:RegisterForEvent(WeaveDelays.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, WeaveDelays.OnReticleHiddenUpdate)


	EVENT_MANAGER:RegisterForUpdate("WeaveDelaysUiLoop", 200, WeaveDelays.UiLoop)
		
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
	elseif WeaveDelays.actionDurationReminderFound then
		local slot = ZO_ActionBar_GetButton(3).slot
		local width,height = slot:GetDimensions()
		topBarOffsetHeight = -height
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
	
	ZO_CreateStringId("SI_BINDING_NAME_WD_TOGGLE", "Toggle WeaveDelays window")
	
	if not WeaveDelays.banditsFound and WeaveDelays.repositionHealthBar then
		local _, point, relativeTo, relativePoint, offsetX, offsetY = ZO_PlayerAttributeHealth:GetAnchor(0)
		slot = ZO_ActionBar_GetButton(WeaveDelays.slotOffset+1).slot
		width,height = slot:GetDimensions()
		offsetY = offsetY - 0.5*height
		ZO_PlayerAttributeHealth:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
	end
	
	if WeaveDelays.actionDurationReminderFound and WeaveDelays.repositionHealthBar then
		local _, point, relativeTo, relativePoint, offsetX, offsetY = ZO_PlayerAttributeHealth:GetAnchor(0)
		slot = ZO_ActionBar_GetButton(WeaveDelays.slotOffset+1).slot
		width,height = slot:GetDimensions()
		offsetY = offsetY - height
		ZO_PlayerAttributeHealth:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
	end
	
	--- delay bar
	local bg = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBARBG')
	local n = WeaveDelays.savedVariables.numDelayBarSlots
	local r = WeaveDelays.savedVariables.numDelayBarRows
	local w = 50
	local m = 2
	local h = 22
	
	if WeaveDelays.savedVariables.showSkillsInDelayBar then
		h = h + 55
	end
	
	if WeaveDelays.savedVariables.showDelayBar then
		WeaveDelays.restoreDelayBarPosition()
		WEAVEDELAYSBAR:SetHidden(False)
		WEAVEDELAYSBAR:SetDimensions((w+m)*n+2, h*r)
		bg:SetDimensions((w+m)*n+2, h*r)
		
		local ctl,ctl2,ctl3,ctl4
		local k=1
		for j=1, r do
			for i=1, n do
				ctl = WINDOW_MANAGER:CreateControl("WEAVEDELAYSBARL"..k, bg, CT_TEXTURE)
				ctl:SetDimensions(w, 14)
				ctl:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*(w+m)+1, 4+(j-1)*h)
				ctl:SetColor(1.0,1.0,1.0,0.2)
				ctl2 = WINDOW_MANAGER:CreateControl("WEAVEDELAYSBARB"..k, bg, CT_TEXTURE)
				ctl2:SetDimensions(5, 20)
				ctl2:SetAnchor(TOPLEFT, ctl, TOPLEFT, 0, -4)
				ctl2:SetColor(1.0,1.0,1.0,0.3)
				if WeaveDelays.savedVariables.showSkillsInDelayBar then
					ctl3 = WINDOW_MANAGER:CreateControl("WEAVEDELAYSBARS"..k, bg, CT_TEXTURE)
					ctl3:SetDimensions(50, 50)
					ctl3:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*(w+m)+1, 20+(j-1)*h)
					ctl3:SetColor(1.0,1.0,1.0,0.1)
				end
				ctl4 = WINDOW_MANAGER:CreateControl("WEAVEDELAYSBARQ"..k, bg, CT_LABEL)
				ctl4:SetFont(WeaveDelays.controlLabelFont)
				ctl4:SetDimensions(16, 16)
				ctl4:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*(w+m)+35, 3+(j-1)*h)
				k = k+1
			end
		end
	end
	
	--- ability recast bar 
	
	if WeaveDelays.savedVariables.showAbilityRecastBar then
		WeaveDelays.restoreDelayBar2Position()
		WEAVEDELAYSBAR2:SetHidden(False)
		
		local bg = WINDOW_MANAGER:GetControlByName('WEAVEDELAYSBAR2BG')
		local n = 10
		for i=1, n do
			ctl3 = WINDOW_MANAGER:CreateControl("WEAVEDELAYSBAR2S"..i, bg, CT_TEXTURE)
			ctl3:SetDimensions(50, 50)
			ctl3:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*(w+m)+1, 5)
			ctl3:SetColor(1.0,1.0,1.0,0.1)
			ctl4 = WINDOW_MANAGER:CreateControl("WEAVEDELAYSBAR2T"..i, bg, CT_LABEL)
			ctl4:SetFont("ZoFontGameLargeBoldShadow")
			ctl4:SetDimensions(24, 24)
			ctl4:SetAnchor(TOPLEFT, bg, TOPLEFT, (i-1)*(w+m)+16, 17)
		end
	end

	--- menu
	WeaveDelays.InitializeMenu()
					
end


function WeaveDelays.InitializeMenu()

    local panelData = {
        type = "panel",
        name = WeaveDelays.name,
        displayName = WeaveDelays.name,
        author = "Psiioniic",
        version = tostring(WeaveDelays.version),
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LibAddonMenu2:RegisterAddonPanel(WeaveDelays.name, panelData)
	
	local optionsTable = {
	{
		type = "header",
		name = "WeaveDelays",
		width = "full",
	},
	{
		type = "checkbox",
		name = "Unlock UI",
		tooltip = "",
		getFunc = function()
			return WeaveDelays.savedVariables.unlockUI
		end,
		setFunc = function(value)
			WeaveDelays.savedVariables.unlockUI = value
		end,
		width = "full",
		default = false,
	},
	{
		type = "checkbox",
		name = "Show action bar addon",
		tooltip = "",
		getFunc = function()
			return WeaveDelays.savedVariables.showActionBarAddon
		end,
		setFunc = function(value)
			WeaveDelays.savedVariables.showActionBarAddon = value
		end,
		width = "full",
		default = false,
		requiresReload = true,
	},
	{
		type = "checkbox",
		name = "Show delay bar",
		tooltip = "",
		getFunc = function()
			return WeaveDelays.savedVariables.showDelayBar
		end,
		setFunc = function(value)
			WeaveDelays.savedVariables.showDelayBar = value
		end,
		width = "full",
		default = false,
		requiresReload = true,
	},
	{
		type = "slider",
		name = "Delay bar slots",
		tooltip = "",
		min = 1,
		max = 40,
		step = 1,
		disabled = function()
			return (not WeaveDelays.savedVariables.showDelayBar)
		end,
		getFunc = function()
			return WeaveDelays.savedVariables.numDelayBarSlots
		end,
		setFunc = function(value)
			WeaveDelays.savedVariables.numDelayBarSlots = tonumber(value)
		end,
		width = "full",
		default = 5,
		requiresReload = true,
	},
	{
		type = "slider",
		name = "Delay bar rows",
		tooltip = "",
		min = 1,
		max = 20,
		step = 1,
		disabled = function()
			return (not WeaveDelays.savedVariables.showDelayBar)
		end,
		getFunc = function()
			return WeaveDelays.savedVariables.numDelayBarRows
		end,
		setFunc = function(value)
			WeaveDelays.savedVariables.numDelayBarRows = tonumber(value)
		end,
		width = "full",
		default = 1,
		requiresReload = true,
	},
	--showDelayBarOnlyInCombat
	{
		type = "checkbox",
		name = "Show delay bar only in combat",
		tooltip = "",
		disabled = function()
			return (not WeaveDelays.savedVariables.showDelayBar)
		end,
		getFunc = function()
			return WeaveDelays.savedVariables.showDelayBarOnlyInCombat
		end,
		setFunc = function(value)
			WeaveDelays.savedVariables.showDelayBarOnlyInCombat = value
		end,
		width = "full",
		default = false,
	},
	{
		type = "slider",
		name = "Show delay bar for number of seconds after combat",
		tooltip = "",
		min = 1,
		max = 60,
		step = 1,
		disabled = function()
			return (not WeaveDelays.savedVariables.showDelayBarOnlyInCombat)
		end,
		getFunc = function()
			return WeaveDelays.savedVariables.showDelayBarAfterCombat
		end,
		setFunc = function(value)
			WeaveDelays.savedVariables.showDelayBarAfterCombat = tonumber(value)
		end,
		width = "full",
		default = 10,
	},
	{
		type = "checkbox",
		name = "Show skills in delay bar",
		tooltip = "",
		disabled = function()
			return (not WeaveDelays.savedVariables.showDelayBar)
		end,
		getFunc = function()
			return WeaveDelays.savedVariables.showSkillsInDelayBar
		end,
		setFunc = function(value)
			WeaveDelays.savedVariables.showSkillsInDelayBar = value
		end,
		width = "full",
		default = false,
		requiresReload = true,
	},
	{
		type = "checkbox",
		name = "Show ability recast bar",
		tooltip = "",
		getFunc = function()
			return WeaveDelays.savedVariables.showAbilityRecastBar
		end,
		setFunc = function(value)
			WeaveDelays.savedVariables.showAbilityRecastBar = value
		end,
		width = "full",
		default = false,
		requiresReload = true,
	},
	}
	LibAddonMenu2:RegisterOptionControls(WeaveDelays.name, optionsTable)

end

function WeaveDelays.OnAddOnLoaded(eventCode, addonName)
	if addonName == "BanditsUserInterface" then
		WeaveDelays.banditsFound = true
	end
	if addonName == "ActionDurationReminder" then
		WeaveDelays.actionDurationReminderFound = true
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
        WeaveDelays.ToggleWindow()
    end

    if #commands == 1 then
		if commands[1] == "reset" then
			WeaveDelays.Reset()
		elseif commands[1] == "skills" then
			d("----------")
			d(GetSlotBoundId(3))
			d(GetSlotBoundId(4))
			d(GetSlotBoundId(5))
			d(GetSlotBoundId(6))
			d(GetSlotBoundId(7))
			d(GetSlotBoundId(8))
			d("----------")
		elseif commands[1] == "update" then
			WeaveDelays.Update()
		end
	end
end

EVENT_MANAGER:RegisterForEvent(WeaveDelays.name, EVENT_ADD_ON_LOADED, WeaveDelays.OnAddOnLoaded)


